import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../data/models/cart_models.dart';
import '../bloc/cart_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().load();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: BlocConsumer<CartBloc, CartState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.cart.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = state.cart;
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Giỏ hàng trống'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              _CouponSection(controller: _couponController, cart: cart),
              _SummarySection(cart: cart),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItemModel item;

  String get _variantLabel {
    final parts = [item.color, item.size].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isEmpty ? item.sku : parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => context.read<CartBloc>().removeItem(item.id),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xóa',
          ),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: resolveImageUrl(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_variantLabel, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(formatVnd(item.unitPrice), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onPressed: item.quantity <= 1
                              ? null
                              : () => context.read<CartBloc>().updateQuantity(item.id, item.quantity - 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onPressed: item.quantity >= item.availableStock
                              ? null
                              : () => context.read<CartBloc>().updateQuantity(item.id, item.quantity + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: onPressed == null ? Colors.grey : null),
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.controller, required this.cart});

  final TextEditingController controller;
  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mã giảm giá', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (cart.couponCode != null) ...[
            Row(
              children: [
                Expanded(child: Text('Đã áp dụng: ${cart.couponCode}', style: const TextStyle(color: AppColors.primary))),
                TextButton(onPressed: () => context.read<CartBloc>().removeCoupon(), child: const Text('Gỡ')),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => context.read<CartBloc>().setCouponInput(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<CartBloc>().applyCoupon(),
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.cart});

  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _SummaryRow(label: 'Tạm tính', value: formatVnd(cart.subtotal)),
            if (cart.discountAmount > 0)
              _SummaryRow(label: 'Giảm giá', value: '- ${formatVnd(cart.discountAmount)}', valueColor: AppColors.error),
            const Divider(),
            _SummaryRow(
              label: 'Tổng cộng',
              value: formatVnd(cart.total),
              bold: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanh toán sẽ có ở Phase 4')),
                  );
                },
                child: const Text('Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 18 : 14,
      color: valueColor,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
