import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';
import 'package:go_router/go_router.dart';

/// Chat list with demo conversations
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static final _demoChats = [
    _ChatItem(
      name: 'ورشة الخليج للسيارات',
      lastMessage: 'تم الانتهاء من تغيير الزيت وفلتر الهواء ✅',
      time: 'منذ 5 د',
      unread: 2,
      isOnline: true,
      isWorkshop: true,
    ),
    _ChatItem(
      name: 'قطع غيار الدوحة',
      lastMessage: 'القطعة متوفرة، يمكنك الطلب الآن',
      time: 'منذ 30 د',
      unread: 1,
      isOnline: true,
      isWorkshop: false,
    ),
    _ChatItem(
      name: 'مركز الريان للصيانة',
      lastMessage: 'مرحباً، كيف يمكنني مساعدتك؟',
      time: 'أمس',
      unread: 0,
      isOnline: false,
      isWorkshop: true,
    ),
    _ChatItem(
      name: 'ورشة السرعة',
      lastMessage: 'تم إرسال الفاتورة 📄',
      time: 'الأحد',
      unread: 0,
      isOnline: false,
      isWorkshop: true,
    ),
    _ChatItem(
      name: 'متجر كفرات قطر',
      lastMessage: 'شكراً لتعاملك معنا، نتمنى لك قيادة آمنة',
      time: 'السبت',
      unread: 0,
      isOnline: true,
      isWorkshop: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(OcSpacing.page, OcSpacing.lg, OcSpacing.page, OcSpacing.md),
              child: Row(
                children: [
                  const Text(
                    'المحادثات',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: OcColors.accent,
                      borderRadius: BorderRadius.circular(OcRadius.pill),
                    ),
                    child: Text(
                      '${_demoChats.where((c) => c.unread > 0).length} جديد',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: OcColors.onAccent),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: OcColors.surfaceCard,
                  borderRadius: BorderRadius.circular(OcRadius.searchBar),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: OcColors.textMuted, size: 18),
                    SizedBox(width: 8),
                    Text('ابحث في المحادثات...', style: TextStyle(color: OcColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OcSpacing.md),

            // Chat list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  0, 0, 0,
                  OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.lg,
                ),
                itemCount: _demoChats.length,
                itemBuilder: (_, i) {
                  final chat = _demoChats[i];
                  return _ChatTile(chat: chat, onTap: () {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isWorkshop;

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.isWorkshop,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page, vertical: 10),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: chat.isWorkshop
                        ? OcColors.accent.withValues(alpha: 0.12)
                        : const Color(0xFF1976D2).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    chat.isWorkshop ? Icons.build_rounded : Icons.store_rounded,
                    color: chat.isWorkshop ? OcColors.accent : const Color(0xFF1976D2),
                    size: 24,
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: OcColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: OcColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: chat.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                            color: OcColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: chat.unread > 0 ? OcColors.accent : OcColors.textMuted,
                          fontWeight: chat.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: chat.unread > 0 ? OcColors.textPrimary : OcColors.textSecondary,
                            fontWeight: chat.unread > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: OcColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat.unread}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: OcColors.onAccent),
                          ),
                        ),
                    ],
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
