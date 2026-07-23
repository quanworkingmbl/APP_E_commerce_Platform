import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/data/models/cart_models.dart';
import '../../../cart/data/repositories/cart_repository.dart';
import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';

enum CheckoutStatus { initial, loading, success, failure, submitting }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.step = 0,
    this.addresses = const [],
    this.shippingMethods = const [],
    this.selectedAddressId,
    this.selectedShippingId,
    this.cart = CartModel.empty,
    this.note = '',
    this.createdOrder,
    this.errorMessage,
  });

  final CheckoutStatus status;
  final int step;
  final List<AddressModel> addresses;
  final List<ShippingMethodModel> shippingMethods;
  final int? selectedAddressId;
  final int? selectedShippingId;
  final CartModel cart;
  final String note;
  final OrderDetailModel? createdOrder;
  final String? errorMessage;

  CheckoutState copyWith({
    CheckoutStatus? status,
    int? step,
    List<AddressModel>? addresses,
    List<ShippingMethodModel>? shippingMethods,
    int? selectedAddressId,
    int? selectedShippingId,
    CartModel? cart,
    String? note,
    OrderDetailModel? createdOrder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      step: step ?? this.step,
      addresses: addresses ?? this.addresses,
      shippingMethods: shippingMethods ?? this.shippingMethods,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedShippingId: selectedShippingId ?? this.selectedShippingId,
      cart: cart ?? this.cart,
      note: note ?? this.note,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status, step, addresses, shippingMethods, selectedAddressId,
        selectedShippingId, cart, note, createdOrder, errorMessage,
      ];
}

class CheckoutBloc extends Cubit<CheckoutState> {
  CheckoutBloc(this._orderRepository, this._addressRepository, this._shippingRepository, this._cartRepository)
      : super(const CheckoutState());

  final OrderRepository _orderRepository;
  final AddressRepository _addressRepository;
  final ShippingRepository _shippingRepository;
  final CartRepository _cartRepository;

  Future<void> init() async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        _addressRepository.list(),
        _shippingRepository.listMethods(),
        _cartRepository.getCart(),
      ]);
      final addresses = results[0] as List<AddressModel>;
      final methods = results[1] as List<ShippingMethodModel>;
      final cart = results[2] as CartModel;
      final defaultAddress = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
      emit(state.copyWith(
        status: CheckoutStatus.success,
        addresses: addresses,
        shippingMethods: methods,
        cart: cart,
        selectedAddressId: defaultAddress?.id,
        selectedShippingId: methods.isNotEmpty ? methods.first.id : null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: _mapError(e)));
    }
  }

  void nextStep() => emit(state.copyWith(step: state.step + 1));
  void prevStep() => emit(state.copyWith(step: state.step > 0 ? state.step - 1 : 0));
  void selectAddress(int id) => emit(state.copyWith(selectedAddressId: id));
  void selectShipping(int id) => emit(state.copyWith(selectedShippingId: id));
  void setNote(String note) => emit(state.copyWith(note: note));

  Future<bool> placeOrder() async {
    final addressId = state.selectedAddressId;
    final shippingId = state.selectedShippingId;
    if (addressId == null || shippingId == null) {
      emit(state.copyWith(errorMessage: 'Vui lòng chọn địa chỉ và phương thức giao hàng'));
      return false;
    }
    emit(state.copyWith(status: CheckoutStatus.submitting, clearError: true));
    try {
      final order = await _orderRepository.checkout(
        addressId: addressId,
        shippingMethodId: shippingId,
        note: state.note.isEmpty ? null : state.note,
      );
      emit(state.copyWith(status: CheckoutStatus.success, createdOrder: order, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: _mapError(e)));
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
