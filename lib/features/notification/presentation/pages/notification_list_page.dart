import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/notification_bloc.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => context.read<NotificationBloc>().markAllRead(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationLoadStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Không có thông báo'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationBloc>().load(),
            child: ListView.separated(
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = state.items[index];
                final date = DateTime.tryParse(n.createdAt);
                return ListTile(
                  leading: Icon(
                    n.read ? Icons.notifications_none : Icons.notifications_active,
                    color: n.read ? Colors.grey : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (date != null)
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (!n.read) context.read<NotificationBloc>().markRead(n.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
