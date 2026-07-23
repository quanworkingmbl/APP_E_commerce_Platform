class ReturnItemModel {
  const ReturnItemModel({
    required this.orderItemId,
    required this.productName,
    required this.sku,
    required this.quantity,
    this.itemReason,
  });

  final int orderItemId;
  final String productName;
  final String sku;
  final int quantity;
  final String? itemReason;

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      orderItemId: json['orderItemId'] as int,
      productName: json['productName'] as String,
      sku: json['sku'] as String,
      quantity: json['quantity'] as int,
      itemReason: json['itemReason'] as String?,
    );
  }
}

class ReturnDetailModel {
  const ReturnDetailModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.reason,
    required this.items,
    required this.createdAt,
  });

  final int id;
  final int orderId;
  final String orderNumber;
  final String status;
  final String reason;
  final List<ReturnItemModel> items;
  final String createdAt;

  factory ReturnDetailModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    return ReturnDetailModel(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String,
      items: items.map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['createdAt'] as String,
    );
  }
}
