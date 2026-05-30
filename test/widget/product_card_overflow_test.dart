import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noble_nibs/core/theme/app_theme.dart';
import 'package:noble_nibs/core/widgets/product_card.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

void main() {
  testWidgets('ProductCard não estoura (overflow) em grade estreita', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: GridView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 48,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            children: [
              ProductCard(
                name: 'Cerrado Descafeinado Premium Especial',
                originLabel: 'Cerrado Mineiro',
                roastLabel: 'Torra média',
                price: const Money(13900),
                rating: 4.3,
                heroTag: 't1',
                width: double.infinity,
              ),
              ProductCard(
                name: 'Bourbon',
                originLabel: 'Minas',
                roastLabel: 'Média',
                price: const Money(3500),
                rating: 4.7,
                heroTag: 't2',
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    // Overflow de RenderFlex seria reportado como exceção no teste.
    expect(tester.takeException(), isNull);
  });
}
