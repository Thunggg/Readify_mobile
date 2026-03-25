import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: notification.isRead
                  ? Colors.grey[700]
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getIcon(),
                color: notification.isRead
                    ? Colors.white70
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.formattedDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: notification.isRead ? Colors.grey[500] : Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'order':
        return Icons.shopping_bag;
      case 'promo':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }
}
