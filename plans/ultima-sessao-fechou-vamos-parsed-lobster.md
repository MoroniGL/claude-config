# Redesign Completo — Landing Page commu.cloud

## Contexto
A landing page atual (`apps/admin/app/page.tsx`) foi construída na última sessão mas tem bugs e seções incompletas. O usuário quer um redesign completo: layout mais impactante, novas seções, correção de bugs.

**Bugs existentes:**
- Linha 172: `<p className={...} />` vazia — tag órfã sem conteúdo
- Linha 53: ícone `ios` não é válido no Material Symbols — não renderiza nada
- Links do nav (`#`) sem IDs nos sections — ancoragem não funciona

---

## Arquivo a modificar

- `C:\Users\moron\.local\bin\src\commu\apps\admin\app\page.tsx` — reescrita completa

---

## Design System (do tailwind.config.ts)

| Token | Valor |
|-------|-------|
| Primário | `#005c55` |
| Primário container | `#0f766e` |
| Fixed teal | `#9cf2e8` / `#6df5e1` |
| Terciário (amber) | `#734700` / `#ffddb8` |
| Surface | `#f9f9ff` |
| On-surface | `#151c27` |
| On-surface-variant | `#3e4947` |
| Fontes | Plus Jakarta Sans (headings) + Inter (body) |

Regras do design system: sem bordas 1px, pill buttons, border-radius 16-24px nos cards, tonal layering.

---

## Estrutura do Redesign (10 seções)

### 1. Nav
- Logo "Commu" + links ancorados: `#marketplace`, `#comunidade`, `#segurança`, `#download`
- Botão "Entrar" (`/login`) + botão pill "Baixar o App" (`#download`)
- Mobile: links ocultos (sem hambúrguer — Server Component)

### 2. Hero
- Badge pill: "Lançando em Liverpool 🇧🇷"
- H1 grande: "O marketplace da comunidade brasileira no UK"
- Subtexto
- 2 botões: "App Store" + "Google Play" (ícone `phone_iphone` e `play_circle` do Material Symbols)
- Mockup visual: card de telefone com flag e logo, floating card "+500 membros ativos"
- Floating badge: "✓ Verificação de identidade"

### 3. Categorias (`id="marketplace"`)
- Grid 2×3 de categorias com emojis grandes + nome + breve descrição
- Categorias: 🛍️ Compra e Venda, 🎁 Doações, 💼 Empregos, 🔧 Serviços, 🍲 Comida Caseira, 🏠 Aluguel/Imóveis

### 4. Números (barra de stats)
- 3 números: "500+ Membros", "1.200+ Anúncios", "1 Cidade (e crescendo)"
- Fundo teal suave com números grandes em destaque

### 5. Como funciona
- 3 passos redesenhados com círculos numerados + ícone grande + linha conectora horizontal
- Melhor tipografia e espaçamento

### 6. Segurança (`id="segurança"`)
- Corrige o bug da `<p>` vazia
- 4 cards de trust signals com ícone colorido (FILL=1) + título + descrição
- Texto lateral melhorado

### 7. Depoimentos (`id="comunidade"`)
- 3 cards de testemunho de membros fictícios (realistas)
- Avatar emoji + nome + cidade + quote
- Fundo `surface-container-low`

### 8. CTA de Download (`id="download"`)
- Seção grande com fundo teal escuro
- H2: "Faça parte da comunidade"
- 2 botões de download grandes
- Subtext: "Grátis · Liverpool · iOS & Android"

### 9. Footer
- Logo + copyright
- Links: Sobre, Privacidade, Termos, Contato
- Ícones sociais: Instagram, WhatsApp (Material: `photo_camera`, `chat`)

---

## Implementação

Reescrever `page.tsx` inteiro. Manter como Server Component puro (sem `'use client'`).  
Estimativa: ~380–450 linhas. Acima de 500 → extrair seção de depoimentos para `_Testimonials.tsx`.

---

## Verificação

1. `cd apps/admin && npm run build` — checar se compila sem erros TypeScript
2. `npm run dev` na porta 3001 — visualizar no browser
3. Checar no mobile: hero responsivo, botões CTA visíveis
4. Verificar que links de nav funcionam (âncoras)
5. Verificar ícones Material Symbols renderizando com FILL correto
