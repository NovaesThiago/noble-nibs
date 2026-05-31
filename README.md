# Noble Nibs ☕ — Loja de Grãos de Café (Flutter)

> App mobile de e-commerce **premium** para venda de **grãos de café especiais**, construído em **Flutter (Material 3)** com **Clean Architecture feature-first**, **Riverpod 2** e **go_router**, e uma estética *specialty coffee* (creme / espresso / caramelo) com fontes **Fraunces** + **Hanken Grotesk** e motivo de grãos desenhado via `CustomPainter`.

A camada de dados é **mock local (JSON)** e desacoplada — o app está pronto para trocar para um backend real substituindo apenas datasources/repositories, sem tocar em `domain`/`presentation`.

---

## Índice

- [Stack tecnológica](#stack-tecnológica)
- [Como rodar](#como-rodar)
- [Arquitetura](#arquitetura)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Inicialização (bootstrap)](#inicialização-bootstrap)
- [Camada `app/` — MaterialApp, rotas e shell](#camada-app--materialapp-rotas-e-shell)
- [Camada `core/` — infraestrutura transversal](#camada-core--infraestrutura-transversal)
  - [Design system (tema)](#design-system-tema)
  - [Widgets reutilizáveis](#widgets-reutilizáveis)
  - [Storage, segurança, erros, utils, providers](#storage-segurança-erros-utils-providers)
- [Entidades de domínio compartilhadas](#entidades-de-domínio-compartilhadas)
- [Features](#features)
- [Dados mock & assets](#dados-mock--assets)
- [Localização](#localização)
- [Testes](#testes)
- [Segurança no cliente](#segurança-defesa-em-profundidade-no-cliente)
- [Pontos de contribuição abertos](#pontos-de-contribuição-abertos-regras-de-negócio)
- [Licença & marca](#licença--marca)

---

## Stack tecnológica

| Categoria | Pacotes |
|---|---|
| **Estado / DI** | `flutter_riverpod` ^2.5 · `riverpod_annotation` ^2.3 (+ `riverpod_generator`) |
| **Navegação** | `go_router` ^14.2 (com `StatefulShellRoute` de abas) |
| **Modelos** | `freezed` ^2.5 · `json_serializable` ^6.8 · `json_annotation` |
| **Funcional / erros** | `fpdart` ^1.1 (`Either<Failure, T>`) |
| **Rede** (preparada) | `dio` ^5.5 · `pretty_dio_logger` |
| **Storage** | `flutter_secure_storage` ^9.2 · `shared_preferences` ^2.3 · `hive` ^2.2 |
| **UI** | `cached_network_image` · `flutter_svg` · `google_fonts` · `flutter_animate` · `shimmer` |
| **i18n** | `intl` ^0.20 (gen-l10n via `generate: true`) |
| **Segurança** | `local_auth` ^2.2 · `flutter_jailbreak_detection` ^1.10 |
| **Logging** | `logger` ^2.3 |
| **Dev / análise** | `build_runner` · `very_good_analysis` ^6.0 · `mocktail` |

**SDK:** Dart `>=3.5.0 <4.0.0`, Flutter `>=3.24.0` (canal `stable`). `useMaterial3: true`.

---

## Como rodar

```bash
flutter pub get          # com generate:true, também prepara o l10n
flutter analyze          # lints estritos (very_good_analysis)
flutter test             # unit + widget
flutter run              # emulador/dispositivo
```

Se editar entidades `freezed`/`json_serializable`, regenere com:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Arquitetura

**Clean Architecture feature-first** com direção de dependência `presentation → domain ← data`:

- **`domain`** — entidades, interfaces de repositório e *use cases*. Sem dependências de Flutter. Erros expressos como `Failure` (sealed) com `fpdart`.
- **`data`** — implementações de repositório e datasources. Lançam **exceptions** internas, que são convertidas em `Failure` na fronteira do repositório.
- **`presentation`** — controllers Riverpod (`Notifier`), páginas e widgets. **Capturam `Failure`** e renderizam estado (`AsyncValue`, loading/erro/vazio).

Como a `data` é isolada, dá para substituir `CatalogLocalDataSource` por um remoto, `AuthRepositoryImpl` mock por Supabase, ou `MockPaymentGateway` por Mercado Pago **sem alterar `domain`/`presentation`**.

### Fluxo do app

```
Splash → (Onboarding 1º acesso) → Welcome → (Login / Cadastro / Visitante) →
  Shell[ Loja · Favoritos · Carrinho · Perfil ]
     → Detalhe do produto → Carrinho → Checkout (guard de sessão)
     → Sucesso → Pedidos → Detalhe → Recomprar
```

---

## Estrutura de pastas

```
lib/
├── main.dart                  ← chama bootstrap(NobleNibsApp)
├── bootstrap.dart             ← init: locale, error handling, prefs, ProviderScope
├── app/
│   ├── app.dart               ← MaterialApp.router (tema, locale pt_BR, router)
│   ├── router/
│   │   ├── routes.dart        ← constantes de rotas + helpers de path
│   │   └── app_router.dart    ← GoRouter (shell de abas + rotas full-screen + guards)
│   └── shell/app_shell.dart   ← bottom nav (Loja/Favoritos/Carrinho/Perfil + badge)
├── core/
│   ├── theme/                 ← app_colors · app_typography · app_dimensions · app_theme
│   ├── widgets/               ← design system reutilizável (12 widgets)
│   ├── security/              ← security_service (root/jailbreak) · biometric_service
│   ├── storage/               ← secure_storage_service · prefs_service
│   ├── providers/             ← theme_mode_provider · app_flags_provider (onboarding)
│   ├── error/                 ← failures (sealed) · exceptions
│   └── utils/                 ← formatters · validators · app_logger
├── shared/domain/entities/    ← Product · Money · Cart · Order · User · Address · Category
├── features/<feature>/{domain,data,presentation}/
│   ├── splash · welcome · onboarding
│   ├── auth · catalog · product_detail
│   ├── cart · checkout · favorites · orders
│   └── addresses · profile · security · about
└── l10n/app_pt.arb            ← strings em pt-BR (infra para multi-idioma)
```

---

## Inicialização (bootstrap)

`lib/main.dart` apenas chama `bootstrap(() => const NobleNibsApp())`. Todo o init mora em **`lib/bootstrap.dart`**, dentro de `runZonedGuarded`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `initializeDateFormatting('pt_BR')` + `Intl.defaultLocale = 'pt_BR'`
3. `FlutterError.onError` → roteia erros do framework para o `logger` (desativado em release)
4. Resolve `SharedPreferences.getInstance()` no boot
5. `SecurityService().isDeviceCompromised()` — loga aviso se detectar root/jailbreak (**não bloqueia** o app, por design)
6. `ProviderScope` com override `sharedPreferencesProvider.overrideWithValue(prefs)`
7. O handler externo do `runZonedGuarded` captura erros não tratados → `logger.e`

---

## Camada `app/` — MaterialApp, rotas e shell

**`app.dart` (`NobleNibsApp`)** — `ConsumerWidget` que monta `MaterialApp.router`: `debugShowCheckedModeBanner: false`, temas `AppTheme.light`/`AppTheme.dark` com `themeMode` reativo de `themeModeProvider`, router de `goRouterProvider`, locale fixo `Locale('pt', 'BR')` e delegates de localização Material/Widgets/Cupertino.

**`routes.dart`** — constantes de path + helpers (`productPath(id)`, `orderPath(id)`, `checkoutSuccessPath(id)`):

| Rota | Path | Tipo |
|---|---|---|
| splash | `/` | inicial |
| onboarding | `/onboarding` | 1º acesso |
| welcome | `/welcome` | landing |
| login / register | `/login` · `/register` | auth |
| catalog | `/catalog` | shell tab 0 |
| favorites | `/favorites` | shell tab 1 |
| cart | `/cart` | shell tab 2 |
| profile | `/profile` | shell tab 3 |
| product | `/product/:id` | full-screen |
| checkout | `/checkout` | full-screen (guard) |
| checkoutSuccess | `/checkout/success/:id` | full-screen |
| orders / order | `/orders` · `/order/:id` | full-screen |
| addresses / security / about | `/addresses` · `/security` · `/about` | full-screen |

**`app_router.dart`** — `goRouterProvider` com `StatefulShellRoute.indexedStack` (4 branches que preservam estado/scroll entre abas) + rotas full-screen. Dois pontos-chave:

- **Guard de checkout** (`_goCheckout`): lê `authControllerProvider`; se `canCheckout` for `false` (Guest **ou** não autenticado), mostra SnackBar e empurra `/login`. Só o estado `Authenticated` passa.
- **Add-to-cart helper** (`_addToCart`): adiciona o produto (primeiro peso/moagem, qty 1) e mostra SnackBar com ação "Ver" → `/cart`.

**`app_shell.dart` (`AppShell`)** — `ConsumerWidget` em torno de `StatefulNavigationShell` com bottom nav (altura 68): **Loja** (`storefront`), **Favoritos** (`favorite`), **Carrinho** (com `_BadgeIcon` mostrando `cartCountProvider` num círculo caramelo) e **Perfil**. Indicador caramelo a 18%, selecionado em `coffeeDark`.

---

## Camada `core/` — infraestrutura transversal

### Design system (tema)

**`app_colors.dart`** — paleta completa:

| Token | Hex | Uso |
|---|---|---|
| `cream` | `#FAF0E6` | fundo claro principal (linho/creme) |
| `creamSoft` | `#F5EBDD` | superfície de card/sheet mais quente |
| `surface` | `#FFFFFF` | superfície neutra (campos, cards claros) |
| `coffeeDark` | `#73481E` | títulos, identidade da marca |
| `coffeeMid` | `#5A3A1A` | fundo escuro do card de produto |
| `espresso` | `#3E2A14` | scaffold do tema escuro |
| `caramel` | `#D19F6C` | **acento primário** — botões, chips ativos, CTAs |
| `caramelDeep` | `#C08A52` | variante pressionada do acento |
| `textPrimary` | `#2A1C10` | texto principal |
| `textSecondary` | `#8A7763` | texto secundário/mudo |
| `divider` | `#E7DCCB` | linhas divisórias |
| `success` / `warning` / `error` | `#4CAF50` / `#E0A800` / `#D9534F` | feedback |
| `star` | `#E0A800` | cor da estrela de avaliação |

Há uma **extensão sobre `BuildContext`** que entrega cores cientes do tema (claro/escuro): `context.ink`, `context.inkSoft`, `context.brandInk`, `context.card`, `context.chipBg`, `context.line`.

**`app_typography.dart`** — duas famílias via `google_fonts`: **Fraunces** (serifa editorial de display) e **Hanken Grotesk** (grotesca humanista para corpo/UI).

| Token | Fonte | Tamanho | Peso | Notas |
|---|---|---|---|---|
| `display` | Fraunces | 44 | w600 | height 1.02, ls -1 |
| `headline` | Fraunces | 28 | w600 | ls -0.5 |
| `titleLarge` | Fraunces | 20 | w600 | — |
| `body` | Hanken Grotesk | 14.5 | w400 | height 1.55 |
| `button` | Hanken Grotesk | 16 | w600 | ls 0.2 |
| `label` | Hanken Grotesk | 12 | w600 | ls 0.8 |
| `overline` | Hanken Grotesk | 11 | w700 | ls 2 · cor fixa `caramelDeep` |

**`app_dimensions.dart`** — tokens de espaçamento/raio/sombra: `AppSpacing` (grid 4pt: `xs 4 · sm 8 · md 16 · lg 24 · xl 32 · xxl 48`), `AppRadius` (`sm 12 · md 20 · lg 28 · pill 100`) e `AppShadows` (`card` e `soft`, com cor de sombra marrom-quente derivada de `coffeeDark`).

**`app_theme.dart`** — `AppTheme.light`/`AppTheme.dark` (Material 3, seed `caramel`). Scaffold `cream` (claro) / `espresso` (escuro); AppBar transparente; `ElevatedButton` caramelo (altura 56, raio `md`); chips e inputs em formato pill.

### Widgets reutilizáveis

`lib/core/widgets/` — o catálogo do design system:

- **`AppButton`** — `primary` (caramelo + haptic), `secondary` (borda `coffeeDark`), `ghost`. Suporta `isLoading` (spinner) e `icon`; `FittedBox(scaleDown)` evita overflow; `Semantics(button)`.
- **`AppTextField`** — campo pill com `label`/`hint`/`prefixIcon`/`validator`/`obscureText`; factory `.search`; flag `dense`.
- **`state_views.dart`** — `ProductGridLoading` (skeleton shimmer 2 colunas), `EmptyView` (ícone + mensagem + ação), `ErrorView` (ícone de erro + "Tentar novamente").
- **`ProductCard`** — card assinatura: fundo em gradiente escuro com um **disco circular de imagem "flutuando"** acima da borda; overlays de `RatingBadge`, coração de favorito e botão circular de adicionar; `Hero` na imagem. Apenas apresentacional.
- **`QuantityStepper`** — linha `− N +` em pill, com `min`/`max` e haptic.
- **`RatingBadge`** — pill com nota + `star_rounded` (`#E0A800`); flag `onDark`.
- **`CategoryChip`** — chip selecionável com `AnimatedContainer` (220ms); `Semantics(selected)`.
- **`PillSelector`** — grupo de pills single-select (peso/moagem) com `Wrap` + `AnimatedContainer`.
- **`CoffeeImage`** — imagem resiliente: `Image.asset` para `assets/...`, `CachedNetworkImage` para `http...`, e fallback pintado (gradiente caramelo + ícone de café) quando nulo/desconhecido.
- **`BeanPatternBackground`** — `CustomPainter` que desenha contornos de grãos de café espalhados com `Random` semeado (layout determinístico); usado em quase todas as telas.

### Storage, segurança, erros, utils, providers

- **`SecureStorageService`** — `flutter_secure_storage` (Android `encryptedSharedPreferences`, iOS `first_unlock`). Chave `auth_token`: `saveToken`/`readToken`/`clearAll` (no logout). Try/catch em tudo — nunca propaga erro de plataforma nem loga dado sensível.
- **`PrefsService`** — `shared_preferences`: `theme_mode`, `onboarding_seen`, `biometric_enabled`. `sharedPreferencesProvider` lança `UnimplementedError` se não for sobrescrito no bootstrap.
- **`SecurityService`** — wrapper de `FlutterJailbreakDetection` (retorna `false` na web/erro). **`BiometricService`** — wrapper de `local_auth` (`isAvailable`, `authenticate` com `stickyAuth`), sempre defensivo.
- **`failures.dart`** — `sealed class Failure` → `NetworkFailure`, `ServerFailure`, `CacheFailure`, `AuthFailure`, `ValidationFailure`, `UnknownFailure` (switch exaustivo na UI). **`exceptions.dart`** — `ServerException`/`CacheException`/`AuthException` (só na camada `data`).
- **`app_logger.dart`** — `logger` global, `Level.off` em release. **`formatters.dart`** — `date` (`"d 'de' MMM, y"` pt-BR), `weight` (`"250g"`/`"1kg"`). **`validators.dart`** — `email`, `password` (≥8, maiúscula+dígito+símbolo), `cep`, `phone`, `required`, `confirmPassword`.
- **Providers globais** — `themeModeProvider` (`Notifier<ThemeMode>`, persiste em prefs) e `onboardingSeenProvider` (`Notifier<bool>`, `markSeen()`).

---

## Entidades de domínio compartilhadas

`lib/shared/domain/entities/`:

- **`Money`** — value object guardado em **`int cents`** (sem bug de ponto flutuante). `Money.fromReais`, getter `reais`, operadores (`+ - * > <`), `formatted` (`NumberFormat.currency` pt-BR → "R$ 35,00"). Igualdade por `cents`.
- **`Product`** — `id`, `name`, `description`, `origin (Origin)`, `roast (RoastLevel)`, `grinds`, `weights`, `notes (TastingNotes)`, `rating`, `reviewCount`, `imageUrl`, `isFeatured`, `stock`. Getters `fromPrice` (menor preço entre os pesos) e `inStock`. Tipos auxiliares: `RoastLevel` (clara/média/escura), `GrindType` (grão/espresso/coado/prensa/moka), `WeightOption` (`grams` + `price`), `TastingNotes` (acidez/corpo/doçura 1–5 + descritores).
- **`Cart` / `CartItem`** — `CartItem` tem `lineId = "produto|gramas|moagem"`, `lineTotal = price × quantity`. `Cart` calcula `itemCount`, `subtotal`, `total`.
- **`Order`** — `items`, `status (OrderStatus)`, `createdAt`, `address`, `paymentLabel`, `subtotal`, `shipping`, `total`, `trackingCode?`. `OrderStatus`: placed/preparing/shipped/delivered/cancelled (com `step` para timeline).
- **`User`** — `id`, `name`, `email`, `photoUrl?`, getter `initials`.
- **`Address`** — `label`, `street`, `number`, `complement?`, `district`, `city`, `state`, `cep`, `isDefault`; getter `oneLine`.
- **`Category`** — `id`, `name`, `type (CategoryType: all/origin/roast/grind/special)`.

---

## Features

| Feature | Camadas | Destaques |
|---|---|---|
| **splash** | presentation | timer 2600ms → welcome; logo com glow pulsante + grãos flutuantes animados (`flutter_animate`) |
| **welcome** | presentation | hero do pacote, CTAs "Explorar o catálogo" / "Já tenho conta", entradas escalonadas |
| **onboarding** | presentation | `PageView` de 3 slides; "Começar" chama `onboardingSeenProvider.markSeen()` e persiste |
| **auth** | domain + data + presentation | `AuthRepository` (mock 900ms); estado **sealed** `AuthState` = `Unauthenticated`/`Guest`/`Authenticated`; `canCheckout` só em `Authenticated`; sessão salva em secure storage; `continueAsGuest()` |
| **catalog** | domain (use cases) + data + presentation | `CatalogLocalDataSource` lê `assets/mock/*.json` (700ms); providers `productsProvider`, `selectedCategoryProvider`, `searchQueryProvider`, `sortOrderProvider` e o derivado `filteredProductsProvider` (filtro por categoria/busca + ordenação); header reativo que colapsa ao rolar; pull-to-refresh |
| **product_detail** | presentation | `productByIdProvider` (resolve do cache, sem nova rede); seleção local de peso/moagem/quantidade; `PillSelector`; `TastingNotesView`; botão "Adicionar · {total}" com preço dinâmico; `Hero` na imagem |
| **cart** | presentation | `CartController` (`Notifier<Cart>`): `add` faz merge por `lineId`, `setQuantity`, `remove`, `clear`, `_guardStock` (clamp `[1, stock]`); `cartCountProvider` com `.select`; swipe-to-delete |
| **checkout** | domain + data + presentation | `PaymentGateway` abstrato + `MockPaymentGateway` (1400ms); `PaymentMethod` (pix/crédito); `DeliveryOption` (padrão/expressa); `shippingProvider` (frete grátis ≥ R$150); `CheckoutController` cria `Order` e limpa o carrinho |
| **favorites** | presentation | `FavoritesController` (`Notifier<Set<String>>`, toggle); `favoriteProductsProvider` deriva do catálogo |
| **orders** | presentation | `OrdersController` (lista em memória); listagem + detalhe + "Recomprar" |
| **addresses** | presentation | lista de endereços (`addressesControllerProvider`) |
| **profile** | presentation | avatar com `initials`, seletor de tema (Light/Dark/System), menu (Pedidos/Endereços/Segurança/Sobre), "Sair" só quando autenticado |
| **security** | presentation | toggle de biometria (`biometricEnabledProvider` + `biometricAvailableProvider`) |
| **about** | presentation | página informativa sobre a marca |

---

## Dados mock & assets

**`assets/mock/products.json`** — 8 produtos. Preços em **centavos** dentro de `WeightOption`. Exemplos:

| ID | Nome | Origem | Torra | Nota | Estoque | Destaque |
|---|---|---|---|---|---|---|
| `bourbon-amarelo-minas` | Bourbon Amarelo | Sul de Minas (BR) | média | 4.7 | 42 | ✅ |
| `yirgacheffe-etiopia` | Yirgacheffe | Yirgacheffe (ET) | clara | 4.9 | 18 | ✅ |
| `geisha-panama` | Geisha | Boquete (PA) | clara | 5.0 | 6 | ✅ |
| `espresso-tradicional` | Espresso da Casa | Blend (BR) | escura | 4.5 | 65 | ✅ |
| `huila-colombia` | Huila Supremo | Huila (CO) | média | 4.6 | 30 | — |
| `antigua-guatemala` | Antigua | Antigua (GT) | média | 4.7 | 12 | — |
| `sidama-etiopia` | Sidama Natural | Sidama (ET) | clara | 4.8 | 15 | — |
| `cerrado-descafeinado` | Cerrado Descafeinado | Cerrado (BR) | média | 4.3 | 24 | — |

Cada produto tem `notes` (acidez/corpo/doçura 1–5 + descritores como "Caramelo", "Jasmim", "Chocolate amargo") e `grinds` (grão inteiro, espresso, coado/V60, prensa, moka).

**`assets/mock/categories.json`** — 7 categorias: `Todos`, `Torra clara/média/escura`, `Brasil`, `Etiópia`, `Destaques`.

**`assets/images/`** — `NobleNibs-logo.png` (splash), `pacote-noble-nibs.png` (hero da welcome), `torra-clara/media/escura.jpg` e `mesclado-3torras.jpg` (atribuídas automaticamente por nível de torra no datasource).

---

## Localização

`lib/l10n/app_pt.arb` (`@@locale: "pt"`) com ~34 chaves (`appTitle`, `homeGreeting` com placeholder `{name}`, `addToCart`, `selectWeight`, `selectGrind`, `checkout`, `subtotal`, `shipping`, `total`, `myOrders`, `login`, `continueAsGuest`, ...). A maioria das strings hoje está inline em PT no código; a infra ARB (`generate: true`) já está pronta para multi-idioma.

---

## Testes

| Arquivo | Cobre |
|---|---|
| `test/unit/money_test.dart` | aritmética em centavos, `fromReais`, comparação, igualdade, `formatted` |
| `test/unit/cart_controller_test.dart` | merge de variante idêntica (qty somada), `_guardStock` (clamp ao estoque), `remove` esvazia |
| `test/unit/validators_test.dart` | `email`, `password` (regras), `cep` |
| `test/widget/app_button_test.dart` | renderiza label, dispara `onPressed`, mostra spinner em `isLoading`, não dá overflow com label longo |
| `test/widget/product_card_overflow_test.dart` | `ProductCard` em grid 2 colunas não estoura com nome longo (`takeException() == null`) |

---

## Segurança (defesa em profundidade no cliente)

- [x] Tokens **somente** em `SecureStorageService` (Keychain/Keystore), nunca em prefs/logs
- [x] Logout limpa **todo** o secure storage (`clearAll`)
- [x] Validação de **toda** entrada do usuário (`core/utils/validators.dart`)
- [x] Detecção de **root/jailbreak** no boot (`SecurityService`, não bloqueante)
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

---

## Pontos de contribuição abertos (regras de negócio)

Procure por `TODO(voce)`:

- `core/theme/app_theme.dart` → `_darkScheme()` — mapa de cores do tema escuro
- `features/catalog/.../catalog_providers.dart` → `_sortProducts()` — critério de "Destaques"
- `features/cart/.../cart_controller.dart` → `_guardStock()` — política de estoque ao adicionar
- `features/checkout/.../checkout_providers.dart` → `shippingProvider` — política de frete

### Estado atual

Dados **mock** em memória (catálogo via JSON; carrinho/auth/pedidos/favoritos via `Notifier`). Trocar para backend real = substituir a camada `data` (datasources/repos) — `domain`/`presentation` não mudam.

---

## Licença & marca

O **código-fonte** está sob a licença [MIT](./LICENSE) — Copyright © 2026 Thiago Novaes.

⚠️ A marca **"Noble Nibs"**, a **logo** (`assets/images/NobleNibs-logo.png`), a arte do pacote e a **identidade visual** (paleta, tipografia, layout) **não** estão cobertas pela MIT — são de propriedade exclusiva do autor, com todos os direitos reservados. Veja [TRADEMARKS.md](./TRADEMARKS.md). Ao reutilizar o código, **substitua a marca, a logo e as imagens da pasta `assets/`** por elementos próprios.
