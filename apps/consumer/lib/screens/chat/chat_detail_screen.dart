import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatDetailScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Mock messages for UI demo
  final List<Map<String, dynamic>> _messages = [
    {'text': 'السلام عليكم، سيارتي تحتاج فحص', 'isMe': true, 'time': '10:30'},
    {'text': 'وعليكم السلام! أهلاً، أي نوع سيارة؟', 'isMe': false, 'time': '10:31'},
    {'text': 'تويوتا كامري 2022', 'isMe': true, 'time': '10:32'},
    {'text': 'تمام، ممكن تمر علينا بكرة الصبح؟', 'isMe': false, 'time': '10:33'},
    {'text': 'إن شاء الله، الساعة 9؟', 'isMe': true, 'time': '10:34'},
    {'text': 'تمام 👍', 'isMe': false, 'time': '10:34'},
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': TimeOfDay.now().format(context)});
    });
    _msgCtrl.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('محادثة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMe = msg['isMe'] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: OcSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? OcColors.primary : OcColors.surfaceCard,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isMe ? OcColors.textOnPrimary : OcColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            color: isMe
                                ? OcColors.textOnPrimary.withValues(alpha: 0.7)
                                : OcColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: OcSpacing.md, vertical: OcSpacing.sm),
            decoration: const BoxDecoration(
              color: OcColors.surfaceCard,
              border: Border(top: BorderSide(color: OcColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: OcColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: OcColors.primary,
                      borderRadius: BorderRadius.circular(OcRadius.md),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: OcColors.textOnPrimary, size: 20),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
