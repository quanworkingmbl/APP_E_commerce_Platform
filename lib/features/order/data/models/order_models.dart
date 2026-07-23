class AddressModel {
  const AddressModel({
    required this.id,
    required this.recipientName,
    required this.phone,
    this.province,
    this.district,
    this.ward,
    required this.addressLine,
    required this.fullAddress,
    required this.isDefault,
  });

  final int id;
  final String recipientName;
  final String phone;
  final String? province;
  final String? district;
  final String? ward;
  final String addressLine;
  final String fullAddress;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      recipientName: json['recipientName'] as String,
      phone: json['phone'] as String,
      province: json['province'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      addressLine: json['addressLine'] as String,
      fullAddress: json['fullAddress'] as String? ?? json['addressLine'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipientName': recipientName,
        'phone': phone,
        'province': province,
        'district': district,
        'ward': ward,
        'addressLine': addressLine,
        'isDefault': isDefault,
      };
}

class ShippingMethodModel {
  const ShippingMethodModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.baseFee,
    required this.feePerKg,
    this.estimatedDays,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final double baseFee;
  final double feePerKg;
  final int? estimatedDays;

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseFee: (json['baseFee'] as num).toDouble(),
      feePerKg: (json['feePerKg'] as num).toDouble(),
      estimatedDays: json['estimatedDays'] as int?,
    );
  }
}

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.sku,
    this.variantLabel,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final int id;
  final String productName;
  final String sku;
  final String? variantLabel;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productName: json['productName'] as String,
      sku: json['sku'] as String,
      variantLabel: json['variantLabel'] as String?,
      imageUrl: json['imageUrl'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }
}

class OrderStatusHistoryModel {
  const OrderStatusHistoryModel({
    required this.status,
    this.note,
    this.actorEmail,
    required this.createdAt,
  });

  final String status;
  final String? note;
  final String? actorEmail;
  final String createdAt;

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      status: json['status'] as String,
      note: json['note'] as String?,
      actorEmail: json['actorEmail'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}

class OrderSummaryModel {
  const OrderSummaryModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.itemCount,
    required this.recipientName,
    required this.createdAt,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final int itemCount;
  final String recipientName;
  final String createdAt;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      itemCount: json['itemCount'] as int? ?? 0,
      recipientName: json['recipientName'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class OrderDetailModel extends OrderSummaryModel {
  const OrderDetailModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.paymentStatus,
    required super.totalAmount,
    required super.itemCount,
    required super.recipientName,
    required super.createdAt,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    this.couponCode,
    this.shippingMethodName,
    required this.recipientPhone,
    required this.shippingAddress,
    this.note,
    required this.items,
    required this.statusHistory,
  });

  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final String? couponCode;
  final String? shippingMethodName;
  final String recipientPhone;
  final String shippingAddress;
  final String? note;
  final List<OrderItemModel> items;
  final List<OrderStatusHistoryModel> statusHistory;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final historyJson = json['statusHistory'] as List<dynamic>? ?? [];
    return OrderDetailModel(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      itemCount: json['itemCount'] as int? ?? itemsJson.length,
      recipientName: json['recipientName'] as String,
      createdAt: json['createdAt'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shippingFee'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      shippingMethodName: json['shippingMethodName'] as String?,
      recipientPhone: json['recipientPhone'] as String,
      shippingAddress: json['shippingAddress'] as String,
      note: json['note'] as String?,
      items: itemsJson.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      statusHistory: historyJson.map((e) => OrderStatusHistoryModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class PageResult<T> {
  const PageResult({required this.items, required this.total, required this.page, required this.size});

  final List<T> items;
  final int total;
  final int page;
  final int size;

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final content = json['content'] as List<dynamic>? ?? [];
    return PageResult(
      items: content.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      total: json['totalElements'] as int? ?? content.length,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? content.length,
    );
  }
}
