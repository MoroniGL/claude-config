# Plano: Universal Three-Tier LLM Router

## Context

O usuário quer instalar um roteador LLM de três camadas no diretório `C:\Users\moron\.local\bin`. O roteador classifica cada chamada LLM e despacha para:
- **Tier 1 (chat)**: Modelo local via Ollama (qwen3:32b / qwen3:14b / llama3.2:3b conforme RAM)
- **Tier 2 (cheap)**: DeepSeek V4-Pro via api.deepseek.com
- **Tier 3 (precision)**: Claude Opus 4.7 via api.anthropic.com

O diretório está limpo — nenhum `lib/`, `scripts/`, `memory/`, `.env`, `package.json` ou `.gitignore` existe ainda.

**Nota importante**: Ambiente é **Windows 11**. O script de instalação do Ollama via curl não funciona aqui — o usuário precisa baixar manualmente de https://ollama.com/download/windows se não estiver instalado.

---

## Fase 1 — Verificação de ambiente

### 1.1 Node.js
```bash
node --version
```
- Requer Node 18+. Se ausente ou versão < 18, parar e orientar o usuário.

### 1.2 Ollama
```bash
ollama --version
```
- Se ausente no Windows: informar o usuário para baixar de https://ollama.com/download/windows e encerrar.

### 1.3 Daemon Ollama
```bash
curl -s http://localhost:11434/api/tags
```
- Se falhar: executar `ollama serve` em background.

### 1.4 Escolha do modelo Tier 1 (baseado em RAM livre)
```bash
node -e "console.log(Math.round(require('os').freemem()/1e9))"
```
- >24 GB → `qwen3:32b`
- 12–24 GB → `qwen3:14b`
- <12 GB → `llama3.2:3b`

Executar `ollama pull <modelo>`.

---

## Fase 2 — Coleta de API keys

Ler `.env` se existir. Para cada chave ausente, perguntar ao usuário:
- `DEEPSEEK_API_KEY` — formato `sk-...`
- `ANTHROPIC_API_KEY` — formato `sk-ant-...`

Criar/atualizar `.env` com todas as variáveis definidas no prompt.

Criar `.gitignore` se não existir, adicionando `.env`.

---

## Fase 3 — Estrutura de diretórios

Criar se não existirem:
- `lib/`
- `scripts/`
- `memory/`
- `memory/tier-usage.jsonl` (arquivo vazio)

---

## Fase 4 — Arquivos do router (ordem de criação)

Todos os arquivos usam CommonJS (`.cjs`). Conteúdo exato conforme especificado.

| Arquivo | Responsabilidade |
|---------|-----------------|
| `lib/soft-failure.cjs` | Logger que captura erros sem crash; grava em `memory/soft-failures.jsonl` |
| `lib/ollama-client.cjs` | Cliente HTTP para Ollama; carrega `.env`; expõe `callOllama`, `probeHealth` |
| `lib/deepseek-client.cjs` | Cliente DeepSeek com timeout auto-escalado e retry em erros transitórios (429, 502–504) |
| `lib/anthropic-client.cjs` | Cliente Anthropic Messages API; expõe `callAnthropic`, `probeHealth` |
| `lib/deepseek-verify.cjs` | Hallucination guard — verifica referências de arquivo/SM-NNN no output |
| `lib/tiered-ask.cjs` | **Router principal**: classifica tarefa, aplica quota rolling-50, despacha, loga |
| `scripts/tier-usage-report.cjs` | Relatório de distribuição das últimas N chamadas com médias de latência |

### Lógica de classificação (em `tiered-ask.cjs`)

```
HARD_FLOOR (precision forçada): identity_audit, self_modification, phenomenology,
  architectural_decision, author_voice, high_stakes_review

CHAT: greeting, echo, classify, label, json_reformat, template_slot_fill, dedup, hash_match
  flags: chat, light, cheap, mechanical
  heurística: prompt < 40 chars + saudação

CHEAP: summarize, summary, enrich, reflexion_first_pass, kg_titling, embedding_title,
  compact_memory, long_context_analysis, codebase_analysis, research_synthesis
  flags: deepseek, cheap_reasoning, long_context

DEFAULT (sem match): precision
```

### Quota rolling-50

Targets: `chat=30% / cheap=40% / precision=30%`, tolerância `±10%`.
- Janela: últimas 50 entradas de `memory/tier-usage.jsonl`
- Se a classe classificada está > TOLERANCE acima do target, demover para a classe mais subrepresentada
- Hard-floor nunca demovido

### Fallback chain

```
Tier 1 falha → Tier 2 (deepseek-v4-pro)
Tier 2 (pro) falha → Tier 2 (deepseek-v4-flash)
Tier 2 (flash) falha → Tier 3
Tier 3 falha → lança exceção (sem fallback)
```

---

## Fase 5 — Verificação

### 5.1 Ping todos os tiers
```bash
node lib/tiered-ask.cjs ping
```
Todos os três tiers devem retornar `ok: true`.

### 5.2 4 chamadas diversas
```bash
node -e "require('./lib/tiered-ask.cjs').ask({ prompt: 'hi' }).then(r => console.log('chat tier:', r.tier))"
node -e "require('./lib/tiered-ask.cjs').ask({ purpose: 'summarize', prompt: 'Summarize: The Apollo program ran 1961-1972 and put 12 men on the moon.' }).then(r => console.log('cheap tier:', r.tier))"
node -e "require('./lib/tiered-ask.cjs').ask({ prompt: 'Design a load-balancer for a 10M-RPS service. Tradeoffs.' }).then(r => console.log('precision tier:', r.tier))"
node -e "require('./lib/tiered-ask.cjs').ask({ purpose: 'identity_audit', prompt: 'who are you?' }).then(r => console.log('hard-floor tier:', r.tier))"
```

Resultado esperado: `1, 2, 3, 3`.

### 5.3 Relatório de uso
```bash
node scripts/tier-usage-report.cjs
```

---

## Arquivos críticos a criar

```
C:\Users\moron\.local\bin\
├── .env                              (criado; NUNCA commitado)
├── .gitignore                        (criado se ausente)
├── memory/
│   └── tier-usage.jsonl              (log persistente)
├── lib/
│   ├── soft-failure.cjs
│   ├── ollama-client.cjs
│   ├── deepseek-client.cjs
│   ├── anthropic-client.cjs
│   ├── deepseek-verify.cjs
│   └── tiered-ask.cjs
└── scripts/
    └── tier-usage-report.cjs
```

---

## Regras rígidas durante execução

- Nunca logar as API keys após captura
- Nunca deletar `memory/tier-usage.jsonl` sem perguntar
- Nunca modificar a lista de hard-floor purposes sem perguntar
- Se Ollama não conseguir puxar o modelo (falta de disco), tentar variante menor e avisar usuário
- Se um probe de tier falhar, logar e continuar — o router degrada com graciosidade
