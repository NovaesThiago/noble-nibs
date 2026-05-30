import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

/// Método de pagamento oferecido no checkout.
enum PaymentMethod {
  pix('Pix'),
  credit('Cartão de crédito');

  const PaymentMethod(this.label);
  final String label;
}

class PaymentRequest {
  const PaymentRequest({required this.amount, required this.method});
  final Money amount;
  final PaymentMethod method;
}

class PaymentResult {
  const PaymentResult({required this.transactionId, required this.method});
  final String transactionId;
  final PaymentMethod method;
}

/// Abstração de gateway de pagamento.
///
/// Trocar [MockPaymentGateway] por uma implementação Mercado Pago/Stripe no
/// futuro não exige mudança na UI de checkout — só no provider que a injeta.
abstract interface class PaymentGateway {
  Future<Either<Failure, PaymentResult>> pay(PaymentRequest request);
}

/// Implementação mock: aprova após uma latência simulada.
class MockPaymentGateway implements PaymentGateway {
  const MockPaymentGateway();

  @override
  Future<Either<Failure, PaymentResult>> pay(PaymentRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    // Mock sempre aprova. Para testar erro, troque por:
    //   return const Left(ServerFailure('Pagamento recusado'));
    final id = 'TX-${DateTime.now().millisecondsSinceEpoch}';
    return Right(PaymentResult(transactionId: id, method: request.method));
  }
}
