import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger global. **Desativado em release** (segurança: nada de logs em
/// produção) e enxuto em debug.
final logger = Logger(
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80),
);
