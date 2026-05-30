/// Endereço de entrega.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.number,
    required this.district,
    required this.city,
    required this.state,
    required this.cep,
    this.complement,
    this.isDefault = false,
  });

  final String id;
  final String label; // "Casa", "Trabalho"...
  final String street;
  final String number;
  final String? complement;
  final String district;
  final String city;
  final String state;
  final String cep;
  final bool isDefault;

  /// Uma linha resumida para exibição.
  String get oneLine {
    final comp = (complement != null && complement!.isNotEmpty) ? ' · $complement' : '';
    return '$street, $number$comp — $district, $city/$state · $cep';
  }

  @override
  bool operator ==(Object o) => o is Address && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
