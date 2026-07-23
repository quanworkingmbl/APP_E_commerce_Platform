import '../datasources/return_remote_datasource.dart';
import '../models/return_models.dart';

class ReturnRepository {
  ReturnRepository(this._remote);

  final ReturnRemoteDataSource _remote;

  Future<ReturnDetailModel> createReturn({
    required int orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) => _remote.createReturn(orderId: orderId, reason: reason, items: items);
}
