import '../datasources/catalog_remote_datasource.dart';
import '../models/catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._remote);

  final CatalogRemoteDataSource _remote;

  Future<PageResult<ProductSummaryModel>> getProducts({
    int page = 0,
    int size = 20,
    String? search,
    int? categoryId,
  }) =>
      _remote.getProducts(page: page, size: size, search: search, categoryId: categoryId);

  Future<ProductDetailModel> getProduct(String slug) => _remote.getProductBySlug(slug);

  Future<List<CategoryModel>> getCategories() => _remote.getCategories();
}
