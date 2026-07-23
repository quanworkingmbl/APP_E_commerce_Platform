import '../../../../core/network/dio_client.dart';
import '../models/payment_models.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._client);

  final DioClient _client;

  Future<CreatePaymentModel> createPayment(int orderId) async {
    final response = await _client.dio.post('/payments/create', data: {'orderId': orderId});
    return CreatePaymentModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<PaymentStatusModel> getPaymentStatus(int orderId) async {
    final response = await _client.dio.get('/payments/status/$orderId');
    return PaymentStatusModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }
}
