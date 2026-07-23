import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_models.dart';
import '../../data/repositories/cart_repository.dart';

enum CartStatus { initial, loading, success, failure, updating }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = CartModel.empty,
    this.errorMessage,
    this.couponInput = '',
  });

  final CartStatus status;
  final CartModel cart;
  final String? errorMessage;
  final String couponInput;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    String? errorMessage,
    String? couponInput,
    bool clearError = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      couponInput: couponInput ?? this.couponInput,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage, couponInput];
}

class CartBloc extends Cubit<CartState> {
  CartBloc(this._repository) : super(const CartState());

  final CartRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, clearError: true));
    try {
      final cart = await _repository.getCart();
      emit(state.copyWith(status: CartStatus.success, cart: cart, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'Có lỗi xảy ra';
  }

  Future<bool> addItem({required int variantId, int quantity = 1}) async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    try {
      final cart = await _repository.addItem(variantId: variantId, quantity: quantity);
      emit(state.copyWith(status: CartStatus.success, cart: cart, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
      return false;
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    if (quantity < 1) return;
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    try {
      final cart = await _repository.updateItem(itemId, quantity);
      emit(state.copyWith(status: CartStatus.success, cart: cart, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
    }
  }

  Future<void> removeItem(int itemId) async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    try {
      final cart = await _repository.removeItem(itemId);
      emit(state.copyWith(status: CartStatus.success, cart: cart, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
    }
  }

  void setCouponInput(String value) {
    emit(state.copyWith(couponInput: value));
  }

  Future<void> applyCoupon() async {
    final code = state.couponInput.trim();
    if (code.isEmpty) return;
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    try {
      final cart = await _repository.applyCoupon(code);
      emit(state.copyWith(status: CartStatus.success, cart: cart, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
    }
  }

  Future<void> removeCoupon() async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    try {
      final cart = await _repository.removeCoupon();
      emit(state.copyWith(status: CartStatus.success, cart: cart, couponInput: '', clearError: true));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: _mapError(e)));
    }
  }
}
