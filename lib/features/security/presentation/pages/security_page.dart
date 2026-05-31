import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/security/biometric_service.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/features/security/presentation/providers/biometric_provider.dart';

/// Configurações de segurança e biometria.
class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key, this.onBack});

  final VoidCallback? onBack;

  Future<void> _toggle(BuildContext context, WidgetRef ref, {required bool value}) async {
    final controller = ref.read(biometricEnabledProvider.notifier);
    if (!value) {
      controller.set(enabled: false);
      return;
    }
    // Ativar exige confirmar a biometria.
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate('Confirme sua identidade para ativar a biometria');
    if (!context.mounted) return;
    if (ok) {
      controller.set(enabled: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível confirmar a biometria.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(biometricAvailableProvider);
    final enabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: const Text('Segurança'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('AUTENTICAÇÃO', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            child: available.when(
              loading: () => const ListTile(
                leading: Icon(Icons.fingerprint_rounded, color: AppColors.caramelDeep),
                title: Text('Verificando biometria...'),
              ),
              error: (_, __) => _biometricTile(context, ref, enabled: enabled, available: false),
              data: (isAvailable) =>
                  _biometricTile(context, ref, enabled: enabled, available: isAvailable),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('PROTEÇÃO DOS SEUS DADOS', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            child: Column(
              children: const [
                _InfoTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Armazenamento seguro',
                  subtitle: 'Tokens de acesso ficam no Keychain/Keystore do aparelho.',
                ),
                Divider(height: 1),
                _InfoTile(
                  icon: Icons.shield_outlined,
                  title: 'Integridade do dispositivo',
                  subtitle: 'Verificamos root/jailbreak ao iniciar o app.',
                ),
                Divider(height: 1),
                _InfoTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Sessão protegida',
                  subtitle: 'Ao sair, todos os dados sensíveis são apagados.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _biometricTile(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
    required bool available,
  }) {
    return SwitchListTile(
      value: enabled && available,
      activeThumbColor: AppColors.caramel,
      secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.caramelDeep),
      title: Text('Entrar com biometria', style: AppTypography.body.copyWith(color: context.ink)),
      subtitle: Text(
        available
            ? 'Use Face ID ou impressão digital para acessar.'
            : 'Indisponível neste dispositivo.',
        style: AppTypography.label.copyWith(letterSpacing: 0),
      ),
      onChanged: available ? (v) => _toggle(context, ref, value: v) : null,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.caramelDeep),
        title: Text(title, style: AppTypography.body.copyWith(color: context.ink)),
        subtitle: Text(subtitle, style: AppTypography.label.copyWith(letterSpacing: 0)),
      );
}
