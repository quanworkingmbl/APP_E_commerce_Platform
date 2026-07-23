class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.variantId,
    required this.sku,
    required this.productName,
    required this.productSlug,
    this.imageUrl,
    this.size,
    this.color,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.availableStock,
  });

  final int id;
  final int variantId;
  final String sku;
  final String productName;
  final String productSlug;
  final String? imageUrl;
  final String? size;
  final String? color;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int availableStock;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      variantId: json['variantId'] as int,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      productSlug: json['productSlug'] as String,
      imageUrl: json['imageUrl'] as String?,
      size: json['size'] as String?,
      color: json['color'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      availableStock: json['availableStock'] as int,
    );
  }
}

class CartModel {
  const CartModel({
    required this.id,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    this.couponCode,
    required this.discountAmount,
    required this.total,
  });

  final int id;
  final List<CartItemModel> items;
  final int itemCount;
  final double subtotal;
  final String? couponCode;
  final double discountAmount;
  final double total;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      id: json['id'] as int,
      items: itemsJson.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      itemCount: json['itemCount'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  static const empty = CartModel(
    id: 0,
    items: [],
    itemCount: 0,
    subtotal: 0,
    discountAmount: 0,
    total: 0,
  );
}
