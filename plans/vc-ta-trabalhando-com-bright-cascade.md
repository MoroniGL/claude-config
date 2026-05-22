# Plano: JobFlow Mobile (iOS + Android)

## Context

O usuário tem o **JobFlow** — plataforma Next.js 16 + Supabase para gestão de trabalhos/empregos de autônomos UK, com integração WhatsApp via webhook. O projeto vive em `C:\Users\moron\.local\bin\jobflow`.

Objetivo: criar um **app móvel** (iPhone + Android) que replique **todas as funcionalidades** do JobFlow web e consuma a integração existente com o **bot WhatsApp** (`C:\Users\moron\.local\bin\src\whatsapp-bot-jm`), que já envia leads via `POST /api/bot/booking`.

Decisão: criar `jobflow-mobile` em React Native + Expo, manter o backend Next.js intocado, e consumir as mesmas APIs e o mesmo Supabase. O bot WhatsApp continua funcionando sem qualquer mudança.

## Decisões consolidadas (pelo usuário)

| Tópico | Decisão |
|---|---|
| Stack mobile | React Native + Expo (Expo Router, TypeScript) |
| Plataformas | iPhone + Android |
| Backend | Mantém Next.js do JobFlow (web e mobile consomem mesma API) |
| WhatsApp | Ver/gerenciar jobs criados pelo bot (push + flag visual) |
| Escopo MVP | Tudo do JobFlow (Dashboard, Jobs, Finances, Registro IA, Team, Settings, Worker) |
| Push | Expo Push Notifications |
| Localização | `C:\Users\moron\.local\bin\jobflow-mobile\` (repo separado) |

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                      Supabase (Postgres)                     │
│         companies · profiles · jobs · job_assignments        │
│         expenses · time_logs · invites                       │
└───────────────────┬─────────────────────────┬────────────────┘
                    │                         │
        ┌───────────▼──────────┐    ┌─────────▼─────────┐
        │   JobFlow Web        │    │  JobFlow Mobile   │
        │   (Next.js 16)       │    │  (Expo + RN)      │
        │   - Dashboard SSR    │    │  - SwiftUI-like   │
        │   - Server Actions   │    │  - Push notifs    │
        │   - /api/bot/booking │    │  - Auth biometria │
        └───────────┬──────────┘    └───────────────────┘
                    │
           ┌────────▼────────┐
           │ whatsapp-bot-jm │  envia POST /api/bot/booking
           │ (whatsapp-web)  │  → cria job no Supabase
           └─────────────────┘
```

**Princípio:** mobile não tem backend próprio. Consome `supabase-js` direto para CRUD e o backend Next.js do JobFlow para endpoints específicos (análise IA do Registro, geração de bot_token).

## Estrutura do projeto `jobflow-mobile`

```
jobflow-mobile/
├── app/                          # Expo Router (file-based)
│   ├── (auth)/
│   │   ├── login.tsx
│   │   ├── register.tsx
│   │   ├── forgot-password.tsx
│   │   └── _layout.tsx
│   ├── (tabs)/                   # Bottom tabs (área autenticada)
│   │   ├── _layout.tsx
│   │   ├── dashboard.tsx
│   │   ├── jobs/
│   │   │   ├── index.tsx         # lista jobs
│   │   │   ├── [id].tsx          # detalhe
│   │   │   └── new.tsx           # criar
│   │   ├── finances.tsx
│   │   └── settings.tsx
│   ├── registro/
│   │   ├── index.tsx
│   │   └── analyze.tsx           # chama API Next.js (IA)
│   ├── team/
│   │   ├── index.tsx
│   │   └── invite.tsx
│   ├── worker/                   # área do trabalhador
│   │   └── index.tsx
│   ├── onboarding.tsx
│   ├── invite/[token].tsx
│   └── _layout.tsx               # root, providers (Supabase, theme)
├── components/
│   ├── ui/                       # NativeBase ou Tamagui (alternativa shadcn)
│   ├── jobs/
│   │   ├── JobCard.tsx
│   │   └── JobForm.tsx
│   ├── dashboard/
│   │   ├── WeeklySummary.tsx
│   │   └── WeekTimeline.tsx
│   └── finances/
│       └── AnnualReport.tsx
├── lib/
│   ├── supabase.ts               # cliente RN com AsyncStorage
│   ├── types.ts                  # COPIA de jobflow/lib/types.ts
│   ├── utils.ts                  # COPIA de jobflow/lib/utils.ts
│   ├── api.ts                    # wrapper pra chamadas /api/* do JobFlow
│   ├── push.ts                   # registro push token, handlers
│   └── theme.ts                  # cores, espaçamentos
├── hooks/
│   ├── useAuth.ts
│   ├── useJobs.ts
│   ├── useExpenses.ts
│   └── usePushNotifications.ts
├── assets/                       # ícones, splash, fontes
├── app.json                      # config Expo (ícones, splash, permissões)
├── eas.json                      # config EAS Build
├── babel.config.js
├── tsconfig.json
├── package.json
└── .env.local                    # SUPABASE_URL, SUPABASE_ANON_KEY, JOBFLOW_API_URL
```

