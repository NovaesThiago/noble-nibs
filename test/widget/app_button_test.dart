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
  });
}
