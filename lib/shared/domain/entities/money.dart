import 'package:intl/intl.dart';

/// Value object para valores monetários.
///
/// Guardamos o valor em **centavos** (`int`) para evitar erros de ponto
/// flutuante em somas/multiplicações de preço — uma fonte clássica de bugs
/// em e-commerce. A formatação para exibição usa `intl` com locale pt-BR.
class Money {
  const Money(this.cents);

  /// Cria a partir de um valor em reais (ex.: `Money.fromReais(35.0)`).
  factory Money.fromReais(double reais) => Money((reais * 100).round());

  /// Centavos (unidade interna, sempre inteira).
  final int cents;

  /// Valor em reais (apenas para cálculos que exigem `double`).
  double get reais => cents / 100;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator *(int qty) => Money(cents * qty);

  bool operator >(Money other) => cents > other.cents;
  bool operator <(Money other) => cents < other.cents;

  static final _format = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

  /// Formata para exibição: `R$ 135,00`.
  String get formatted => _format.format(reais);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => formatted;
}
