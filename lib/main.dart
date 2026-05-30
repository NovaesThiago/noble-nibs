import 'package:noble_nibs/app/app.dart';
import 'package:noble_nibs/bootstrap.dart';

/// Ponto de entrada do app. Toda a inicialização (locale, segurança, prefs,
/// captura de erros) acontece em [bootstrap].
Future<void> main() => bootstrap(() => const NobleNibsApp());
