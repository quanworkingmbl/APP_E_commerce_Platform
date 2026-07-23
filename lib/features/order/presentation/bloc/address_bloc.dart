import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';

enum AddressStatus { initial, loading, success, failure, saving }

class AddressState extends Equatable {
  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  final AddressStatus status;
  final List<AddressModel> addresses;
  final String? errorMessage;

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, addresses, errorMessage];
}

class AddressBloc extends Cubit<AddressState> {
  AddressBloc(this._repository) : super(const AddressState());

  final AddressRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AddressStatus.loading, clearError: true));
    try {
      final addresses = await _repository.list();
      emit(state.copyWith(status: AddressStatus.success, addresses: addresses, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: _mapError(e)));
    }
  }

  Future<bool> save(AddressModel model, {bool isNew = false}) async {
    emit(state.copyWith(status: AddressStatus.saving, clearError: true));
    try {
      if (isNew) {
        await _repository.create(model);
      } else {
        await _repository.update(model);
      }
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: _mapError(e)));
      return false;
    }
  }

  Future<void> delete(int id) async {
    emit(state.copyWith(status: AddressStatus.saving, clearError: true));
    try {
      await _repository.delete(id);
      await load();
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: _mapError(e)));
    }
  }

  Future<void> setDefault(int id) async {
    emit(state.copyWith(status: AddressStatus.saving, clearError: true));
    try {
      await _repository.setDefault(id);
      await load();
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: _mapError(e)));
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
