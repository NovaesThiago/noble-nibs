import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noble_nibs/app/router/routes.dart';
import 'package:noble_nibs/app/shell/app_shell.dart';
import 'package:noble_nibs/features/about/presentation/pages/about_page.dart';
import 'package:noble_nibs/features/addresses/presentation/pages/addresses_page.dart';
import 'package:noble_nibs/features/security/presentation/pages/security_page.dart';
import 'package:noble_nibs/features/auth/presentation/pages/login_page.dart';
import 'package:noble_nibs/features/auth/presentation/pages/register_page.dart';
import 'package:noble_nibs/features/auth/presentation/providers/auth_controller.dart';
import 'package:noble_nibs/features/cart/presentation/pages/cart_page.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/catalog/presentation/pages/catalog_page.dart';
import 'package:noble_nibs/features/checkout/presentation/pages/checkout_page.dart';
import 'package:noble_nibs/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:noble_nibs/features/favorites/presentation/pages/favorites_page.dart';
import 'package:noble_nibs/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:noble_nibs/features/orders/presentation/pages/order_detail_page.dart';
import 'package:noble_nibs/features/orders/presentation/pages/orders_page.dart';
import 'package:noble_nibs/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:noble_nibs/features/profile/presentation/pages/profile_page.dart';
import 'package:noble_nibs/features/splash/presentation/pages/splash_page.dart';
import 'package:noble_nibs/features/welcome/welcome_page.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Configuração de rotas (go_router) com `StatefulShellRoute` para as abas.
///
/// Splash → (Onboarding) → Welcome → (Login) → Shell[Loja|Favoritos|Carrinho|
/// Perfil]. Detalhe, checkout, pedidos e auth ficam fora do shell e cobrem as
/// abas ao serem empilhados. O checkout exige sessão (visitante → login).
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, _) => SplashPage(
          // Tela de iniciar → leva para a Welcome.
          onReady: () => context.go(Routes.welcome),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, _) => OnboardingPage(onDone: () => context.go(Routes.welcome)),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, _) => WelcomePage(
          onEnter: () => context.go(Routes.catalog),
          onLogin: () => context.push(Routes.login),
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, _) => LoginPage(
          onBack: () => context.pop(),
          onSuccess: () => context.go(Routes.catalog),
          onRegister: () => context.push(Routes.register),
          onGuest: () {
            ref.read(authControllerProvider.notifier).continueAsGuest();
            context.go(Routes.catalog);
          },
        ),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, _) => RegisterPage(
          onBack: () => context.pop(),
          onSuccess: () => context.go(Routes.catalog),
        ),
      ),

      // ---------------------- SHELL (abas) ----------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Aba 0 — Loja/Catálogo
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.catalog,
                builder: (context, _) => CatalogPage(
                  onOpenOrders: () => context.push(Routes.orders),
                  onTapProduct: (p) => context.push(Routes.productPath(p.id)),
                  onAddProduct: (p) => _addToCart(context, ref, p),
                ),
              ),
            ],
          ),
          // Aba 1 — Favoritos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favorites,
                builder: (context, _) => FavoritesPage(
                  onTapProduct: (p) => context.push(Routes.productPath(p.id)),
                  onAddProduct: (p) => _addToCart(context, ref, p),
                  onShop: () => context.go(Routes.catalog),
                ),
              ),
            ],
          ),
          // Aba 2 — Carrinho
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.cart,
                builder: (context, _) => CartPage(
                  onContinueShopping: () => context.go(Routes.catalog),
                  onCheckout: () => _goCheckout(context, ref),
                ),
              ),
            ],
          ),
          // Aba 3 — Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, _) => ProfilePage(
                  onOpenOrders: () => context.push(Routes.orders),
                  onLogin: () => context.push(Routes.login),
                  onLogout: () => context.go(Routes.welcome),
                  onOpenAddresses: () => context.push(Routes.addresses),
                  onOpenSecurity: () => context.push(Routes.security),
                  onOpenAbout: () => context.push(Routes.about),
                ),
              ),
            ],
          ),
        ],
      ),

      // ---------------------- Rotas full-screen ----------------------
      GoRoute(
        path: Routes.product,
        builder: (context, state) => ProductDetailPage(
          id: state.pathParameters['id']!,
          onBack: () => context.pop(),
          onOpenCart: () => context.go(Routes.cart),
        ),
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, _) => CheckoutPage(
          onBack: () => context.pop(),
          onSuccess: (orderId) =>
              context.pushReplacement(Routes.checkoutSuccessPath(orderId)),
        ),
      ),
      GoRoute(
        path: Routes.checkoutSuccess,
        builder: (context, state) => CheckoutSuccessPage(
          orderId: state.pathParameters['id']!,
          onViewOrder: () => context.go(Routes.orderPath(state.pathParameters['id']!)),
          onBackToShop: () => context.go(Routes.catalog),
        ),
      ),
      GoRoute(
        path: Routes.addresses,
        builder: (context, _) => AddressesPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.security,
        builder: (context, _) => SecurityPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.about,
        builder: (context, _) => AboutPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.orders,
        builder: (context, _) => OrdersPage(
          onBack: () => context.pop(),
          onShop: () => context.go(Routes.catalog),
          onOpenOrder: (orderId) => context.push(Routes.orderPath(orderId)),
        ),
      ),
      GoRoute(
        path: Routes.order,
        builder: (context, state) => OrderDetailPage(
          id: state.pathParameters['id']!,
          onBack: () => context.pop(),
          onReorder: () => context.go(Routes.cart),
        ),
      ),
    ],
  );
});

/// Adiciona a variante padrão ao carrinho com feedback.
void _addToCart(BuildContext context, Ref ref, Product product) {
  ref.read(cartControllerProvider.notifier).add(
        product,
        product.weights.first,
        product.grinds.first,
        1,
      );
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        action: SnackBarAction(label: 'Ver', onPressed: () => context.go(Routes.cart)),
      ),
    );
}

/// Guard de sessão para o checkout.
void _goCheckout(BuildContext context, Ref ref) {
  if (ref.read(authControllerProvider).canCheckout) {
    context.push(Routes.checkout);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entre na sua conta para finalizar a compra.')),
    );
    context.push(Routes.login);
  }
}
