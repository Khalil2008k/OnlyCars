import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationServiceProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadNotifCountProvider);
            },
            child: const Text('قراءة الكل'),
          ),
        ],
      ),
      body: notifsAsync.when(
        data: (notifs) => notifs.isEmpty
            ? const OcEmptyState(
                icon: Icons.notifications_none_rounded,
                message: 'لا توجد إشعارات',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(OcSpacing.lg),
                itemCount: notifs.length,
                separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.sm),
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return GestureDetector(
                    onTap: () async {
                      // Mark as read
                      if (!n.isRead) {
                        await ref.read(notificationServiceProvider).markAsRead(n.id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadNotifCountProvider);
                      }
                      // Navigate based on type
                      if (!context.mounted) return;
                      final data = n.data;
                      switch (n.type) {
                        case 'order_status':
                        case 'order':
                          if (data.containsKey('order_id')) context.push('/order/${data['order_id']}');
                          break;
                        case 'chat_message':
                        case 'chat':
                          if (data.containsKey('room_id')) context.push('/chat/${data['room_id']}');
                          break;
                        case 'diagnosis_report':
                        case 'diagnosis':
                          if (data.containsKey('report_id')) context.push('/diagnosis/${data['report_id']}');
                          break;
                        case 'workshop_bill':
                          if (data.containsKey('bill_id')) context.push('/bill/${data['bill_id']}');
                          break;
                        case 'review':
                          if (data.containsKey('order_id')) context.push('/rate/${data['order_id']}');
                          break;
                      }
                    },
                    child: Container(
                    padding: const EdgeInsets.all(OcSpacing.lg),
                    decoration: BoxDecoration(
                      color: n.isRead ? OcColors.surfaceCard : OcColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(OcRadius.md),
                      border: Border.all(color: n.isRead ? OcColors.border : OcColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: OcColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(OcRadius.sm),
                          ),
                          child: Icon(_iconForType(n.type), color: OcColors.primary, size: 20),
                        ),
                        const SizedBox(width: OcSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.titleAr, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(n.bodyAr, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: OcColors.primary, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل الإشعارات', onRetry: () => ref.invalidate(notificationsProvider)),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'order' || 'order_status' => Icons.receipt_long_rounded,
      'chat' || 'chat_message' => Icons.chat_rounded,
      'review' => Icons.star_rounded,
      'diagnosis' || 'diagnosis_report' => Icons.assignment_rounded,
      'workshop_bill' => Icons.receipt_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}
