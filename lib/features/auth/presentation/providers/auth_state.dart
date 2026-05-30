import 'package:noble_nibs/shared/domain/entities/user.dart';

/// Estado de autenticação (sealed → switch exaustivo na UI/guards).
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is Authenticated;
  bool get canCheckout => this is Authenticated; // visitante precisa logar p/ pagar

  User? get userOrNull => switch (this) {
        Authenticated(:final user) => user,
        _ => null,
      };
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Guest extends AuthState {
  const Guest();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
}
