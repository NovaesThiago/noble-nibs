import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checagens de integridade do dispositivo no cliente.
///
/// Política (configurável): no boot, detecta root/jailbreak. O app pode então
/// avisar o usuário e/ou bloquear fluxos sensíveis (pagamento). As chamadas são
/// defensivas para não crashar em plataformas sem o plugin (web/desktop/test).
class SecurityService {
  const SecurityService();

  /// `true` se o dispositivo aparenta estar com root/jailbreak.
  Future<bool> isDeviceCompromised() async {
    if (kIsWeb) return false;
    try {
      return await FlutterJailbreakDetection.jailbroken;
    } catch (_) {
      return false; // plugin indisponível → não bloqueia.
    }
  }
}

final securityServiceProvider =
    Provider<SecurityService>((ref) => const SecurityService());
