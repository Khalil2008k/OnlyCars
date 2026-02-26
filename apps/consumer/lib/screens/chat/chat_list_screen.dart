import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomsProvider);
    final currentUid = OcSupabase.currentUserId;

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(OcSpacing.lg, OcSpacing.lg, OcSpacing.lg, 0),
              child: Text('المحادثات', style: Theme.of(context).textTheme.headlineMedium),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(OcSpacing.lg),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'ابحث في المحادثات...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),

            // Chat rooms list
            Expanded(
              child: roomsAsync.when(
                data: (rooms) {
                  // Filter by search
                  final filtered = _searchQuery.isEmpty
                      ? rooms
                      : rooms.where((r) {
                          final name = _getOtherName(r, currentUid);
                          return name.toLowerCase().contains(_searchQuery);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const OcEmptyState(
                      icon: Icons.chat_outlined,
                      message: 'لا توجد محادثات',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(chatRoomsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: OcColors.border),
                      itemBuilder: (_, i) => _ChatRoomTile(
                        room: filtered[i],
                        currentUid: currentUid ?? '',
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => OcErrorState(
                  message: 'تعذر تحميل المحادثات',
                  onRetry: () => ref.invalidate(chatRoomsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOtherName(ChatRoom room, String? uid) {
    final other = room.otherUser;
    return other?['name'] ?? 'مستخدم';
  }
}

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoom room;
  final String currentUid;

  const _ChatRoomTile({required this.room, required this.currentUid});

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    if (diff.inDays < 7) return '${diff.inDays}ي';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = room.otherUser;
    final name = other?['name'] ?? 'مستخدم';
    final avatarUrl = other?['avatar_url'] as String?;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: OcSpacing.sm),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: OcColors.surfaceLight,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null ? const Icon(Icons.person, color: OcColors.textSecondary) : null,
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        room.lastMessage ?? 'ابدأ المحادثة...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _timeAgo(room.lastMessageAt),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary),
          ),
        ],
      ),
      onTap: () => context.push('/chat/${room.id}'),
    );
  }
}
