/// Validadores de entrada do usuário.
///
/// Segurança: **toda** entrada passa por aqui antes de ser usada. Funções
/// retornam `null` quando válido (contrato esperado por `TextFormField`),
/// ou uma mensagem de erro pt-BR.
abstract final class Validators {
  static String? required(String? v, {String field = 'Campo'}) =>
      (v == null || v.trim().isEmpty) ? '$field é obrigatório' : null;

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Informe o e-mail';
    final re = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'E-mail inválido';
  }

  /// Senha forte: mín. 8, com maiúscula, número e símbolo.
  ///
  /// Trade-off de segurança × UX deliberado (ver plano §11.6 / §18).
  static String? password(String? v) {
    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Inclua uma letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Inclua um número';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
      return 'Inclua um símbolo';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original) =>
      v == original ? null : 'As senhas não coincidem';

  static String? cep(String? v) {
    if (v == null) return 'CEP inválido';
    return RegExp(r'^\d{5}-?\d{3}$').hasMatch(v) ? null : 'CEP inválido';
  }

  static String? phone(String? v) {
    if (v == null) return 'Telefone inválido';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 11 ? null : 'Telefone inválido';
  }
}
