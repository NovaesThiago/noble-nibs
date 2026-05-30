import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazenamento seguro de segredos (Keychain no iOS / Keystore no Android).
///
/// Segurança: tokens/segredos vivem **somente** aqui, nunca em
/// `SharedPreferences` nem em logs. Todas as chamadas são defensivas
/// (try/catch) para degradar sem crashar em plataformas sem o plugin.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _kAuthToken = 'auth_token';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _kAuthToken, value: token);
    } catch (_) {
      // Falha de plataforma/plugin — não propaga (sem dados sensíveis em log).
    }
  }

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _kAuthToken);
    } catch (_) {
      return null;
    }
  }

  /// Limpa TUDO — chamado no logout (segurança).
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}

final secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());