## Mapeamento JobFlow Web → Mobile

| JobFlow Web (origem) | jobflow-mobile (destino) | Estratégia |
|---|---|---|
| `app/(dashboard)/dashboard/page.tsx` | `app/(tabs)/dashboard.tsx` | Re-implementar UI; lógica do `lib/utils.ts` (getWeekDays, calculateJobTotal) copiada igual |
| `app/(dashboard)/jobs/page.tsx` + `components/jobs/*` | `app/(tabs)/jobs/*` + `components/jobs/*` | Mesma lógica, UI nativa (FlatList, Swipeable) |
| `app/(dashboard)/finances/page.tsx` | `app/(tabs)/finances.tsx` | Gráficos via `victory-native` ou `react-native-svg-charts` |
| `app/(dashboard)/registro/page.tsx` + `app/api/registro/analyze/route.ts` | `app/registro/*` | UI nativa; análise IA continua em endpoint Next.js, mobile chama via fetch |
| `app/(dashboard)/team/page.tsx` | `app/team/*` | Gestão de membros, convites via Supabase + endpoint `/invite/[token]` |
| `app/(dashboard)/settings/page.tsx` (bot WhatsApp em linhas 92-111, 220-323) | `app/(tabs)/settings.tsx` | Tela de config + seção bot WhatsApp (gerar/revogar token chamando `POST/DELETE /api/settings/bot-token`) |
| `app/(dashboard)/worker/*` | `app/worker/*` | View limitada para role=worker |
| `app/(auth)/*` | `app/(auth)/*` | Supabase Auth nativo no RN com `@supabase/supabase-js` + `AsyncStorage` |
| `lib/types.ts` | `lib/types.ts` | **Copiar literalmente** (Company, Profile, Job, Expense, TimeLog, UserRole, JobStatus) |
| `lib/utils.ts` | `lib/utils.ts` | **Copiar literalmente** funções puras |
| `lib/supabase/client.ts` | `lib/supabase.ts` | Adaptar para usar `AsyncStorage` em vez de cookies |
| `supabase/migrations/*.sql` | (não duplicar) | Mobile usa o **mesmo Supabase** do web |

## Integração WhatsApp no app

Bot WhatsApp **não muda**. Ele continua chamando `POST /api/bot/booking` no backend Next.js, que insere job no Supabase com nota `"Created by WhatsApp bot"`.

App mobile vai:

1. **Identificar visualmente** jobs vindos do bot — `components/jobs/JobCard.tsx` checa `job.notes?.includes('WhatsApp bot')` e mostra ícone WhatsApp verde.
2. **Push notification** quando bot cria job novo:
   - Criar trigger Postgres `notify_new_bot_job` em nova migration `supabase/migrations/007_bot_push.sql`
   - Edge Function `supabase/functions/send-bot-push` é acionada e chama Expo Push API
   - Mobile recebe push e abre direto o detalhe do job
3. **Configurar bot pela app** — tela em Settings reaproveita endpoints existentes:
   - `POST /api/settings/bot-token` (gera) — `app/api/settings/bot-token/route.ts:14-58`
   - `DELETE /api/settings/bot-token` (revoga) — `app/api/settings/bot-token/route.ts:61-93`

## Push Notifications (Expo)

**Setup:**
1. Instalar `expo-notifications` + `expo-device`
2. `lib/push.ts` registra token Expo no `profiles.expo_push_token` (nova coluna; criar `supabase/migrations/008_expo_push_token.sql`)
3. Permissões em `app.json`: `"ios.infoPlist.UIBackgroundModes": ["remote-notification"]`
4. Edge Function consulta `expo_push_token` da empresa do job criado e dispara via `https://exp.host/--/api/v2/push/send`

