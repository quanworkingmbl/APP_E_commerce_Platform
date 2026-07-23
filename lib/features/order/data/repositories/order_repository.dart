import '../datasources/order_remote_datasource.dart';
import '../models/order_models.dart';

class AddressRepository {
  AddressRepository(this._remote);

  final AddressRemoteDataSource _remote;

  Future<List<AddressModel>> list() => _remote.list();
  Future<AddressModel> create(AddressModel model) => _remote.create(model.toJson());
  Future<AddressModel> update(AddressModel model) => _remote.update(model.id, model.toJson());
  Future<void> delete(int id) => _remote.delete(id);
  Future<AddressModel> setDefault(int id) => _remote.setDefault(id);
}

class ShippingRepository {
  ShippingRepository(this._remote);

  final ShippingRemoteDataSource _remote;

  Future<List<ShippingMethodModel>> listMethods() => _remote.listMethods();
}

class OrderRepository {
  OrderRepository(this._remote);

  final OrderRemoteDataSource _remote;

  Future<OrderDetailModel> checkout({required int addressId, required int shippingMethodId, String? note}) =>
      _remote.checkout(addressId: addressId, shippingMethodId: shippingMethodId, note: note);

  Future<PageResult<OrderSummaryModel>> listOrders({int page = 0, int size = 20}) =>
      _remote.listOrders(page: page, size: size);

  Future<OrderDetailModel> getOrder(int id) => _remote.getOrder(id);
  Future<OrderDetailModel> cancelOrder(int id) => _remote.cancelOrder(id);
}
