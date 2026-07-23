import 'package:flutter/material.dart';

String orderStatusLabel(String status) {
  return switch (status) {
    'PENDING_PAYMENT' => 'Chờ thanh toán',
    'CONFIRMED' => 'Đã xác nhận',
    'PROCESSING' => 'Đang xử lý',
    'SHIPPING' => 'Đang giao',
    'DELIVERED' => 'Đã giao',
    'COMPLETED' => 'Hoàn thành',
    'CANCELLED' => 'Đã hủy',
    _ => status,
  };
}

Color orderStatusColor(String status) {
  return switch (status) {
    'PENDING_PAYMENT' => Colors.orange,
    'CONFIRMED' => Colors.blue,
    'PROCESSING' => Colors.cyan,
    'SHIPPING' => Colors.indigo,
    'DELIVERED' => Colors.green,
    'COMPLETED' => Colors.green.shade700,
    'CANCELLED' => Colors.red,
    _ => Colors.grey,
  };
}

String paymentStatusLabel(String status) {
  return switch (status) {
    'UNPAID' => 'Chưa thanh toán',
    'PAID' => 'Đã thanh toán',
    'REFUNDED' => 'Đã hoàn tiền',
    _ => status,
  };
}

Color paymentStatusColor(String status) {
  return switch (status) {
    'UNPAID' => Colors.orange,
    'PAID' => Colors.green,
    'REFUNDED' => Colors.deepOrange,
    _ => Colors.grey,
  };
}
