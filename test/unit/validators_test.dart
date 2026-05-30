import 'package:flutter_test/flutter_test.dart';
import 'package:noble_nibs/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('aceita e-mail válido', () => expect(Validators.email('voce@email.com'), isNull));
    test('rejeita inválido', () => expect(Validators.email('invalido'), isNotNull));
    test('rejeita vazio', () => expect(Validators.email(''), isNotNull));
  });

  group('Validators.password', () {
    test('aceita senha forte', () => expect(Validators.password('Abcdef1!'), isNull));
    test('rejeita curta', () => expect(Validators.password('Ab1!'), isNotNull));
    test('rejeita sem maiúscula', () => expect(Validators.password('abcdef1!'), isNotNull));
    test('rejeita sem símbolo', () => expect(Validators.password('Abcdef12'), isNotNull));
  });

  group('Validators.cep', () {
    test('aceita com e sem hífen', () {
      expect(Validators.cep('01310-100'), isNull);
      expect(Validators.cep('01310100'), isNull);
    });
    test('rejeita inválido', () => expect(Validators.cep('123'), isNotNull));
  });
}
