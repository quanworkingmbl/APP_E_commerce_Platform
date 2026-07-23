import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/checkout_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == CheckoutStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CheckoutStatus.failure && state.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Lỗi'),
                  ElevatedButton(onPressed: () => context.read<CheckoutBloc>().init(), child: const Text('Thử lại')),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StepDot(label: '1', title: 'Địa chỉ', active: state.step >= 0, done: state.step > 0),
                    const Expanded(child: Divider()),
                    _StepDot(label: '2', title: 'Giao hàng', active: state.step >= 1, done: state.step > 1),
                    const Expanded(child: Divider()),
                    _StepDot(label: '3', title: 'Tóm tắt', active: state.step >= 2, done: false),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: switch (state.step) {
                    0 => _AddressStep(state: state),
                    1 => _ShippingStep(state: state),
                    _ => _SummaryStep(state: state),
                  },
                ),
              ),
              _BottomBar(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.title, required this.active, required this.done});

  final String label;
  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.primary : Colors.grey;
    return Column(
      children: [
        CircleAvatar(radius: 14, backgroundColor: color, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({required this.state});
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...state.addresses.map((a) => RadioListTile<int>(
              value: a.id,
              groupValue: state.selectedAddressId,
              onChanged: (v) => context.read<CheckoutBloc>().selectAddress(v!),
              title: Text(a.recipientName),
              subtitle: Text(a.fullAddress),
              secondary: a.isDefault ? const Chip(label: Text('Mặc định')) : null,
            )),
        TextButton(onPressed: () => context.push('/addresses'), child: const Text('Quản lý địa chỉ')),
      ],
    );
  }
}

class _ShippingStep extends StatelessWidget {
  const _ShippingStep({required this.state});
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: state.shippingMethods.map((m) => RadioListTile<int>(
            value: m.id,
            groupValue: state.selectedShippingId,
            onChanged: (v) => context.read<CheckoutBloc>().selectShipping(v!),
            title: Text(m.name),
            subtitle: Text('${formatVnd(m.baseFee)}${m.estimatedDays != null ? ' · ${m.estimatedDays} ngày' : ''}'),
          )).toList(),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.state});
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${cart.items.length} sản phẩm', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...cart.items.map((i) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(i.productName),
              subtitle: Text('x${i.quantity}'),
              trailing: Text(formatVnd(i.lineTotal)),
            )),
        const Divider(),
        _Row(label: 'Tạm tính', value: formatVnd(cart.subtotal)),
        if (cart.discountAmount > 0) _Row(label: 'Giảm giá', value: '- ${formatVnd(cart.discountAmount)}'),
        _Row(label: 'Tổng', value: formatVnd(cart.total), bold: true),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: 'Ghi chú đơn hàng'),
          onChanged: context.read<CheckoutBloc>().setNote,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state});
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CheckoutBloc>();
    final isLast = state.step >= 2;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (state.step > 0)
              OutlinedButton(onPressed: bloc.prevStep, child: const Text('Quay lại')),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: state.status == CheckoutStatus.submitting
                    ? null
                    : () async {
                        if (!isLast) {
                          bloc.nextStep();
                          return;
                        }
                        final ok = await bloc.placeOrder();
                        if (!context.mounted) return;
                        if (ok) {
                          final order = context.read<CheckoutBloc>().state.createdOrder;
                          getIt<CartBloc>().load();
                          if (order != null) {
                            context.go('/payment/${order.id}');
                          }
                        }
                      },
                child: Text(isLast
                    ? (state.status == CheckoutStatus.submitting ? 'Đang xử lý...' : 'Đặt hàng')
                    : 'Tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
