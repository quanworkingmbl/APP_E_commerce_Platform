import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/catalog_models.dart';
import '../../data/repositories/catalog_repository.dart';

part 'product_list_state.dart';

class ProductListBloc extends Cubit<ProductListState> {
  ProductListBloc(this._repository) : super(const ProductListState.initial());

  final CatalogRepository _repository;

  Future<void> load({int? categoryId, bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(status: ProductListStatus.loading, page: 0, products: []));
    } else if (state.status == ProductListStatus.loading) {
      return;
    } else {
      emit(state.copyWith(status: ProductListStatus.loading));
    }

    try {
      final categories = state.categories.isEmpty ? await _repository.getCategories() : state.categories;
      final result = await _repository.getProducts(page: 0, size: 20, categoryId: categoryId ?? state.categoryId);
      emit(state.copyWith(
        status: ProductListStatus.success,
        products: result.items,
        categories: categories,
        categoryId: categoryId ?? state.categoryId,
        page: result.page,
        hasMore: result.items.length < result.total,
      ));
    } catch (_) {
      emit(state.copyWith(status: ProductListStatus.failure, errorMessage: 'Không tải được sản phẩm'));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ProductListStatus.loadingMore) return;
    emit(state.copyWith(status: ProductListStatus.loadingMore));
    try {
      final nextPage = state.page + 1;
      final result = await _repository.getProducts(page: nextPage, size: 20, categoryId: state.categoryId);
      emit(state.copyWith(
        status: ProductListStatus.success,
        products: [...state.products, ...result.items],
        page: nextPage,
        hasMore: state.products.length + result.items.length < result.total,
      ));
    } catch (_) {
      emit(state.copyWith(status: ProductListStatus.failure));
    }
  }

  void selectCategory(int? categoryId) {
    load(categoryId: categoryId, refresh: true);
  }
}
