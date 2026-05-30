import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/core/storage/secure_storage_service.dart';
import 'package:noble_nibs/features/auth/data/auth_repository_impl.dart';
import 'package:noble_nibs/features/auth/domain/auth_repository.dart';
import 'package:noble_nibs/features/auth/presentation/providers/auth_state.dart';
import 'package:noble_nibs/shared/domain/entities/user.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => const AuthRepositoryImpl());

/// Controlador de sessão (keepAlive). Mantém o [AuthState] global; as telas
/// chamam os métodos e tratam o `Either` retornado para loading/erro.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const Unauthenticated();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<Either<Failure, Unit>> signIn(String email, String password) async {
    final result = await _repo.signIn(email: email, password: password);
    return result.fold<Either<Failure, Unit>>(
      (failure) => Left(failure),
      (user) {
        _persistSession(user);
        state = Authenticated(user);
        return const Right(unit);
      },
    );
  }

  Future<Either<Failure, Unit>> signUp(String name, String email, String password) async {
    final result = await _repo.signUp(name: name, email: email, password: password);
    return result.fold<Either<Failure, Unit>>(
      (failure) => Left(failure),
      (user) {
        _persistSession(user);
        state = Authenticated(user);
        return const Right(unit);
      },
    );
  }

  void continueAsGuest() => state = const Guest();

  Future<void> signOut() async {
    await _repo.signOut();
    // Segurança: logout limpa TUDO do secure storage.
    await ref.read(secureStorageProvider).clearAll();
    state = const Unauthenticated();
  }

  /// Guarda o token (mock) em secure storage — nunca em prefs/logs.
  void _persistSession(User user) =>
      unawaited(ref.read(secureStorageProvider).saveToken('mock-token-${user.id}'));
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
