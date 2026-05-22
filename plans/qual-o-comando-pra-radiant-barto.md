# Plano: Corrigir exibição de fotos de perfil no Commu

## Contexto

O `avatar_url` é salvo corretamente no Supabase e o upload funciona, mas 3 telas nunca renderizam a imagem — mostram apenas a inicial do nome em um círculo. O único lugar que funciona é o perfil próprio do usuário.

## Causa raiz

| Arquivo | Problema |
|---------|----------|
| `apps/mobile/app/(tabs)/messages/index.tsx` | `avatar_url` está na query mas nunca é usado no JSX |
| `apps/mobile/app/messages/[id].tsx` | `avatar_url` não está nem na query |
| `apps/mobile/app/profile/[id].tsx` | `avatar_url` está na query mas nunca é usado no JSX |

## Abordagem

### 1. Criar componente `Avatar` reutilizável
**Arquivo novo:** `apps/mobile/components/Avatar.tsx`

Componente simples que:
- Recebe `uri: string | null`, `name: string`, `size: number`
- Se `uri` existe → renderiza `<Image>` com `expo-image`
- Se não → renderiza círculo com inicial (comportamento atual)
- Estilo teal (`#00675e`) consistente com o design system

### 2. Corrigir `messages/index.tsx` (lista de conversas)
- A query já inclui `avatar_url` — nenhuma mudança no fetch
- Substituir o bloco de inicial (linhas ~200-213) pelo `<Avatar uri={other?.avatar_url} name={other?.name} size={48} />`

### 3. Corrigir `messages/[id].tsx` (conversa individual)
- Adicionar `avatar_url` nas duas foreign key joins (linhas 37-38):
  ```
  buyer:profiles!conversations_buyer_id_fkey(id, name, avatar_url),
  seller:profiles!conversations_seller_id_fkey(id, name, avatar_url)
  ```
- Localizar onde o nome/avatar do outro usuário é exibido no header e usar `<Avatar>`

### 4. Corrigir `profile/[id].tsx` (perfil público)
- A query já inclui `avatar_url` — nenhuma mudança no fetch
- Substituir o bloco de inicial (linhas ~131-133) pelo `<Avatar uri={profile?.avatar_url} name={profile?.name} size={80} />`

## Arquivos a modificar

1. **CRIAR:** `src/commu/apps/mobile/components/Avatar.tsx`
2. `src/commu/apps/mobile/app/(tabs)/messages/index.tsx` — linhas ~200-213
3. `src/commu/apps/mobile/app/messages/[id].tsx` — linhas 37-38 (query) + header
4. `src/commu/apps/mobile/app/profile/[id].tsx` — linhas ~131-133

## Verificação

1. Rodar o app: `cd src/commu/apps/mobile && npx expo start`
2. Fazer login com usuário que tem foto de perfil
3. Verificar que avatar aparece na lista de conversas
4. Abrir uma conversa e verificar avatar no header
5. Acessar perfil público de outro usuário e verificar foto
