import '../../../../core/network/dio_client.dart';
import '../models/order_models.dart';

class AddressRemoteDataSource {
  AddressRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<AddressModel>> list() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/users/me/addresses');
    final data = response.data?['data'] as List<dynamic>;
    return data.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> create(Map<String, dynamic> body) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>('/users/me/addresses', data: body);
    return AddressModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<AddressModel> update(int id, Map<String, dynamic> body) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>('/users/me/addresses/$id', data: body);
    return AddressModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioClient.dio.delete<void>('/users/me/addresses/$id');
  }

  Future<AddressModel> setDefault(int id) async {
    final response = await _dioClient.dio.patch<Map<String, dynamic>>('/users/me/addresses/$id/default');
    return AddressModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }
}

class ShippingRemoteDataSource {
  ShippingRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<ShippingMethodModel>> listMethods() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/shipping/methods');
    final data = response.data?['data'] as List<dynamic>;
    return data.map((e) => ShippingMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<OrderDetailModel> checkout({required int addressId, required int shippingMethodId, String? note}) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/orders/checkout',
      data: {'addressId': addressId, 'shippingMethodId': shippingMethodId, if (note != null) 'note': note},
    );
    return OrderDetailModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<PageResult<OrderSummaryModel>> listOrders({int page = 0, int size = 20}) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResult.fromJson(response.data?['data'] as Map<String, dynamic>, OrderSummaryModel.fromJson);
  }

  Future<OrderDetailModel> getOrder(int id) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/orders/$id');
    return OrderDetailModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<OrderDetailModel> cancelOrder(int id) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>('/orders/$id/cancel');
    return OrderDetailModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }
}
