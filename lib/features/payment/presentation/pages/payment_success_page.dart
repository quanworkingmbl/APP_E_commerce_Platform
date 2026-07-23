import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../order/data/repositories/order_repository.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final _paymentRepo = getIt<PaymentRepository>();
  final _orderRepo = getIt<OrderRepository>();
  var _loading = true;
  String? _orderNumber;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    try {
      await _paymentRepo.getPaymentStatus(widget.orderId);
      final order = await _orderRepo.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _orderNumber = order.orderNumber;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 96, color: Colors.green.shade600),
                    const SizedBox(height: 24),
                    Text(
                      'Thanh toán thành công!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (_orderNumber != null)
                      Text(
                        'Đơn hàng $_orderNumber đã được xác nhận.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!, style: const TextStyle(color: Colors.orange), textAlign: TextAlign.center),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/orders/${widget.orderId}'),
                        child: const Text('Xem chi tiết đơn'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Tiếp tục mua sắm'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
