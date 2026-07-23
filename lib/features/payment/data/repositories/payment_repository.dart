import '../datasources/payment_remote_datasource.dart';
import '../models/payment_models.dart';

class PaymentRepository {
  PaymentRepository(this._remote);

  final PaymentRemoteDataSource _remote;

  Future<CreatePaymentModel> createPayment(int orderId) => _remote.createPayment(orderId);
  Future<PaymentStatusModel> getPaymentStatus(int orderId) => _remote.getPaymentStatus(orderId);
}
