class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.children = const [],
  });

  final int id;
  final String name;
  final String slug;
  final int? parentId;
  final List<CategoryModel> children;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      parentId: json['parentId'] as int?,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductSummaryModel {
  const ProductSummaryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.categoryName,
    this.primaryImageUrl,
    this.minPrice,
    this.maxPrice,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? categoryName;
  final String? primaryImageUrl;
  final num? minPrice;
  final num? maxPrice;

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      categoryName: json['categoryName'] as String?,
      primaryImageUrl: json['primaryImageUrl'] as String?,
      minPrice: json['minPrice'] as num?,
      maxPrice: json['maxPrice'] as num?,
    );
  }
}

class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    required this.sku,
    this.size,
    this.color,
    required this.price,
    this.comparePrice,
    required this.stockQuantity,
    required this.active,
  });

  final int id;
  final String sku;
  final String? size;
  final String? color;
  final num price;
  final num? comparePrice;
  final int stockQuantity;
  final bool active;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as int,
      sku: json['sku'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      price: json['price'] as num,
      comparePrice: json['comparePrice'] as num?,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }
}

class ProductImageModel {
  const ProductImageModel({required this.url, this.altText, this.primary = false});

  final String url;
  final String? altText;
  final bool primary;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      url: json['url'] as String,
      altText: json['altText'] as String?,
      primary: json['primary'] as bool? ?? false,
    );
  }
}

class ProductDetailModel {
  const ProductDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.variants,
    required this.images,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final List<ProductVariantModel> variants;
  final List<ProductImageModel> images;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PageResult<T> {
  const PageResult({required this.items, required this.total, required this.page, required this.size});

  final List<T> items;
  final int total;
  final int page;
  final int size;

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) mapper) {
    final content = (json['content'] as List<dynamic>).map((e) => mapper(e as Map<String, dynamic>)).toList();
    return PageResult(
      items: content,
      total: json['totalElements'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}
