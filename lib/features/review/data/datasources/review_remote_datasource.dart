import '../../../../core/network/dio_client.dart';
import '../models/review_models.dart';

class ReviewRemoteDataSource {
  ReviewRemoteDataSource(this._client);

  final DioClient _client;

  Future<ReviewSummaryModel> createReview({
    required int orderItemId,
    required int rating,
    String? content,
  }) async {
    final response = await _client.dio.post('/reviews', data: {
      'orderItemId': orderItemId,
      'rating': rating,
      if (content != null && content.isNotEmpty) 'content': content,
    });
    return ReviewSummaryModel.fromJson(response.data?['data'] as Map<String, dynamic>);
  }
}
