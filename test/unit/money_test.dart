import 'package:flutter_test/flutter_test.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

void main() {
  group('Money', () {
    test('soma, subtração e multiplicação em centavos', () {
      expect((const Money(100) + const Money(50)).cents, 150);
      expect((const Money(100) - const Money(40)).cents, 60);
      expect((const Money(100) * 3).cents, 300);
    });

    test('fromReais converte para centavos sem erro de ponto flutuante', () {
      expect(Money.fromReais(35).cents, 3500);
      expect(Money.fromReais(0.1).cents, 10);
    });

    test('comparação', () {
      expect(const Money(100) > const Money(50), isTrue);
      expect(const Money(50) < const Money(100), isTrue);
    });

    test('igualdade por valor', () {
      expect(const Money(3500), const Money(3500));
    });

    test('formata como moeda', () {
      expect(const Money(3500).formatted, contains('35'));
    });
  });
}
