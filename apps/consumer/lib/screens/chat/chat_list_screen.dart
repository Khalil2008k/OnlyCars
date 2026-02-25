import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('المحادثات')),
      body: roomsAsync.when(
        data: (rooms) => rooms.isEmpty
            ? const OcEmptyState(icon: Icons.chat_outlined, message: 'لا توجد محادثات بعد')
            : ListView.separated(
                padding: const EdgeInsets.all(OcSpacing.lg),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = rooms[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: OcSpacing.sm),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: OcColors.surfaceLight,
                      child: const Icon(Icons.person, color: OcColors.textSecondary),
                    ),
                    title: Text(r.otherUser?['name'] ?? 'مستخدم', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: r.lastMessage != null
                        ? Text(r.lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary))
                        : null,
                    trailing: r.lastMessageAt != null
                        ? Text(_timeAgo(r.lastMessageAt!),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary))
                        : null,
                    onTap: () {/* Navigate to chat detail */},
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل المحادثات', onRetry: () => ref.invalidate(chatRoomsProvider)),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    return '${diff.inDays}ي';
  }
}
