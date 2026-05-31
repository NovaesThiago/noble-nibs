import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/utils/validators.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/app_text_field.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:noble_nibs/shared/domain/entities/address.dart';

/// Gerenciamento de endereços de entrega.
class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: const Text('Endereços'),
      ),
      body: addresses.isEmpty
          ? EmptyView(
              message: 'Você ainda não tem endereços salvos.',
              icon: Icons.location_on_outlined,
              action: AppButton.primary(
                'Adicionar endereço',
                icon: Icons.add_rounded,
                expanded: false,
                onPressed: () => _openForm(context, ref),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => _AddressCard(address: addresses[i]),
            ),
      floatingActionButton: addresses.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.caramel,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text('Adicionar', style: AppTypography.button),
              onPressed: () => _openForm(context, ref),
            ),
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const _AddAddressSheet(),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.caramelDeep),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label,
                        style: AppTypography.button.copyWith(color: context.ink)),
                    if (address.isDefault) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text('Padrão',
                            style: AppTypography.label.copyWith(
                              color: AppColors.caramelDeep,
                              letterSpacing: 0,
                            )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address.oneLine,
                    style: AppTypography.label.copyWith(letterSpacing: 0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Formulário de novo endereço (bottom sheet).
class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _cep = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _complement = TextEditingController();
  final _district = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();

  @override
  void dispose() {
    for (final c in [_label, _cep, _street, _number, _complement, _district, _city, _state]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final address = Address(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _label.text.trim(),
      street: _street.text.trim(),
      number: _number.text.trim(),
      complement: _complement.text.trim().isEmpty ? null : _complement.text.trim(),
      district: _district.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim().toUpperCase(),
      cep: _cep.text.trim(),
    );
    ref.read(addressesControllerProvider.notifier).add(address);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo endereço', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _label,
                label: 'Identificação',
                hint: 'Casa, Trabalho...',
                validator: (v) => Validators.required(v, field: 'Identificação'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _cep,
                label: 'CEP',
                hint: '00000-000',
                keyboardType: TextInputType.number,
                validator: Validators.cep,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      controller: _street,
                      label: 'Rua',
                      validator: (v) => Validators.required(v, field: 'Rua'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _number,
                      label: 'Nº',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, field: 'Número'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _complement, label: 'Complemento (opcional)'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _district,
                label: 'Bairro',
                validator: (v) => Validators.required(v, field: 'Bairro'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      controller: _city,
                      label: 'Cidade',
                      validator: (v) => Validators.required(v, field: 'Cidade'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _state,
                      label: 'UF',
                      validator: (v) =>
                          (v != null && v.trim().length == 2) ? null : 'UF',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary('Salvar endereço', icon: Icons.check_rounded, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
