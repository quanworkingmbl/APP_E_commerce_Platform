part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    required this.status,
    this.product,
    this.selectedVariant,
    this.errorMessage,
  });

  const ProductDetailState.initial()
      : status = ProductDetailStatus.initial,
        product = null,
        selectedVariant = null,
        errorMessage = null;

  final ProductDetailStatus status;
  final ProductDetailModel? product;
  final ProductVariantModel? selectedVariant;
  final String? errorMessage;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    ProductDetailModel? product,
    ProductVariantModel? selectedVariant,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, selectedVariant, errorMessage];
}
