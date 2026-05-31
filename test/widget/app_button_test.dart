import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('renderiza o rótulo e dispara onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary('Comprar', onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Comprar'), findsOneWidget);
      await tester.tap(find.text('Comprar'));
      expect(tapped, isTrue);
    });

    testWidgets('mostra spinner quando isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary('Carregando', onPressed: null, isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('não estoura (overflow) com rótulo longo em espaço estreito', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const SizedBox(width: 150), // simula o seletor de quantidade
                Expanded(
                  child: AppButton.primary(
                    r'Adicionar · R$ 1.299,00',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
