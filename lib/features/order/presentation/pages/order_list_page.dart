import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/order_status_utils.dart';
import '../bloc/order_bloc.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng')),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state.status == OrderStatusEnum.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.orders.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<OrderBloc>().loadOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final date = DateTime.tryParse(order.createdAt);
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/orders/${order.id}'),
                    title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()) : order.createdAt),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: orderStatusColor(order.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            orderStatusLabel(order.status),
                            style: TextStyle(color: orderStatusColor(order.status), fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(formatVnd(order.totalAmount), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
