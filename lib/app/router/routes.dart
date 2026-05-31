/// Caminhos de rota como constantes — evita strings mágicas espalhadas.
abstract final class Routes {
  // Fora do shell
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const addresses = '/addresses';
  static const security = '/security';
  static const about = '/about';

  // Abas do shell (bottom nav)
  static const catalog = '/catalog';
  static const favorites = '/favorites';
  static const cart = '/cart';
  static const profile = '/profile';

  // Rotas com parâmetro
  static const product = '/product/:id';
  static String productPath(String id) => '/product/$id';

  static const order = '/order/:id';
  static String orderPath(String id) => '/order/$id';

  static const checkoutSuccess = '/checkout/success/:id';
  static String checkoutSuccessPath(String id) => '/checkout/success/$id';
}
