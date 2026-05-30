import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:shimmer/shimmer.dart';

/// Estados de UI padronizados para conteúdo assíncrono: loading, empty, error.
/// Centralizá-los garante consistência e cobre os 4 estados (com `data`) em
/// toda a app.

/// Skeleton de carregamento para a grade de produtos (shimmer quente).
class ProductGridLoading extends StatelessWidget {
  const ProductGridLoading({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.chipBg,
      highlightColor: context.card,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: context.chipBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}

/// Estado vazio (ex.: busca sem resultados).
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.coffee_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.inkSoft),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppTypography.body),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com ação de retry.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppTypography.body),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton.secondary('Tentar novamente', onPressed: onRetry, expanded: false),
            ],
          ],
        ),
      ),
    );
  }
}
