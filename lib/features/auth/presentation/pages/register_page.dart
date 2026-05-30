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

/// Tela de cadastro (mock) com validação de senha forte.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.onSuccess, this.onBack});

  final VoidCallback? onSuccess;
  final VoidCallback? onBack;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .signUp(_name.text.trim(), _email.text.trim(), _password.text);
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
      appBar: AppBar(
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.05)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Criar conta', style: AppTypography.display.copyWith(fontSize: 34)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Leva menos de um minuto.', style: AppTypography.body),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _name,
                      label: 'Nome',
                      hint: 'Seu nome',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => Validators.required(v, field: 'Nome'),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                      hint: 'Mín. 8, com maiúscula, número e símbolo',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      validator: Validators.password,
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
                    AppButton.primary('Criar conta', isLoading: _loading, onPressed: _submit),
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
