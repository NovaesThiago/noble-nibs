import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/app/router/app_router.dart';
import 'package:noble_nibs/core/providers/theme_mode_provider.dart';
import 'package:noble_nibs/core/theme/app_theme.dart';

/// Widget raiz: `MaterialApp.router` com tema reativo e localização pt-BR.
class NobleNibsApp extends ConsumerWidget {
  const NobleNibsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Noble Nibs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // Localização (Material/Cupertino) em pt-BR. As strings de UI estão em
      // pt-BR inline; a infra de `gen-l10n` (app_pt.arb) está pronta para
      // migrar quando quiser multi-idioma.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
