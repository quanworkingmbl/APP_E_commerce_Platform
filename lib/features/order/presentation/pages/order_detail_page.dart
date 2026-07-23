import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/order_status_utils.dart';
import '../bloc/order_bloc.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().loadOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn')),
      body: BlocConsumer<OrderBloc, OrderState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatusEnum.loading && state.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = state.selectedOrder;
          if (order == null) {
            return Center(child: Text(state.errorMessage ?? 'Không tìm thấy đơn'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(orderStatusLabel(order.status)),
                            backgroundColor: orderStatusColor(order.status).withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: orderStatusColor(order.status)),
                          ),
                          Chip(
                            label: Text(paymentStatusLabel(order.paymentStatus)),
                            backgroundColor: paymentStatusColor(order.paymentStatus).withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: paymentStatusColor(order.paymentStatus)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Người nhận: ${order.recipientName}'),
                      Text('SĐT: ${order.recipientPhone}'),
                      Text('Địa chỉ: ${order.shippingAddress}'),
                      if (order.shippingMethodName != null) Text('Giao hàng: ${order.shippingMethodName}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ...order.items.map((item) => ListTile(
                          title: Text(item.productName),
                          subtitle: Text('${item.sku} · x${item.quantity}'),
                          trailing: Text(formatVnd(item.lineTotal)),
                        )),
                    if (order.status == 'DELIVERED' || order.status == 'COMPLETED') ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: order.items.map((item) {
                            return OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/orders/${order.id}/review?orderItemId=${item.id}&productName=${Uri.encodeComponent(item.productName)}',
                              ),
                              icon: const Icon(Icons.rate_review_outlined, size: 18),
                              label: Text('Đánh giá ${item.productName}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow('Tạm tính', formatVnd(order.subtotal)),
                          _SummaryRow('Phí ship', formatVnd(order.shippingFee)),
                          if (order.discountAmount > 0) _SummaryRow('Giảm giá', '- ${formatVnd(order.discountAmount)}'),
                          _SummaryRow('Tổng', formatVnd(order.totalAmount), bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lịch sử trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ...order.statusHistory.map((h) {
                        final date = DateTime.tryParse(h.createdAt);
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.circle, size: 12, color: orderStatusColor(h.status)),
                                  Container(width: 2, height: 40, color: Colors.grey.shade300),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(orderStatusLabel(h.status), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (date != null)
                                      Text(DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    if (h.note != null && h.note!.isNotEmpty) Text(h.note!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              if (order.status == 'DELIVERED' || order.status == 'COMPLETED') ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/orders/${order.id}/return'),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Yêu cầu trả hàng'),
                ),
              ],
              if (order.status == 'PENDING_PAYMENT') ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/payment/${order.id}'),
                  child: const Text('Thanh toán ngay'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: state.status == OrderStatusEnum.updating
                      ? null
                      : () => context.read<OrderBloc>().cancelOrder(order.id),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Hủy đơn'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : null, color: bold ? AppColors.primary : null)),
        ],
      ),
    );
  }
}
