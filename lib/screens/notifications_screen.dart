import 'dart:async';

import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;
  bool _didInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialLoad) return;
    _didInitialLoad = true;
    final model = SustainabilityProvider.of(context);
    unawaited(model.refreshNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final items =
        _unreadOnly
            ? model.notifications.where((n) => !n.isRead).toList()
            : model.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('notifications', context)),
        actions: [
          TextButton(
            onPressed:
                model.unreadNotificationsCount == 0
                    ? null
                    : () {
                      model.markAllNotificationsRead();
                    },
            child: Text(AppStrings.get('markAllRead', context)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(AppStrings.get('all', context)),
                    icon: const Icon(Icons.list_alt_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(AppStrings.get('unread', context)),
                    icon: const Icon(Icons.mark_email_unread_outlined),
                  ),
                ],
                selected: {_unreadOnly},
                onSelectionChanged:
                    (v) => setState(() => _unreadOnly = v.first),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await model.refreshNotifications();
                },
                child:
                    items.isEmpty
                        ? ListView(
                          children: [
                            const SizedBox(height: 90),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 52,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppStrings.get('noNotifications', context),
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final n = items[index];
                            return _NotificationTile(
                              notification: n,
                              onTap: () {
                                unawaited(model.markNotificationRead(n.id));
                              },
                              onLongPress: () {
                                unawaited(model.toggleNotificationRead(n.id));
                              },
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (notification.kind) {
      NotificationKind.challenge => Icons.flag_outlined,
      NotificationKind.tip => Icons.lightbulb_outline,
      NotificationKind.news => Icons.newspaper_outlined,
    };

    final accent = switch (notification.kind) {
      NotificationKind.challenge => colorScheme.primary,
      NotificationKind.tip => colorScheme.secondary,
      NotificationKind.news => colorScheme.tertiary,
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withAlpha(70)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  notification.isRead
                                      ? colorScheme.onSurface
                                      : accent,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt, context),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime, BuildContext context) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final diffDays = today.difference(day).inDays;

  final time =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  if (diffDays == 0) return '${AppStrings.get('today', context)} • $time';
  if (diffDays == 1) return '${AppStrings.get('yesterday', context)} • $time';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} • $time';
}
