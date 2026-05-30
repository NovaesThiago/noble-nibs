import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/utils/validators.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/app_text_field.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';
import 'package:noble_nibs/features/auth/presentation/providers/auth_controller.dart';

/// Tela de login (mock). Aceita qualquer credencial bem-formada.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    super.key,
    this.onSuccess,
    this.onRegister,
    this.onGuest,
    this.onBack,
  });

  final VoidCallback? onSuccess;
  final VoidCallback? onRegister;
  final VoidCallback? onGuest;
  final VoidCallback? onBack;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => widget.onSuccess?.call(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.05)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.onBack != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.coffeeDark),
                        onPressed: widget.onBack,
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Bem-vindo de volta', style: AppTypography.display.copyWith(fontSize: 34)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Entre para continuar sua jornada pelo café.', style: AppTypography.body),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _email,
                      label: 'E-mail',
                      hint: 'voce@email.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _password,
                      label: 'Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      validator: (v) => Validators.required(v, field: 'Senha'),
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary('Entrar', isLoading: _loading, onPressed: _submit),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: AppButton.ghost('Continuar como visitante', onPressed: widget.onGuest),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Wrap(
                        children: [
                          Text('Não tem conta? ', style: AppTypography.body),
                          GestureDetector(
                            onTap: widget.onRegister,
                            child: Text(
                              'Criar agora',
                              style: AppTypography.button.copyWith(
                                color: AppColors.caramelDeep,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
