# Plano: MeloBot — Discord Bot FiveM RP

## Contexto
Reconstrução completa do `melo-bot/` do zero. O projeto atual (facção simples em JSON) será descartado. O novo bot é uma plataforma completa para organizações de GTA RP no FiveM: 22 comandos slash, painéis interativos, MongoDB, sistema de premium com chaves, logs detalhados e multi-guild.

**Stack:** Node.js + discord.js v14 + MongoDB + Mongoose + pdfkit

---

## Estrutura de Arquivos

```
melo-bot/
├── index.js                          # Entry point, carrega handlers e conecta DB
├── deploy.js                         # Registra slash commands no Discord
├── .env.example
├── package.json
├── docker-compose.yml
│
├── src/
│   ├── commands/
│   │   ├── gerenciamento/            # Cor amarela (#FFD700)
│   │   │   ├── anunciar.js
│   │   │   ├── pd.js
│   │   │   ├── promover.js
│   │   │   └── rebaixar.js
│   │   ├── configuracao/             # Cor azul (#0099FF)
│   │   │   ├── dashboard.js
│   │   │   ├── premium.js
│   │   │   └── resgatar.js
│   │   ├── desenvolvedor/            # Cor vermelha (#FF3333)
│   │   │   ├── gerar.js
│   │   │   └── resetar.js
│   │   ├── ranking/                  # Cor roxa (#9B59B6)
│   │   │   └── ranking.js
│   │   └── paineis/                  # Cor verde (#00CC44)
│   │       ├── registro.js
│   │       ├── farms.js
│   │       ├── admin_farm.js
│   │       ├── banco.js
│   │       ├── acao.js
│   │       ├── vendas.js
│   │       ├── hierarquia.js
│   │       ├── lavagem.js
│   │       ├── ausencia.js
│   │       ├── bau.js
│   │       ├── bau_lider.js
│   │       └── encomendas.js
│   │
│   ├── events/
│   │   ├── ready.js                  # Log de início + verificar trials expirados
│   │   ├── interactionCreate.js      # Roteador central (cmd/button/modal/select)
│   │   └── guildCreate.js            # Ativa trial de 48h ao entrar no servidor
│   │
│   ├── handlers/
│   │   ├── commandHandler.js         # Carrega arquivos de /commands dinamicamente
│   │   ├── buttonHandler.js          # Prefixo → módulo de painel
│   │   ├── modalHandler.js           # Prefixo → módulo de painel
│   │   ├── selectMenuHandler.js      # Prefixo → módulo de painel
│   │   └── cooldownHandler.js        # Map em memória por (userId, commandName)
│   │
│   ├── database/
│   │   ├── connection.js             # mongoose.connect com retry
│   │   └── models/
│   │       ├── Guild.js              # Config do servidor
│   │       ├── Member.js             # Membros registrados por guild
│   │       ├── Transaction.js        # Histórico do banco
│   │       ├── FarmRecord.js         # Registros de farm
│   │       ├── Absence.js            # Ausências
│   │       ├── Action.js             # Ações táticas
│   │       ├── Sale.js               # Vendas internas
│   │       ├── Inventory.js          # Baú coletivo
│   │       ├── Order.js              # Encomendas
│   │       └── PremiumKey.js         # Chaves de licença
│   │
│   ├── panels/                       # Lógica de cada painel separada
│   │   ├── registro/
│   │   │   ├── panel.js              # Embed + botões iniciais
│   │   │   ├── buttons.js            # Aprovar/Reprovar
│   │   │   └── modal.js              # Formulário de candidatura
│   │   ├── farms/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   ├── admin_farm/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── pdf.js                # Exportação PDF de relatório
│   │   ├── banco/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   ├── modal.js
│   │   │   └── pdf.js
│   │   ├── acao/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   ├── vendas/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   ├── hierarquia/
│   │   │   ├── panel.js
│   │   │   └── buttons.js
│   │   ├── lavagem/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   ├── modal.js
│   │   │   └── pdf.js
│   │   ├── ausencia/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   ├── bau/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   ├── bau_lider/
│   │   │   ├── panel.js
│   │   │   ├── buttons.js
│   │   │   └── modal.js
│   │   └── encomendas/
│   │       ├── panel.js
│   │       ├── buttons.js
│   │       └── modal.js
│   │
│   └── utils/
│       ├── embeds.js                 # Builders de embed por categoria/cor
│       ├── permissions.js            # checkPermission(interaction, type) → boolean
│       ├── logger.js                 # enviarLog(guild, tipo, embed)
│       ├── premium.js                # isPremium(guildId), checkFeature(guildId, feature)
│       ├── pdf.js                    # generatePDF(type, data) → Buffer
│       └── hierarchy.js              # getNextRole, getPrevRole baseado em config
```

---

## Modelos MongoDB

### Guild
```js
{
  guildId: String,          // Discord guild ID
  premium: {
    active: Boolean,
    plan: 'trial' | 'free' | 'paid',
    expiresAt: Date,
    key: String
  },
  config: {
    roles: {
      admin: String,        // roleId para administrador
      ban: String,          // roleId para aplicar PD
      promote: String,      // roleId para promover
      demote: String,       // roleId para rebaixar
      member: String,       // cargo atribuído ao aprovar registro
      leader: String        // cargo de líder (bau_lider)
    },
    channels: {
      logs: String,
      registro: String,
      farms: String,
      banco: String,
      acao: String,
      vendas: String,
      ausencia: String,
      bau: String,
      encomendas: String
    },
    hierarchy: [{ roleId: String, name: String, level: Number }],
    farm: { weeklyGoal: Number, types: [String] },
    wash: { rate: Number },   // taxa de lavagem em %
    bank: { hours: String }   // ex: "08:00-20:00"
  }
}
```

