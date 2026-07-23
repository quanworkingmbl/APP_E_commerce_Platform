import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentFailurePage extends StatelessWidget {
  const PaymentFailurePage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, size: 96, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                'Thanh toán thất bại',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Giao dịch không thành công hoặc đã bị hủy. Bạn có thể thử lại trước khi đơn hết hạn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/payment/$orderId'),
                  child: const Text('Thử thanh toán lại'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/orders/$orderId'),
                  child: const Text('Về chi tiết đơn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
