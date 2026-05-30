import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:noble_nibs/core/security/security_service.dart';
import 'package:noble_nibs/core/storage/prefs_service.dart';
import 'package:noble_nibs/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inicialização do app dentro de uma zona protegida.
///
/// Responsável por: capturar erros não tratados, inicializar locale (pt-BR),
/// rodar checagens de segurança e injetar dependências assíncronas (prefs)
/// via override no [ProviderScope].
Future<void> bootstrap(Widget Function() builder) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Locale pt-BR (necessário para DateFormat com símbolos de data).
      await initializeDateFormatting('pt_BR');
      Intl.defaultLocale = 'pt_BR';

      // Funil de erros do framework → logger (desativado em release).
      FlutterError.onError = (details) {
        logger.e('FlutterError', error: details.exception, stackTrace: details.stack);
      };

      // Dependências assíncronas resolvidas uma vez no boot.
      final prefs = await SharedPreferences.getInstance();

      // Checagem de integridade (não bloqueia; apenas registra por ora).
      final compromised = await const SecurityService().isDeviceCompromised();
      if (compromised) {
        logger.w('Dispositivo com root/jailbreak detectado.');
      }

      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: builder(),
        ),
      );
    },
    (error, stack) => logger.e('Erro não tratado', error: error, stackTrace: stack),
  );
}
