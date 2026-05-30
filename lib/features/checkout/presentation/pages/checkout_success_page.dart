import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

/// Confirmação animada do pedido.
class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({
    super.key,
    required this.orderId,
    this.onViewOrder,
    this.onBackToShop,
  });

  final String orderId;
  final VoidCallback? onViewOrder;
  final VoidCallback? onBackToShop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.05)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      )
                      .fadeIn(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Pedido confirmado!', style: AppTypography.display.copyWith(fontSize: 30))
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOut),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Seu pedido $orderId está em preparo.\nVocê acompanha o status em "Meus pedidos".',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(fontSize: 15),
                  ).animate().fadeIn(delay: 350.ms),
                  const Spacer(),
                  AppButton.primary('Acompanhar pedido', onPressed: onViewOrder)
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.4, curve: Curves.easeOut),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary('Voltar à loja', onPressed: onBackToShop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
