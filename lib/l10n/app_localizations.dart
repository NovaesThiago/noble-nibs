import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Noble Nibs'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia, {name}'**
  String homeGreeting(String name);

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar grãos, origem, torra...'**
  String get searchHint;

  /// No description provided for @categories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get categories;

  /// No description provided for @featured.
  ///
  /// In pt, this message translates to:
  /// **'Destaques'**
  String get featured;

  /// No description provided for @bestSellers.
  ///
  /// In pt, this message translates to:
  /// **'Mais vendidos'**
  String get bestSellers;

  /// No description provided for @addToCart.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao carrinho'**
  String get addToCart;

  /// No description provided for @selectWeight.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o peso'**
  String get selectWeight;

  /// No description provided for @selectGrind.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a moagem'**
  String get selectGrind;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @cartEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Seu carrinho está vazio'**
  String get cartEmpty;

  /// No description provided for @checkout.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar compra'**
  String get checkout;

  /// No description provided for @subtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In pt, this message translates to:
  /// **'Frete'**
  String get shipping;

  /// No description provided for @discount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @applyCoupon.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar cupom'**
  String get applyCoupon;

  /// No description provided for @orderPlaced.
  ///
  /// In pt, this message translates to:
  /// **'Pedido realizado com sucesso!'**
  String get orderPlaced;

  /// No description provided for @myOrders.
  ///
  /// In pt, this message translates to:
  /// **'Meus pedidos'**
  String get myOrders;

  /// No description provided for @favorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @errorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci a senha'**
  String get forgotPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In pt, this message translates to:
  /// **'Continuar como visitante'**
  String get continueAsGuest;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
