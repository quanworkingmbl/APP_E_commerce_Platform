import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/return_repository.dart';

enum ReturnSubmitStatus { initial, submitting, success, failure }

class ReturnState extends Equatable {
  const ReturnState({
    this.status = ReturnSubmitStatus.initial,
    this.errorMessage,
  });

  final ReturnSubmitStatus status;
  final String? errorMessage;

  ReturnState copyWith({ReturnSubmitStatus? status, String? errorMessage, bool clearError = false}) {
    return ReturnState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class ReturnBloc extends Cubit<ReturnState> {
  ReturnBloc(this._repository) : super(const ReturnState());

  final ReturnRepository _repository;

  Future<bool> submitReturn({
    required int orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(state.copyWith(status: ReturnSubmitStatus.submitting, clearError: true));
    try {
      await _repository.createReturn(orderId: orderId, reason: reason, items: items);
      emit(state.copyWith(status: ReturnSubmitStatus.success));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(status: ReturnSubmitStatus.failure, errorMessage: _mapError(e)));
      return false;
    } catch (e) {
      emit(state.copyWith(status: ReturnSubmitStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return 'Không thể gửi yêu cầu trả hàng';
  }
}
