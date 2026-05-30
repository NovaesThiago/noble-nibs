/// Falhas de domínio — o "vocabulário de erros" que atravessa as camadas.
///
/// Use-cases retornam `Either<Failure, T>` (via `fpdart`), nunca lançam
/// exceptions para a camada de apresentação. Por ser `sealed`, o compilador
/// obriga tratamento exaustivo em `switch`, eliminando casos esquecidos na UI.
library;

sealed class Failure {
  const Failure(this.message);

  /// Mensagem amigável e segura para exibir ao usuário (sem detalhes técnicos).
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Sem conexão / falha de rede transitória.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

/// Erro retornado pelo servidor (5xx, payload inválido).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor. Tente novamente.']);
}

/// Falha ao ler/gravar dados locais (cache, storage).
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais.']);
}

/// Falha de autenticação/autorização.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Entrada inválida (validação de formulário, regra de negócio).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Catch-all para erros não mapeados.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Algo deu errado.']);
}
