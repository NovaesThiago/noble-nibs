import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instância de [SharedPreferences].
///
/// Lançada por padrão; **sobrescrita em `bootstrap()`** com a instância real.
/// Isso permite que os controllers leiam prefs de forma síncrona.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescreva sharedPreferencesProvider em bootstrap()'),
);

/// Wrapper tipado sobre [SharedPreferences] para dados **não sensíveis**
/// (tema, flag de onboarding). Nada de tokens aqui — isso vai em
/// `SecureStorageService`.
class PrefsService {
  const PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kOnboardingSeen = 'onboarding_seen';

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String value) => _prefs.setString(_kThemeMode, value);

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);
}

final prefsServiceProvider = Provider<PrefsService>(
  (ref) => PrefsService(ref.watch(sharedPreferencesProvider)),
);
