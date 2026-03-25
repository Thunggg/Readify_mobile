import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_list_screen.dart';

class NotificationPreviewOverlay extends StatelessWidget {
  final List<NotificationModel> notifications;
  final VoidCallback onViewAll;
  final Function(NotificationModel) onNotificationTap;

  const NotificationPreviewOverlay({
    super.key,
    required this.notifications,
    required this.onViewAll,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mới nhất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
                ],
              ),
            ),
            const Divider(height: 1),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Không có thông báo mới', style: TextStyle(color: Colors.grey))),
              )
            else
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return NotificationPreviewItem(
                      notification: n,
                      onTap: () => onNotificationTap(n),
                    );
                  },
                ),
              ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                // Mark all as read action could go here or in onViewAll
                onViewAll();
              },
              child: const Text('Đánh dấu đã đọc tất cả'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPreviewItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationPreviewItem({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.transparent : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
