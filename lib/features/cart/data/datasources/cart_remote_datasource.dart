import '../../../../core/network/dio_client.dart';
import '../models/cart_models.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<CartModel> getCart() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/cart');
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Future<CartModel> addItem({required int variantId, int quantity = 1}) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/cart/items',
      data: {'variantId': variantId, 'quantity': quantity},
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Future<CartModel> updateItem(int itemId, int quantity) async {
    final response = await _dioClient.dio.patch<Map<String, dynamic>>(
      '/cart/items/$itemId',
      data: {'quantity': quantity},
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Future<CartModel> removeItem(int itemId) async {
    final response = await _dioClient.dio.delete<Map<String, dynamic>>('/cart/items/$itemId');
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Future<CartModel> applyCoupon(String code) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/cart/coupon',
      data: {'code': code},
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Future<CartModel> removeCoupon() async {
    final response = await _dioClient.dio.delete<Map<String, dynamic>>('/cart/coupon');
    final data = response.data?['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }
}
