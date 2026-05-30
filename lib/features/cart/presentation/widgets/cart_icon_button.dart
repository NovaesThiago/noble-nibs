import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';

/// Botão de carrinho com badge de contagem reativo ([cartCountProvider]).
class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          color: context.ink,
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: const BoxDecoration(
                color: AppColors.caramel,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
