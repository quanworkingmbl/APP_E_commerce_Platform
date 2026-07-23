import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/review_repository.dart';

enum ReviewStatus { initial, submitting, success, failure }

class ReviewState extends Equatable {
  const ReviewState({
    this.status = ReviewStatus.initial,
    this.errorMessage,
  });

  final ReviewStatus status;
  final String? errorMessage;

  ReviewState copyWith({ReviewStatus? status, String? errorMessage, bool clearError = false}) {
    return ReviewState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class ReviewBloc extends Cubit<ReviewState> {
  ReviewBloc(this._repository) : super(const ReviewState());

  final ReviewRepository _repository;

  Future<bool> submitReview({
    required int orderItemId,
    required int rating,
    String? content,
  }) async {
    emit(state.copyWith(status: ReviewStatus.submitting, clearError: true));
    try {
      await _repository.createReview(orderItemId: orderItemId, rating: rating, content: content);
      emit(state.copyWith(status: ReviewStatus.success));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(status: ReviewStatus.failure, errorMessage: _mapError(e)));
      return false;
    } catch (e) {
      emit(state.copyWith(status: ReviewStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  void reset() => emit(const ReviewState());

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return 'Không thể gửi đánh giá';
  }
}