### Member
```js
{
  guildId, userId,
  nickname: String,         // nome in-game
  fivemId: String,
  recruiter: String,        // userId do recrutador
  joinDate: Date,
  currentRoleId: String,    // roleId atual na hierarquia
  status: 'ativo' | 'inativo' | 'pd'
}
```

### Transaction
```js
{
  guildId, userId,
  type: 'deposito' | 'saque' | 'lavagem',
  amount: Number,
  description: String,
  balanceAfter: Number,
  timestamp: Date
}
```

### FarmRecord
```js
{
  guildId, userId,
  type: String,             // tipo de farm
  quantity: Number,
  value: Number,
  week: String,             // "2025-W18" (ISO week)
  approved: Boolean,
  approvedBy: String,
  timestamp: Date
}
```

### Absence, Action, Sale, Inventory, Order, PremiumKey
(estruturas menores definidas no código conforme necessário)

---

## Sistema de Permissões

`src/utils/permissions.js` expõe `checkPermission(interaction, type)`:
- Carrega `guild.config.roles[type]` do DB
- Verifica se o membro tem o cargo configurado
- Comandos de desenvolvedor verificam `BOT_OWNER_IDS` no `.env`
- Retorna embed de erro padronizado se falhar

---

## Sistema de Premium

| Plano | Recursos |
|-------|---------|
| `trial` (48h auto) | Todos os painéis, sem PDF |
| `free` | Painéis básicos (registro, farm, banco), sem PDF |
| `paid` | Tudo: PDF, admin_farm, lavagem avançada, bau_lider |

Chaves geradas com `/gerar`, formato: `MELO-XXXX-XXXX-XXXX`

---

## Roteamento de Interações (customId)

Todos os customIds seguem o padrão `prefixo:dados`:
- Botões: `registro:aprovar:userId`, `banco:depositar`, `farm:meta:userId`
- Modais: `modal:registro`, `modal:banco:depositar`
- Select: `dashboard:config:cargos`

`interactionCreate.js` faz split no `:` e roteia para o handler correto.

---

## Comandos e Categorias

| # | Comando | Categoria | Cor |
|---|---------|-----------|-----|
| 1 | `/anunciar` | Gerenciamento | Amarelo |
| 2 | `/pd` | Gerenciamento | Amarelo |
| 3 | `/promover` | Gerenciamento | Amarelo |
| 4 | `/rebaixar` | Gerenciamento | Amarelo |
| 5 | `/dashboard` | Configuração | Azul |
| 6 | `/premium` | Configuração | Azul |
| 7 | `/resgatar` | Configuração | Azul |
| 8 | `/gerar` | Desenvolvedor | Vermelho |
| 9 | `/resetar` | Desenvolvedor | Vermelho |
| 10 | `/ranking recrutamento` | Ranking | Roxo |
| 11-22 | `/painel [tipo]` | Painéis | Verde |

---

## Implementação por Fases

### Fase 1 — Base
- Limpar `melo-bot/` completamente
- Criar `package.json` com deps: `discord.js`, `mongoose`, `dotenv`, `pdfkit`, `nanoid`
- `index.js`, `deploy.js`
- `database/connection.js`
- Todos os models MongoDB
- `handlers/commandHandler.js` (loader dinâmico)
- `events/ready.js`, `events/interactionCreate.js` (roteador central)
- `utils/embeds.js`, `utils/permissions.js`, `utils/logger.js`, `utils/premium.js`

### Fase 2 — Comandos de Gerenciamento + Config
- `/anunciar`, `/pd`, `/promover`, `/rebaixar`
- `/dashboard`, `/premium`, `/resgatar`
- `/gerar`, `/resetar`
- `events/guildCreate.js` (trial 48h)

### Fase 3 — Painéis Core
- `painel registro` (com aprovação por botão + DM)
- `painel banco` (depositar/sacar/saldo/histórico)
- `painel farms` + `painel admin_farm`
- `painel ausencia`

### Fase 4 — Painéis Avançados + PDF
- `painel acao`, `painel vendas`
- `painel hierarquia`, `painel lavagem`
- `painel bau`, `painel bau_lider`, `painel encomendas`
- PDF export para banco, farm, lavagem

### Fase 5 — Finishing
- `/ranking recrutamento`
- Cooldown handler
- `.env.example`, `docker-compose.yml`
- Testes manuais com `deploy.js`

---

## Verificação

1. `node deploy.js` — registra todos os 22 comandos sem erro
2. `node index.js` — bot online, conectado ao MongoDB
3. `/dashboard` — select menus funcionando, salva config no DB
4. `/resgatar <chave>` — ativa premium no servidor
5. `/painel registro` — embed aparece, botão abre modal, aprovação atribui cargo
6. `/painel banco` — depositar/sacar atualiza saldo em tempo real
7. `/pd @usuario motivo` — remove cargos da hierarquia + loga no canal
8. `/gerar free 3 5` — só owner do bot consegue; gera 5 chaves no embed
