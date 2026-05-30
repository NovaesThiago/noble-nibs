import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/storage/prefs_service.dart';

/// Flag de "onboarding já visto", persistida em prefs (não reexibe após restart).
class OnboardingSeenController extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsServiceProvider).onboardingSeen;

  void markSeen() {
    state = true;
    unawaited(ref.read(prefsServiceProvider).setOnboardingSeen(true));
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenController, bool>(OnboardingSeenController.new);
