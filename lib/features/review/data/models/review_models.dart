class ReviewSummaryModel {
  const ReviewSummaryModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.rating,
    this.content,
    required this.status,
  });

  final int id;
  final int productId;
  final String productName;
  final int rating;
  final String? content;
  final String status;

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryModel(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      rating: json['rating'] as int,
      content: json['content'] as String?,
      status: json['status'] as String,
    );
  }
}
