import 'package:intl/intl.dart';

/// Formatadores de exibição (datas, peso). Moeda fica em [Money.formatted].
abstract final class Formatters {
  static final _date = DateFormat("d 'de' MMM, y", 'pt_BR');

  static String date(DateTime d) => _date.format(d);

  /// Peso em gramas → "250g" ou "1kg".
  static String weight(int grams) =>
      grams >= 1000 ? '${(grams / 1000).toStringAsFixed(grams % 1000 == 0 ? 0 : 1)}kg' : '${grams}g';
}
