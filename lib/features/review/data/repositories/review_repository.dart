import '../datasources/review_remote_datasource.dart';
import '../models/review_models.dart';

class ReviewRepository {
  ReviewRepository(this._remote);

  final ReviewRemoteDataSource _remote;

  Future<ReviewSummaryModel> createReview({
    required int orderItemId,
    required int rating,
    String? content,
  }) => _remote.createReview(orderItemId: orderItemId, rating: rating, content: content);
}
