# Plano: Renomear /obrigado para /thankyou

## Contexto
A rota de confirmação de enquiry do site jmcleaning.uk está em `/obrigado` (português). O usuário quer trocar para `/thankyou` (inglês), alinhando com o idioma principal do site (UK).

## Arquivos a Modificar

### 1. Renomear pasta da rota Next.js
- **De:** `src/jm-cleaning-react/src/app/obrigado/`
- **Para:** `src/jm-cleaning-react/src/app/thankyou/`
- Ação: mover/renomear a pasta inteira (contém `page.tsx` e `ObrigadoClient.tsx`)

### 2. Renomear o componente client
- **De:** `src/app/thankyou/ObrigadoClient.tsx`
- **Para:** `src/app/thankyou/ThankYouClient.tsx`
- Atualizar o nome do componente interno de `ObrigadoClient` para `ThankYouClient`

### 3. Atualizar import em page.tsx
- **Arquivo:** `src/jm-cleaning-react/src/app/thankyou/page.tsx`
- Trocar `import ObrigadoClient from "./ObrigadoClient"` → `import ThankYouClient from "./ThankYouClient"`
- Trocar `<ObrigadoClient />` → `<ThankYouClient />`

### 4. Atualizar redirect em ContactForm.tsx
- **Arquivo:** `src/jm-cleaning-react/src/components/ContactForm.tsx` — linha 47
- Trocar `router.push("/obrigado")` → `router.push("/thankyou")`

### 5. Atualizar redirect em InstantQuoteCalculator.tsx
- **Arquivo:** `src/jm-cleaning-react/src/components/InstantQuoteCalculator.tsx` — linha 245
- Trocar `router.push("/obrigado")` → `router.push("/thankyou")`

## Verificação
1. Acessar `http://localhost:3000/thankyou` — deve renderizar a página de confirmação
2. Submeter o formulário de contato — deve redirecionar para `/thankyou`
3. Submeter o calculador de orçamento — deve redirecionar para `/thankyou`
4. Verificar que `/obrigado` retorna 404
