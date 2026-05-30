// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Noble Nibs';

  @override
  String homeGreeting(String name) {
    return 'Bom dia, $name';
  }

  @override
  String get searchHint => 'Buscar grãos, origem, torra...';

  @override
  String get categories => 'Categorias';

  @override
  String get featured => 'Destaques';

  @override
  String get bestSellers => 'Mais vendidos';

  @override
  String get addToCart => 'Adicionar ao carrinho';

  @override
  String get selectWeight => 'Selecione o peso';

  @override
  String get selectGrind => 'Selecione a moagem';

  @override
  String get description => 'Descrição';

  @override
  String get quantity => 'Quantidade';

  @override
  String get cartEmpty => 'Seu carrinho está vazio';

  @override
  String get checkout => 'Finalizar compra';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Frete';

  @override
  String get discount => 'Desconto';

  @override
  String get total => 'Total';

  @override
  String get applyCoupon => 'Aplicar cupom';

  @override
  String get orderPlaced => 'Pedido realizado com sucesso!';

  @override
  String get myOrders => 'Meus pedidos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get profile => 'Perfil';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get login => 'Entrar';

  @override
  String get register => 'Criar conta';

  @override
  String get forgotPassword => 'Esqueci a senha';

  @override
  String get continueAsGuest => 'Continuar como visitante';

  @override
  String get logout => 'Sair';
}
