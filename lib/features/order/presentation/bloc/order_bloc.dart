import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';

enum OrderStatusEnum { initial, loading, success, failure, updating }

class OrderState extends Equatable {
  const OrderState({
    this.status = OrderStatusEnum.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
  });

  final OrderStatusEnum status;
  final List<OrderSummaryModel> orders;
  final OrderDetailModel? selectedOrder;
  final String? errorMessage;

  OrderState copyWith({
    OrderStatusEnum? status,
    List<OrderSummaryModel>? orders,
    OrderDetailModel? selectedOrder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, orders, selectedOrder, errorMessage];
}

class OrderBloc extends Cubit<OrderState> {
  OrderBloc(this._repository) : super(const OrderState());

  final OrderRepository _repository;

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrderStatusEnum.loading, clearError: true));
    try {
      final result = await _repository.listOrders();
      emit(state.copyWith(status: OrderStatusEnum.success, orders: result.items, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: OrderStatusEnum.failure, errorMessage: _mapError(e)));
    }
  }

  Future<void> loadOrder(int id) async {
    emit(state.copyWith(status: OrderStatusEnum.loading, clearError: true));
    try {
      final order = await _repository.getOrder(id);
      emit(state.copyWith(status: OrderStatusEnum.success, selectedOrder: order, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: OrderStatusEnum.failure, errorMessage: _mapError(e)));
    }
  }

  Future<bool> cancelOrder(int id) async {
    emit(state.copyWith(status: OrderStatusEnum.updating, clearError: true));
    try {
      final order = await _repository.cancelOrder(id);
      emit(state.copyWith(status: OrderStatusEnum.success, selectedOrder: order, clearError: true));
      await loadOrders();
      return true;
    } catch (e) {
      emit(state.copyWith(status: OrderStatusEnum.failure, errorMessage: _mapError(e)));
      return false;
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    }
    return 'Có lỗi xảy ra';
  }
}
