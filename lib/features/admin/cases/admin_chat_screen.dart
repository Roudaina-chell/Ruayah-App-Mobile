import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/conversation.dart';
import '../../../models/chat_message.dart';
import '../../../services/chat_service.dart';

class AdminChatScreen extends StatefulWidget {
  final Conversation conversation;

  const AdminChatScreen({super.key, required this.conversation});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _chatService = ChatService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _chatService.markSeenByAdmin(widget.conversation.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _textController.clear();

    try {
      await _chatService.sendAdminReply(
        conversationId: widget.conversation.id,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Column(
          children: [
            Text(
              widget.conversation.userName,
              style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              widget.conversation.userPhone,
              style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.messages(widget.conversation.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final messages = snapshot.data ?? [];
                  _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderRole == 'admin';
                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.navy.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        textAlign: TextAlign.right,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        style: TextStyle(color: AppColors.navy, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب الرد...',
                          hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.35)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _isSending ? null : _handleSend,
                    ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 4 : 16),
            bottomRight: Radius.circular(isMe ? 16 : 4),
          ),
        ),
        child: Text(
          message.text,
          textAlign: TextAlign.right,
          style: TextStyle(color: isMe ? Colors.white : AppColors.navy, fontSize: 14),
        ),
      ),
    );
  }
}