import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/catalog_models.dart';
import '../../data/repositories/catalog_repository.dart';

part 'product_detail_state.dart';

class ProductDetailBloc extends Cubit<ProductDetailState> {
  ProductDetailBloc(this._repository) : super(const ProductDetailState.initial());

  final CatalogRepository _repository;

  Future<void> load(String slug) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    try {
      final product = await _repository.getProduct(slug);
      final variants = product.variants.where((v) => v.active).toList();
      emit(state.copyWith(
        status: ProductDetailStatus.success,
        product: product,
        selectedVariant: variants.isNotEmpty ? variants.first : null,
      ));
    } catch (_) {
      emit(state.copyWith(status: ProductDetailStatus.failure, errorMessage: 'Không tải được chi tiết'));
    }
  }

  void selectVariant(ProductVariantModel variant) {
    emit(state.copyWith(selectedVariant: variant));
  }
}
