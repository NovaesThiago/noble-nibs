import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/features/auth/domain/auth_repository.dart';
import 'package:noble_nibs/shared/domain/entities/user.dart';

/// Implementação MOCK de autenticação.
///
/// Aceita qualquer credencial bem-formada (a validação de formato acontece na
/// UI via `Validators`). Em produção, troque por uma fonte real (Supabase/REST)
/// sem alterar as camadas acima.
///
/// Segurança: nunca logamos senha; o token (mock) seria guardado em
/// secure storage numa implementação real.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  Future<void> get _latency => Future<void>.delayed(const Duration(milliseconds: 900));

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    await _latency;
    // Mock: deriva um usuário do e-mail. (Sem backend para validar de fato.)
    final name = _nameFromEmail(email);
    return Right(User(id: 'u-${email.hashCode}', name: name, email: email));
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _latency;
    return Right(User(id: 'u-${email.hashCode}', name: name, email: email));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const Right(unit);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp('[._]'), ' ');
    return local
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}
