part of 'product_list_bloc.dart';

enum ProductListStatus { initial, loading, loadingMore, success, failure }

class ProductListState extends Equatable {
  const ProductListState({
    required this.status,
    this.products = const [],
    this.categories = const [],
    this.categoryId,
    this.page = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  const ProductListState.initial()
      : status = ProductListStatus.initial,
        products = const [],
        categories = const [],
        categoryId = null,
        page = 0,
        hasMore = true,
        errorMessage = null;

  final ProductListStatus status;
  final List<ProductSummaryModel> products;
  final List<CategoryModel> categories;
  final int? categoryId;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductSummaryModel>? products,
    List<CategoryModel>? categories,
    int? categoryId,
    int? page,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      categoryId: categoryId ?? this.categoryId,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, categories, categoryId, page, hasMore, errorMessage];
}
