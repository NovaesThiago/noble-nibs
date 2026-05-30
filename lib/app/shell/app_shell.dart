import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';

/// Shell de navegação com bottom nav. Cada aba é um branch do
/// `StatefulShellRoute.indexedStack`, então o estado (scroll, filtros) é
/// preservado ao alternar abas.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.caramel.withValues(alpha: 0.18),
          labelTextStyle: WidgetStatePropertyAll(
            AppTypography.label.copyWith(letterSpacing: 0, fontSize: 11),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.coffeeDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        child: NavigationBar(
          height: 68,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Loja',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: _BadgeIcon(icon: Icons.shopping_bag_outlined, count: cartCount),
              selectedIcon: _BadgeIcon(icon: Icons.shopping_bag_rounded, count: cartCount),
              label: 'Carrinho',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(color: AppColors.caramel, shape: BoxShape.circle),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
