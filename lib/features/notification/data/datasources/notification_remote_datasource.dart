import '../../../../core/network/dio_client.dart';
import '../../../order/data/models/order_models.dart';
import '../models/notification_models.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._client);

  final DioClient _client;

  Future<PageResult<NotificationModel>> list({int page = 0, int size = 20}) async {
    final response = await _client.dio.get('/notifications', queryParameters: {'page': page, 'size': size});
    final data = response.data?['data'] as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return PageResult(
      items: content.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
      page: data['page'] as int? ?? page,
      size: data['size'] as int? ?? size,
      total: data['totalElements'] as int? ?? content.length,
    );
  }

  Future<UnreadCountModel> unreadCount() async {
    final response = await _client.dio.get('/notifications/unread-count');
    return UnreadCountModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }

  Future<void> markRead(int id) async {
    await _client.dio.patch('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.dio.patch('/notifications/read-all');
  }
}
