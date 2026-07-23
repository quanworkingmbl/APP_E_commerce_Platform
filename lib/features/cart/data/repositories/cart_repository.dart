import '../datasources/cart_remote_datasource.dart';
import '../models/cart_models.dart';

class CartRepository {
  CartRepository(this._remote);

  final CartRemoteDataSource _remote;

  Future<CartModel> getCart() => _remote.getCart();

  Future<CartModel> addItem({required int variantId, int quantity = 1}) =>
      _remote.addItem(variantId: variantId, quantity: quantity);

  Future<CartModel> updateItem(int itemId, int quantity) =>
      _remote.updateItem(itemId, quantity);

  Future<CartModel> removeItem(int itemId) => _remote.removeItem(itemId);

  Future<CartModel> applyCoupon(String code) => _remote.applyCoupon(code);

  Future<CartModel> removeCoupon() => _remote.removeCoupon();
}
