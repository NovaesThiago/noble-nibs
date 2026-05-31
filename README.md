# Noble Nibs ☕ — Loja de Grãos de Café (Flutter)

App mobile de e-commerce para venda de **grãos de café especiais**, com Clean Architecture,
Riverpod, Material 3 e uma estética "specialty coffee" (creme / espresso / caramelo).

> Estética: fontes **Fraunces** + **Hanken Grotesk**; paleta `#FAF0E6` / `#73481E` / `#D19F6C`;
> motivo de grãos via `CustomPainter`.

## Stack
- **Flutter** (Material 3) · **Dart 3.5+**
- **Riverpod 2** (DI + estado) · **go_router** (navegação com shell de abas)
- **fpdart** (`Either<Failure, T>`) · dados **mock** (JSON local), prontos para backend real
- `flutter_secure_storage`, `shared_preferences`, `flutter_jailbreak_detection`, `local_auth`

## Como rodar
```bash
flutter pub get          # com generate:true, também prepara o l10n
flutter analyze          # lints estritos (very_good_analysis)
flutter test             # unit + widget
flutter run              # emulador/dispositivo
```

## Arquitetura
Clean Architecture **feature-first** (`data` → `domain` ← `presentation`). Estrutura em `lib/`:
- `core/` — tema, design system (`widgets/`), erros, storage, segurança, utils, providers globais
- `features/<feature>/{data,domain,presentation}` — catálogo, detalhe, carrinho, auth, checkout,
  pedidos, favoritos, perfil, onboarding, splash
- `app/` — `app.dart` (MaterialApp), `router/` (go_router + shell), `shell/` (bottom nav)
- `shared/domain/entities` — entidades compartilhadas (Product, Money, Cart, Order...)

## Fluxo do app
Splash → (Onboarding 1º acesso) → Welcome → (Login / Cadastro / Visitante) →
**Shell**[Loja · Favoritos · Carrinho · Perfil] → Detalhe → Carrinho → Checkout (guard de sessão)
→ Sucesso → Pedidos → Detalhe → Recomprar.

## Segurança (defesa em profundidade no cliente)
- [x] Tokens **somente** em `SecureStorageService` (Keychain/Keystore), nunca em prefs/logs
- [x] Logout limpa **todo** o secure storage (`clearAll`)
- [x] Validação de **toda** entrada do usuário (`core/utils/validators.dart`)
- [x] Detecção de **root/jailbreak** no boot (`SecurityService`)
- [x] Captura global de erros (`runZonedGuarded` + `FlutterError.onError`)
- [x] Logs **desativados em release** (`app_logger.dart`)
- [ ] Certificate pinning (estrutura pronta no `DioClient` — ativar com backend real)
- [ ] `FLAG_SECURE` em telas sensíveis (pagamento) — adicionar na integração nativa
- [ ] Biometria no login (`local_auth` no pubspec — wiring opcional)

### Build de release (hardening)
```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

## Pontos de contribuição abertos (regras de negócio)
Procure por `TODO(voce)`:
- `core/theme/app_theme.dart` → `_darkScheme()` — mapa de cores do tema escuro
- `features/catalog/.../catalog_providers.dart` → `_sortProducts()` — critério de "Destaques"
- `features/cart/.../cart_controller.dart` → `_guardStock()` — política de estoque ao adicionar
- `features/checkout/.../checkout_providers.dart` → `shippingProvider` — política de frete

## Estado atual
Dados **mock** em memória (catálogo via JSON; carrinho/auth/pedidos/favoritos via `Notifier`).
Trocar para backend real = substituir a camada `data` (datasources/repos) — as camadas
`domain`/`presentation` não mudam.

## Licença

O **código-fonte** está sob a licença [MIT](./LICENSE).

⚠️ A marca **"Noble Nibs"**, a **logo** e a **identidade visual** **não** estão cobertas
pela MIT — são de propriedade exclusiva do autor, com todos os direitos reservados.
Veja [TRADEMARKS.md](./TRADEMARKS.md). Ao reutilizar o código, substitua a marca, a logo
e as imagens da pasta `assets/` por elementos próprios.
