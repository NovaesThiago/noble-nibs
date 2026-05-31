import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Autenticação biométrica (Face ID / impressão digital) via `local_auth`.
///
/// Todas as chamadas são defensivas: em plataformas sem suporte (web, sem
/// hardware) retornam de forma segura, sem crashar.
class BiometricService {
  const BiometricService();

  /// `true` se o dispositivo tem biometria configurada/suportada.
  Future<bool> isAvailable() async {
    try {
      final auth = LocalAuthentication();
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Solicita autenticação biométrica. Retorna `true` se confirmada.
  Future<bool> authenticate(String reason) async {
    try {
      final auth = LocalAuthentication();
      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricServiceProvider =
    Provider<BiometricService>((ref) => const BiometricService());
