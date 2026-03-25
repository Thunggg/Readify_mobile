import 'package:flutter/material.dart';
import 'package:mobile/features/notification/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_item_widget.dart';
import '../services/notification_service.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationProvider _provider = NotificationProvider();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _provider.load(unreadOnly: _unreadOnly).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all),
            onPressed: () {
              _provider.markAllAsRead().then((_) {
                if (mounted) setState(() {});
              });
            },
          ),
          PopupMenuButton<bool>(
            onSelected: (val) {
              setState(() {
                _unreadOnly = val;
              });
              _load();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: false, child: Text('Show all')),
              const PopupMenuItem(value: true, child: Text('Unread only')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _load(),
              child: _provider.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            _unreadOnly ? 'No unread notifications' : 'No notifications yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _provider.notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = _provider.notifications[index];
                        return NotificationItemWidget(
                          notification: notification,
                          onTap: () async {
                             // Mark as read and open detail
                             _provider.markAsRead(notification.id);
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => NotificationDetailScreen(notificationId: notification.id),
                               ),
                             );
                             if (mounted) setState(() {});
                          },
                        );
                      },
                    ),
            ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final String notificationId;
  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    // A simplified detail screen for now
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detail')),
      body: FutureBuilder(
        future: NotificationService().getDetail(notificationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notification = snapshot.data as NotificationModel;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.notifications, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(notification.title, style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 4),
                           Text(notification.formattedDate, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(notification.message, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
