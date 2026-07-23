import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';

enum NotificationLoadStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationLoadStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  final NotificationLoadStatus status;
  final List<NotificationModel> items;
  final int unreadCount;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationLoadStatus? status,
    List<NotificationModel>? items,
    int? unreadCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, unreadCount, errorMessage];
}

class NotificationBloc extends Cubit<NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationState());

  final NotificationRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationLoadStatus.loading, clearError: true));
    try {
      final page = await _repository.list();
      final unread = await _repository.unreadCount();
      emit(state.copyWith(
        status: NotificationLoadStatus.success,
        items: page.items,
        unreadCount: unread.unreadCount,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: NotificationLoadStatus.failure, errorMessage: _mapError(e)));
    }
  }

  Future<void> refreshUnread() async {
    try {
      final unread = await _repository.unreadCount();
      emit(state.copyWith(unreadCount: unread.unreadCount));
    } catch (_) {}
  }

  Future<void> markRead(int id) async {
    await _repository.markRead(id);
    emit(state.copyWith(
      items: state.items.map((n) => n.id == id ? NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        category: n.category,
        read: true,
        createdAt: n.createdAt,
      ) : n).toList(),
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    ));
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    emit(state.copyWith(
      items: state.items.map((n) => NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        category: n.category,
        read: true,
        createdAt: n.createdAt,
      )).toList(),
      unreadCount: 0,
    ));
  }

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return 'Không tải được thông báo';
  }
}
