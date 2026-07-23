import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/order_models.dart';
import '../bloc/address_bloc.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().load();
  }

  Future<void> _openForm({AddressModel? editing}) async {
    final nameCtrl = TextEditingController(text: editing?.recipientName ?? '');
    final phoneCtrl = TextEditingController(text: editing?.phone ?? '');
    final lineCtrl = TextEditingController(text: editing?.addressLine ?? '');
    final provinceCtrl = TextEditingController(text: editing?.province ?? '');
    final districtCtrl = TextEditingController(text: editing?.district ?? '');
    final wardCtrl = TextEditingController(text: editing?.ward ?? '');
    var isDefault = editing?.isDefault ?? false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(editing == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Người nhận')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại')),
                TextField(controller: lineCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ')),
                TextField(controller: wardCtrl, decoration: const InputDecoration(labelText: 'Phường/Xã')),
                TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'Quận/Huyện')),
                TextField(controller: provinceCtrl, decoration: const InputDecoration(labelText: 'Tỉnh/TP')),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (v) => setState(() => isDefault = v ?? false),
                  title: const Text('Đặt làm mặc định'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;

    final model = AddressModel(
      id: editing?.id ?? 0,
      recipientName: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      province: provinceCtrl.text.trim().isEmpty ? null : provinceCtrl.text.trim(),
      district: districtCtrl.text.trim().isEmpty ? null : districtCtrl.text.trim(),
      ward: wardCtrl.text.trim().isEmpty ? null : wardCtrl.text.trim(),
      addressLine: lineCtrl.text.trim(),
      fullAddress: lineCtrl.text.trim(),
      isDefault: isDefault,
    );

    if (!context.mounted) return;
    await context.read<AddressBloc>().save(model, isNew: editing == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == AddressStatus.loading && state.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.addresses.isEmpty) {
            return const Center(child: Text('Chưa có địa chỉ'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final addr = state.addresses[index];
              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(addr.recipientName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      if (addr.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Mặc định', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                        ),
                    ],
                  ),
                  subtitle: Text('${addr.phone}\n${addr.fullAddress}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await _openForm(editing: addr);
                      } else if (v == 'default') {
                        await context.read<AddressBloc>().setDefault(addr.id);
                      } else if (v == 'delete') {
                        await context.read<AddressBloc>().delete(addr.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      if (!addr.isDefault) const PopupMenuItem(value: 'default', child: Text('Đặt mặc định')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
