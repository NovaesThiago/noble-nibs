/// Exceptions internas da camada `data`.
///
/// Diferente de [Failure] (que é o tipo público que atravessa as camadas),
/// estas exceptions vivem apenas dentro de datasources/repositories e são
/// convertidas para [Failure] pelo `error_mapper`/`RepositoryImpl`.
library;

class ServerException implements Exception {
  const ServerException([this.message = 'Erro no servidor']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Erro de cache']);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
