import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      (user?.fullName.isNotEmpty == true ? user!.fullName[0] : '?').toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user?.fullName ?? 'Khách'),
                  subtitle: Text(user?.email ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              _MenuTile(icon: Icons.receipt_long_outlined, title: 'Đơn hàng', onTap: () => context.push('/orders')),
              _MenuTile(icon: Icons.favorite_border, title: 'Yêu thích', subtitle: 'Phase 2', disabled: true),
              _MenuTile(icon: Icons.location_on_outlined, title: 'Địa chỉ', onTap: () => context.push('/addresses')),
              _MenuTile(icon: Icons.notifications_outlined, title: 'Thông báo', onTap: () => context.push('/notifications')),
              _MenuTile(icon: Icons.lock_outline, title: 'Đổi mật khẩu', subtitle: 'Phase 1+', disabled: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AuthCubit>().logout();
                  if (context.mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.disabled = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: !disabled,
        onTap: disabled ? null : onTap,
        leading: Icon(icon, color: disabled ? Colors.grey : AppColors.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: disabled ? const Text('Soon', style: TextStyle(color: Colors.grey)) : const Icon(Icons.chevron_right),
      ),
    );
  }
}