## Build & deploy

**Desenvolvimento:**
```bash
cd C:\Users\moron\.local\bin\jobflow-mobile
npx expo start                 # Expo Go no celular físico
npx expo run:ios               # se tiver Mac
npx expo run:android           # Android Studio
```

**Build de produção (EAS — não precisa Mac):**
```bash
npm install -g eas-cli
eas login
eas build:configure
eas build --platform ios       # gera .ipa para TestFlight/App Store
eas build --platform android   # gera .aab para Play Store
eas submit --platform ios      # envia para App Store Connect
eas submit --platform android  # envia para Play Console
```

**Pré-requisitos:**
- Conta Apple Developer ($99/ano) — usuário precisa ter
- Conta Google Play Console ($25 único) — usuário precisa ter
- Bundle ID iOS: `com.jobflow.app` (definir em `app.json`)

## Fases de implementação

### Fase 1 — Setup base (3-4 dias)
- `npx create-expo-app jobflow-mobile -t expo-template-blank-typescript`
- Configurar Expo Router, TypeScript strict, ESLint, Prettier
- Copiar `lib/types.ts`, `lib/utils.ts` do JobFlow
- Configurar Supabase client com `AsyncStorage`
- Configurar tema (cores, fontes — alinhadas ao JobFlow web)
- Setup EAS Build (`eas.json`)

### Fase 2 — Auth (3-4 dias)
- Telas `(auth)/login`, `register`, `forgot-password`, `reset-password`
- Hook `useAuth` com sessão persistida
- Deep link `invite/[token]` (chama `POST /invite/[token]` do JobFlow)
- Onboarding (criar empresa, similar a `app/onboarding/page.tsx` do web)

### Fase 3 — Dashboard + Jobs (5-7 dias)
- Tab Layout (5 tabs: Dashboard, Jobs, Finances, Settings, Worker)
- Dashboard: WeeklySummaryCards, WeekTimeline
- Jobs: lista (FlatList com filtros), detalhe, criar/editar, swipe-to-delete
- `JobCard` com badge WhatsApp para jobs do bot

### Fase 4 — Finances + Registro (4-6 dias)
- Finances: relatório anual, gráficos (`victory-native`)
- Registro: lista transações + tela "Analyze" que chama `POST /api/registro/analyze` no JobFlow
- Adicionar/editar despesas

### Fase 5 — Team + Settings (3-4 dias)
- Team: listar membros, gerar convites
- Settings: empresa (logo, tipo), AI provider/key, **bot WhatsApp** (token, status, métricas)
- Worker view (role-gated)

### Fase 6 — Push WhatsApp (2-3 dias)
- Migration `008_expo_push_token.sql` (coluna em `profiles`)
- `lib/push.ts` — registro de token, listeners
- Supabase Edge Function `send-bot-push`
- Migration `007_bot_push.sql` — trigger pós-insert em `jobs` com `notes LIKE '%WhatsApp bot%'`
- Testar fluxo end-to-end (bot → API → trigger → Edge Function → Expo Push → app)

### Fase 7 — Polish + builds (3-5 dias)
- Ícone do app + splash screen (alinhar identidade JobFlow)
- Testar em iPhone físico via TestFlight (build EAS)
- Testar em Android físico (APK interno)
- Acessibilidade (VoiceOver/TalkBack), dark mode
- Privacy policy + termos (exigência App Store)
- Submeter para revisão Apple e Google

**Total estimado: 4-5 semanas de trabalho ativo.**

## Arquivos críticos para reaproveitar (paths absolutos)

**Copiar literalmente:**
- `C:\Users\moron\.local\bin\jobflow\lib\types.ts` → `jobflow-mobile/lib/types.ts`
- `C:\Users\moron\.local\bin\jobflow\lib\utils.ts` → `jobflow-mobile/lib/utils.ts`

