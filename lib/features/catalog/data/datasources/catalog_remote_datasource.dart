import '../../../../core/network/dio_client.dart';
import '../models/catalog_models.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<PageResult<ProductSummaryModel>> getProducts({
    int page = 0,
    int size = 20,
    String? search,
    int? categoryId,
    int? brandId,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/catalog/products',
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (brandId != null) 'brandId': brandId,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return PageResult.fromJson(data, ProductSummaryModel.fromJson);
  }

  Future<ProductDetailModel> getProductBySlug(String slug) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/catalog/products/$slug');
    final data = response.data?['data'] as Map<String, dynamic>;
    return ProductDetailModel.fromJson(data);
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/catalog/categories');
    final data = response.data?['data'] as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
