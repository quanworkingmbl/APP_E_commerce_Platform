import '../../../../core/network/dio_client.dart';
import '../models/return_models.dart';

class ReturnRemoteDataSource {
  ReturnRemoteDataSource(this._client);

  final DioClient _client;

  Future<ReturnDetailModel> createReturn({
    required int orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _client.dio.post('/returns', data: {
      'orderId': orderId,
      'reason': reason,
      'items': items,
    });
    return ReturnDetailModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }
}
