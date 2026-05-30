import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/providers/theme_mode_provider.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/features/auth/presentation/providers/auth_controller.dart';

/// Aba de perfil e configurações.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.onOpenOrders, this.onLogout, this.onLogin});

  final VoidCallback? onOpenOrders;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.userOrNull;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.md),
            // --- Cabeçalho do usuário ---
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.caramel,
                  child: Text(
                    user?.initials ?? '👤',
                    style: AppTypography.headline.copyWith(color: Colors.white, fontSize: 22),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Visitante', style: AppTypography.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Entre para sincronizar seus pedidos',
                        style: AppTypography.label.copyWith(letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
                if (user == null)
                  TextButton(onPressed: onLogin, child: const Text('Entrar')),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Tema (usa AppTheme.dark / _darkScheme) ---
            Text('APARÊNCIA', style: AppTypography.overline),
            const SizedBox(height: AppSpacing.sm),
            _ThemeSelector(
              mode: mode,
              onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Opções ---
            Text('CONTA', style: AppTypography.overline),
            const SizedBox(height: AppSpacing.sm),
            _Tile(icon: Icons.receipt_long_outlined, label: 'Meus pedidos', onTap: onOpenOrders),
            _Tile(icon: Icons.location_on_outlined, label: 'Endereços', onTap: () {}),
            _Tile(icon: Icons.fingerprint_rounded, label: 'Segurança e biometria', onTap: () {}),
            _Tile(icon: Icons.info_outline_rounded, label: 'Sobre o Noble Nibs', onTap: () {}),
            if (user != null)
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Sair',
                danger: true,
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  onLogout?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, 'Claro', Icons.light_mode_rounded),
      (ThemeMode.dark, 'Escuro', Icons.dark_mode_rounded),
      (ThemeMode.system, 'Sistema', Icons.brightness_auto_rounded),
    ];
    return Row(
      children: [
        for (final (m, label, icon) in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: m == mode ? AppColors.caramel : context.chipBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: m == mode ? AppColors.caramel : context.line,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: m == mode ? Colors.white : context.inkSoft, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: AppTypography.label.copyWith(
                        letterSpacing: 0,
                        color: m == mode ? Colors.white : context.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (m != ThemeMode.system) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : context.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: danger ? AppColors.error : AppColors.caramelDeep),
      title: Text(label, style: AppTypography.body.copyWith(color: color)),
      trailing: Icon(Icons.chevron_right_rounded, color: context.inkSoft),
      onTap: onTap,
    );
  }
}
