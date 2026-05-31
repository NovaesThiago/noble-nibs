import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_text_field.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:noble_nibs/features/catalog/presentation/widgets/category_bar.dart';
import 'package:noble_nibs/features/catalog/presentation/widgets/product_grid.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Tela de catálogo: busca + categorias + ordenação + grade de produtos.
///
/// O cabeçalho é **reativo ao scroll**: no topo ele se funde com o fundo do
/// tema (transparente); ao rolar, anima para a cor reversa (`onSurface`) com os
/// componentes invertidos (`surface`), virando uma barra de contraste.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({
    super.key,
    this.onTapProduct,
    this.onAddProduct,
    this.onOpenOrders,
  });

  final void Function(Product)? onTapProduct;
  final void Function(Product)? onAddProduct;
  final VoidCallback? onOpenOrders;

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final _scroll = ScrollController();

  /// No topo real da lista → controla a COR (transparente só no topo).
  bool _atTop = true;

  /// Elementos recolhidos → controlado pela DIREÇÃO (baixo = recolhe,
  /// cima = expande). Independente da cor.
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final atTop = pos.pixels <= 8;

    var collapsed = _collapsed;
    if (atTop) {
      collapsed = false; // no topo, sempre expandido
    } else if (pos.userScrollDirection == ScrollDirection.reverse) {
      collapsed = true; // rolando para baixo → oculta
    } else if (pos.userScrollDirection == ScrollDirection.forward) {
      collapsed = false; // rolando para cima → retorna
    }

    if (atTop != _atTop || collapsed != _collapsed) {
      setState(() {
        _atTop = atTop;
        _collapsed = collapsed;
      });
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Bolinha caramelo do "Meus pedidos". Reutilizada no título (topo) ou ao
  /// lado do input (minimizado).
  Widget _ordersButton({double size = 46, double iconSize = 22}) {
    return Material(
      color: AppColors.caramel,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpenOrders,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final sort = ref.watch(sortOrderProvider);
    final scheme = Theme.of(context).colorScheme;

    // Cor: depende SÓ da posição (transparente apenas no topo real; depois
    // permanece na cor reversa, mesmo ao subir, até voltar ao topo).
    final headerBg = _atTop ? Colors.transparent : scheme.onSurface;
    final headerFg = _atTop ? scheme.onSurface : scheme.surface;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: BeanPatternBackground(opacity: 0.12, density: 24),
          ),
          SafeArea(
            child: Column(
              children: [
                // --- Cabeçalho reativo ao scroll ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: headerBg,
                    boxShadow: _atTop ? const <BoxShadow>[] : AppShadows.soft,
                  ),
                  child: Column(
                    children: [
                      // Título: sempre visível, mas a FONTE diminui ao rolar.
                      // Minimizado → top maior (título desce, mais perto do input).
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.fromLTRB(
                          // Mesmo left do header reduzido (input minimizado).
                          AppSpacing.lg + AppSpacing.xs,
                          _collapsed ? AppSpacing.lg : AppSpacing.md,
                          AppSpacing.lg,
                          // Minimizado: mais espaço entre o título e o input.
                          _collapsed ? AppSpacing.md : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                alignment: Alignment.centerLeft,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeOut,
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(opacity: anim, child: child),
                                  // Alinha à esquerda (padrão é centralizado) →
                                  // mesmo left no expandido e no minimizado.
                                  layoutBuilder: (current, previous) => Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      ...previous,
                                      if (current != null) current,
                                    ],
                                  ),
                                  child: _collapsed
                                      // Minimizado: título + "NOSSA SELEÇÃO" à direita.
                                      ? Row(
                                          key: const ValueKey('title-collapsed'),
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Catálogo de grãos',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.headline.copyWith(
                                                  color: headerFg,
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.sm),
                                            Text('NOSSA SELEÇÃO', style: AppTypography.overline),
                                          ],
                                        )
                                      // Topo: "NOSSA SELEÇÃO" em cima do título.
                                      : Column(
                                          key: const ValueKey('title-expanded'),
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('NOSSA SELEÇÃO', style: AppTypography.overline),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Catálogo de grãos',
                                              style: AppTypography.headline.copyWith(
                                                color: headerFg,
                                                fontSize: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            // Bolinha no título só no topo; some com fade ao minimizar.
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(scale: anim, child: child),
                              ),
                              child: _collapsed
                                  ? const SizedBox(key: ValueKey('orders-title-empty'))
                                  : Padding(
                                      key: const ValueKey('orders-title'),
                                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                                      child: _ordersButton(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      // Busca: permanece visível. Minimizado → sobe um pouco
                      // (menos padding-top).
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.fromLTRB(
                          // Minimizado: laterais um pouco maiores → input mais
                          // estreito (mas não tanto).
                          _collapsed ? AppSpacing.lg + AppSpacing.xs : AppSpacing.lg,
                          _collapsed ? 0 : AppSpacing.sm,
                          _collapsed ? AppSpacing.lg + AppSpacing.xs : AppSpacing.lg,
                          // Minimizado: input é o último elemento → mais respiro
                          // para não encostar na borda do header.
                          _collapsed ? AppSpacing.md : AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextField.search(
                                hint: 'Buscar por nome, origem ou nota...',
                                dense: _collapsed, // minimizado → menor altura
                                onChanged: (q) =>
                                    ref.read(searchQueryProvider.notifier).state = q,
                              ),
                            ),
                            // Minimizado: bolinha à direita do input (fade+scale).
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(scale: anim, child: child),
                              ),
                              child: _collapsed
                                  ? Padding(
                                      key: const ValueKey('orders-input'),
                                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                                      child: _ordersButton(size: 44, iconSize: 20),
                                    )
                                  : const SizedBox(key: ValueKey('orders-input-empty')),
                            ),
                          ],
                        ),
                      ),
                      // Seletores (categorias + ordenação): SOMEM ao rolar.
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _collapsed
                            ? const SizedBox(width: double.infinity)
                            : Column(
                                children: [
                                  const CategoryBar(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.lg,
                                      AppSpacing.sm,
                                      AppSpacing.lg,
                                      AppSpacing.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        productsAsync.maybeWhen(
                                          data: (list) => Text(
                                            '${list.length} ${list.length == 1 ? 'item' : 'itens'}',
                                            style: AppTypography.label.copyWith(color: headerFg),
                                          ),
                                          orElse: () => const SizedBox.shrink(),
                                        ),
                                        const Spacer(),
                                        _SortButton(
                                          current: sort,
                                          foreground: headerFg,
                                          onSelected: (s) =>
                                              ref.read(sortOrderProvider.notifier).state = s,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                // --- Conteúdo (4 estados) ---
                Expanded(
                  child: productsAsync.when(
                    loading: () => const ProductGridLoading(),
                    error: (e, _) => ErrorView(
                      message: e is Failure ? e.message : 'Erro ao carregar.',
                      onRetry: () => ref.invalidate(productsProvider),
                    ),
                    data: (products) => products.isEmpty
                        ? EmptyView(
                            message:
                                'Nenhum grão encontrado para sua busca.\nTente outro termo ou categoria.',
                            action: TextButton(
                              onPressed: () {
                                ref.read(searchQueryProvider.notifier).state = '';
                                ref.read(selectedCategoryProvider.notifier).state = null;
                              },
                              child: const Text('Limpar filtros'),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.caramel,
                            onRefresh: () async => ref.invalidate(productsProvider),
                            child: ProductGrid(
                              controller: _scroll,
                              products: products,
                              onTapProduct: widget.onTapProduct,
                              onAddProduct: widget.onAddProduct,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de ordenação que abre um bottom sheet com as opções.
class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.current,
    required this.onSelected,
    this.foreground,
  });

  final CatalogSort current;
  final ValueChanged<CatalogSort> onSelected;
  final Color? foreground;

  Future<void> _open(BuildContext context) async {
    final choice = await showModalBottomSheet<CatalogSort>(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text('Ordenar por', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final s in CatalogSort.values)
              ListTile(
                title: Text(s.label, style: AppTypography.body.copyWith(
                  color: context.ink,
                )),
                trailing: s == current
                    ? const Icon(Icons.check_rounded, color: AppColors.caramel)
                    : null,
                onTap: () => Navigator.pop(ctx, s),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (choice != null) onSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? context.brandInk;
    return TextButton.icon(
      onPressed: () => _open(context),
      icon: Icon(Icons.swap_vert_rounded, size: 18, color: fg),
      label: Text(
        current.label,
        style: AppTypography.label.copyWith(color: fg, letterSpacing: 0),
      ),
    );
  }
}
