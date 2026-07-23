import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../order/data/models/order_models.dart';
import '../../../order/data/repositories/order_repository.dart';
import '../../../../core/di/injection.dart';
import '../bloc/return_bloc.dart';

class ReturnRequestPage extends StatefulWidget {
  const ReturnRequestPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  final _reasonController = TextEditingController();
  OrderDetailModel? _order;
  final Map<int, int> _quantities = {};
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await getIt<OrderRepository>().getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        for (final item in order.items) {
          _quantities[item.id] = item.quantity;
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_order == null) return;
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do trả hàng')));
      return;
    }
    final items = _order!.items
        .where((item) => (_quantities[item.id] ?? 0) > 0)
        .map((item) => {
              'orderItemId': item.id,
              'quantity': _quantities[item.id],
            })
        .toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn ít nhất một sản phẩm')));
      return;
    }
    final ok = await context.read<ReturnBloc>().submitReturn(
          orderId: widget.orderId,
          reason: reason,
          items: items,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu trả hàng thành công')));
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu trả hàng')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Không tải được đơn hàng'))
              : BlocConsumer<ReturnBloc, ReturnState>(
                  listener: (context, state) {
                    if (state.errorMessage != null && state.status == ReturnSubmitStatus.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                    }
                  },
                  builder: (context, state) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text('Đơn ${_order!.orderNumber}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        ..._order!.items.map((item) {
                          final qty = _quantities[item.id] ?? 0;
                          return Card(
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text('${item.sku} · tối đa ${item.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: qty > 0
                                        ? () => setState(() => _quantities[item.id] = qty - 1)
                                        : null,
                                  ),
                                  Text('$qty'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: qty < item.quantity
                                        ? () => setState(() => _quantities[item.id] = qty + 1)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reasonController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Lý do trả hàng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: state.status == ReturnSubmitStatus.submitting ? null : _submit,
                          child: Text(state.status == ReturnSubmitStatus.submitting ? 'Đang gửi...' : 'Gửi yêu cầu'),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
