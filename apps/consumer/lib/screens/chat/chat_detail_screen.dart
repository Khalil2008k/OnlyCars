import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatDetailScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  StreamSubscription? _subscription;
  bool _isLoading = true;
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = OcSupabase.currentUserId;
    _loadMessages();
    _markAsRead();
  }

  Future<void> _loadMessages() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final msgs = await chatService.getMessages(widget.roomId, limit: 100);
      if (!mounted) return;
      setState(() {
        _messages = msgs.reversed.toList(); // oldest first
        _isLoading = false;
      });
      _scrollToBottom();
      _subscribeToNewMessages();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _subscribeToNewMessages() {
    final chatService = ref.read(chatServiceProvider);
    _subscription = chatService.subscribeToMessages(widget.roomId).listen((msg) {
      if (!mounted) return;
      setState(() {
        // Avoid duplicates
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
        }
      });
      _scrollToBottom();
      // Mark incoming messages as read
      if (msg.senderId != _currentUid) {
        chatService.markAsRead(widget.roomId);
      }
    });
  }

  Future<void> _markAsRead() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.markAsRead(widget.roomId);
    } catch (_) {}
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(roomId: widget.roomId, content: text);
      // Message will appear via subscription
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إرسال الرسالة')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('محادثة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            ref.invalidate(chatRoomsProvider); // refresh unread counts
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('ابدأ المحادثة...', style: TextStyle(color: OcColors.textSecondary)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(OcSpacing.lg),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == _currentUid;

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
                                  // Image message
                                  if (msg.type == 'image' && msg.mediaUrl != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(msg.mediaUrl!, width: 200, fit: BoxFit.cover),
                                    ),
                                    if (msg.content != null && msg.content!.isNotEmpty)
                                      const SizedBox(height: 6),
                                  ],

                                  // Text content
                                  if (msg.content != null && msg.content!.isNotEmpty)
                                    Text(
                                      msg.content!,
                                      style: TextStyle(
                                        color: isMe ? OcColors.textOnPrimary : OcColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  const SizedBox(height: 4),

                                  // Time + read status
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(msg.createdAt),
                                        style: TextStyle(
                                          color: isMe ? OcColors.textOnPrimary.withValues(alpha: 0.7) : OcColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg.isRead ? Icons.done_all : Icons.done,
                                          size: 14,
                                          color: msg.isRead ? Colors.lightBlueAccent : OcColors.textOnPrimary.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ],
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
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      textInputAction: TextInputAction.send,
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