**Adaptar (web → RN):**
- `C:\Users\moron\.local\bin\jobflow\lib\supabase\client.ts` (cookies → AsyncStorage)
- `C:\Users\moron\.local\bin\jobflow\app\(dashboard)\jobs\page.tsx` (Server Component → useEffect+useState)
- `C:\Users\moron\.local\bin\jobflow\components\jobs\job-card.tsx` (HTML → View/Pressable)
- `C:\Users\moron\.local\bin\jobflow\components\dashboard\weekly-summary-cards.tsx`
- `C:\Users\moron\.local\bin\jobflow\app\(dashboard)\settings\page.tsx` (linhas 92-111 e 220-323 — bot WhatsApp)

**Manter intocados (consumidos pelo mobile via fetch):**
- `C:\Users\moron\.local\bin\jobflow\app\api\bot\booking\route.ts:12-80`
- `C:\Users\moron\.local\bin\jobflow\app\api\settings\bot-token\route.ts:14-93`
- `C:\Users\moron\.local\bin\jobflow\app\api\registro\analyze\route.ts:7-89`

**Bot WhatsApp (sem alteração):**
- `C:\Users\moron\.local\bin\src\whatsapp-bot-jm\src\bot.js:99` (continua chamando JobFlow)
- `C:\Users\moron\.local\bin\src\whatsapp-bot-jm\src\booking.js:21`

**Novas migrations a criar no Supabase:**
- `C:\Users\moron\.local\bin\jobflow\supabase\migrations\007_bot_push.sql` (trigger push)
- `C:\Users\moron\.local\bin\jobflow\supabase\migrations\008_expo_push_token.sql` (coluna profiles)

## Verificação (como testar end-to-end)

**Após cada fase:**
```bash
cd C:\Users\moron\.local\bin\jobflow-mobile
npx expo start                  # rodar em Expo Go no celular físico
```

**Testes funcionais MVP:**

1. **Auth**: Cadastrar conta nova → confirmar email → fazer login → ver dashboard.
2. **Jobs CRUD**: Criar job pelo app → confirmar que aparece no JobFlow web → editar status no web → confirmar atualização no app (em até 30s ou refresh).
3. **WhatsApp end-to-end**:
   - Iniciar `whatsapp-bot-jm` localmente (`cd C:\Users\moron\.local\bin\src\whatsapp-bot-jm && npm start`)
   - Enviar mensagem ao bot via WhatsApp pessoal
   - Bot escala lead → POST `/api/bot/booking` → job criado no Supabase
   - **App deve receber push notification** e abrir detalhe ao tocar
   - Job deve aparecer com ícone WhatsApp na lista
4. **Settings bot token**: Gerar token novo no app → atualizar `JOBFLOW_BOT_TOKEN` no `.env` do bot → reiniciar bot → confirmar que continua funcionando. Revogar token → confirmar 401 no bot.
5. **Registro IA**: Adicionar transações → tela Analyze → confirmar que análise (Claude/Gemini) chega.
6. **Multi-device**: Fazer ação no app iPhone → ver atualizar no JobFlow web em tempo real (via Supabase Realtime, fase 7).

**Build de release:**
```bash
eas build --platform ios --profile preview        # TestFlight interno
eas build --platform android --profile preview    # APK interno
```

**Pré-submissão App Store:**
- App Privacy form preenchido
- Screenshots iPhone 6.7" e 6.5" (obrigatório)
- App icon 1024x1024
- Política de privacidade hospedada (página `/privacy` no JobFlow web)
- TestFlight com pelo menos 5 testers internos por 1-2 semanas

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Apple rejeita por ser "muito similar ao web" | Usar componentes nativos (gestos, haptics, navegação iOS), funcionalidades exclusivas mobile (push, biometria, câmera) |
| Bot WhatsApp para de funcionar (não relacionado ao app) | App **não toca no bot**. Risco isolado. |
| Divergência de tipos entre web e mobile ao longo do tempo | A médio prazo, considerar migrar para monorepo (Turborepo) com `packages/types` compartilhado |
| Performance de listas grandes (Jobs, Finances) | Usar `FlashList` (Shopify) em vez de `FlatList` para 1000+ items |
| AI keys expostas no app | Manter chamadas IA no backend Next.js (`/api/registro/analyze`). App **nunca** carrega `ai_api_key` da empresa |

## Observação final

Este plano **não altera** o JobFlow web nem o bot WhatsApp existentes. Apenas:
- Adiciona o repositório novo `jobflow-mobile`
- Cria 2 migrations Supabase (push tokens)
- Cria 1 Supabase Edge Function (`send-bot-push`)

O risco para sistemas em produção é **mínimo**.
