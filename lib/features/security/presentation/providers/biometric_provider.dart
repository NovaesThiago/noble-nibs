import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/security/biometric_service.dart';
import 'package:noble_nibs/core/storage/prefs_service.dart';

/// Disponibilidade de biometria no dispositivo (async, uma vez).
final biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricServiceProvider).isAvailable(),
);

/// Preferência "usar biometria", persistida em prefs.
class BiometricEnabledController extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsServiceProvider).biometricEnabled;

  void set({required bool enabled}) {
    state = enabled;
    unawaited(ref.read(prefsServiceProvider).setBiometricEnabled(enabled));
  }
}

final biometricEnabledProvider =
    NotifierProvider<BiometricEnabledController, bool>(BiometricEnabledController.new);
