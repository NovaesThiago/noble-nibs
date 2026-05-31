import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/storage/prefs_service.dart';

/// Controla o [ThemeMode] do app (claro/escuro/sistema), persistido em prefs.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(prefsServiceProvider).themeMode;
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      // Padrão: tema CLARO (antes seguia o sistema).
      _ => ThemeMode.light,
    };
  }

  void set(ThemeMode mode) {
    state = mode;
    unawaited(ref.read(prefsServiceProvider).setThemeMode(mode.name));
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
