import '../datasources/notification_remote_datasource.dart';
import '../models/notification_models.dart';
import '../../../order/data/models/order_models.dart';

class NotificationRepository {
  NotificationRepository(this._remote);

  final NotificationRemoteDataSource _remote;

  Future<PageResult<NotificationModel>> list({int page = 0, int size = 20}) =>
      _remote.list(page: page, size: size);

  Future<UnreadCountModel> unreadCount() => _remote.unreadCount();
  Future<void> markRead(int id) => _remote.markRead(id);
  Future<void> markAllRead() => _remote.markAllRead();
}
