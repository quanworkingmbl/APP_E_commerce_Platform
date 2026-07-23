class CreatePaymentModel {
  const CreatePaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.orderNumber,
    required this.txnRef,
    required this.paymentUrl,
    required this.status,
  });

  final int paymentId;
  final int orderId;
  final String orderNumber;
  final String txnRef;
  final String paymentUrl;
  final String status;

  factory CreatePaymentModel.fromJson(Map<String, dynamic> json) {
    return CreatePaymentModel(
      paymentId: json['paymentId'] as int,
      orderId: json['orderId'] as int,
      orderNumber: json['orderNumber'] as String,
      txnRef: json['txnRef'] as String,
      paymentUrl: json['paymentUrl'] as String,
      status: json['status'] as String,
    );
  }
}

class PaymentStatusModel {
  const PaymentStatusModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paid,
    this.transactionStatus,
    this.txnRef,
  });

  final int orderId;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;
  final String? transactionStatus;
  final String? txnRef;
  final bool paid;

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      orderId: json['orderId'] as int,
      orderNumber: json['orderNumber'] as String,
      orderStatus: json['orderStatus'] as String,
      paymentStatus: json['paymentStatus'] as String,
      transactionStatus: json['transactionStatus'] as String?,
      txnRef: json['txnRef'] as String?,
      paid: json['paid'] as bool? ?? false,
    );
  }
}
