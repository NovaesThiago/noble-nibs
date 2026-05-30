import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/widgets/category_chip.dart';
import 'package:noble_nibs/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';

/// Barra horizontal de categorias. Lê [categoriesProvider] e controla
/// [selectedCategoryProvider]. "Todos" (type=all) corresponde a sem filtro.
class CategoryBar extends ConsumerWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return categoriesAsync.maybeWhen(
      data: (categories) => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final category = categories[i];
            final isAll = category.type == CategoryType.all;
            final isSelected =
                isAll ? selected == null : selected?.id == category.id;
            return CategoryChip(
              label: category.name,
              selected: isSelected,
              onTap: () => ref.read(selectedCategoryProvider.notifier).state =
                  isAll ? null : category,
            );
          },
        ),
      ),
      orElse: () => const SizedBox(height: 44),
    );
  }
}
