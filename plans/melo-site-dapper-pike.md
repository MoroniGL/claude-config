# Plano: Corrigir redirect_uri inválido no Discord OAuth2 — melo-site

## Contexto

O `melo-site` (Next.js 15 + NextAuth v4) usa Discord OAuth2 para autenticação. O NextAuth constrói automaticamente o redirect URI como `{NEXTAUTH_URL}/api/auth/callback/discord`. O erro "redirect_uri invalid" ocorre porque a URL de produção na Vercel não está sincronizada em dois lugares: variável de ambiente `NEXTAUTH_URL` e o portal do Discord.

Nenhuma mudança de código é necessária — o arquivo `src/app/api/auth/[...nextauth]/route.js` está correto.

---

## Diagnóstico

| Local | Problema provável |
|-------|-------------------|
| Vercel → Environment Variables | `NEXTAUTH_URL` aponta para `localhost` ou não está definido |
| Discord Developer Portal | Redirect URI de produção não está cadastrado |

---

## Correções (sem alteração de código)

### Passo 1 — Descobrir a URL de produção

No terminal ou dashboard da Vercel:
```bash
# Via Vercel CLI
vercel ls
# ou verificar em vercel.com/dashboard → melo-site → Deployments → URL de produção
# Formato: https://melo-site-xxxx.vercel.app  ou domínio customizado
```

### Passo 2 — Atualizar `NEXTAUTH_URL` na Vercel

1. Acessar: vercel.com/dashboard → projeto **melo-site** → Settings → Environment Variables
2. Adicionar ou editar:
   ```
   NEXTAUTH_URL = https://SEU-DOMINIO.vercel.app
   ```
3. Marcar para os ambientes: **Production** (e Preview se quiser testar lá)
4. Salvar e fazer **redeploy** (Settings → Deployments → Redeploy, ou push novo commit)

### Passo 3 — Adicionar URI no Discord Developer Portal

1. Acessar: discord.com/developers/applications → selecionar a aplicação do melo
2. Menu: **OAuth2** → **General**
3. Em **Redirects**, adicionar:
   ```
   https://SEU-DOMINIO.vercel.app/api/auth/callback/discord
   ```
4. Salvar alterações (botão Save Changes)

### Passo 4 — Verificar demais variáveis na Vercel

Confirmar que estas também estão definidas:
```
DISCORD_CLIENT_ID     = (ID do app no Discord Developer Portal)
DISCORD_CLIENT_SECRET = (secret do app)
NEXTAUTH_SECRET       = (string aleatória, ex: gerada com `openssl rand -base64 32`)
MONGODB_URI           = (string de conexão MongoDB)
```

---

## Verificação

1. Após redeploy, abrir o site em produção
2. Clicar em "Entrar com Discord" no Navbar
3. Deve redirecionar ao Discord → autorizar → voltar ao dashboard sem erros
4. Verificar no console do browser que não há erros de CORS ou redirect

---

## Arquivos relevantes (somente leitura — nenhum precisa mudar)

- `melo-site/src/app/api/auth/[...nextauth]/route.js` — config NextAuth (correto)
- `melo-site/src/components/Navbar.js` — botão de login
- `melo-site/.env.example` — template das variáveis
