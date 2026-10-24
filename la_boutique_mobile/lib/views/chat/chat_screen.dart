import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../auth/login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastCount = 0;
  bool _started = false;

  final List<String> _quickPrompts = [
    'Tư vấn chọn size 📏',
    'Thời gian giao hàng 🚚',
    'BST Sunset SS26 🌅',
    'Chính sách đổi trả 🔄',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        _started = true;
        final chat = context.read<ChatProvider>();
        chat.loadHistory();
        chat.startPolling();
      }
    });
  }

  @override
  void dispose() {
    if (_started) context.read<ChatProvider>().stopPolling();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    if (customText == null) _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthProvider>().isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.clay500,
                  radius: 18,
                  child: Icon(Icons.support_agent, color: Colors.white, size: 20),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tư vấn La Boutique', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Thường trả lời trong vài phút', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
      body: isAuth ? _buildChat(context) : _buildGuestPrompt(context),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.sand300),
            const SizedBox(height: 16),
            const Text('Đăng nhập để nhắn tin với shop',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text('Tin nhắn gắn với tài khoản của bạn để shop tiện hỗ trợ.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.mute)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.clay500, foregroundColor: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('ĐĂNG NHẬP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    // Tự cuộn xuống khi có tin mới (gửi đi hoặc nhận về qua polling).
    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      _scrollToBottom();
    }

    return Column(
      children: [
        Expanded(
          child: (chatProvider.isLoading && messages.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: AppColors.clay500))
              : messages.isEmpty
                  ? const Center(
                      child: Text('Hãy gửi tin nhắn đầu tiên cho shop nhé!',
                          style: TextStyle(fontSize: 13, color: AppColors.mute)),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg.isFromUser;
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.clay500 : AppColors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(2),
                                bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(14),
                              ),
                              border: isUser ? null : Border.all(color: AppColors.sand200.withValues(alpha: 0.8)),
                              boxShadow: [
                                BoxShadow(color: AppColors.ink.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(msg.text, style: TextStyle(color: isUser ? Colors.white : AppColors.ink, fontSize: 13, height: 1.4)),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.formatDateShort(msg.timestamp),
                                  style: TextStyle(
                                    color: isUser ? Colors.white.withValues(alpha: 0.7) : AppColors.mute.withValues(alpha: 0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),

        // Gợi ý câu hỏi nhanh
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickPrompts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ActionChip(
                label: Text(_quickPrompts[index]),
                onPressed: () => _sendMessage(_quickPrompts[index]),
                backgroundColor: AppColors.white,
                side: BorderSide(color: AppColors.sand200.withValues(alpha: 0.8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                labelStyle: const TextStyle(fontSize: 11, color: AppColors.ink, fontWeight: FontWeight.w500),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Ô nhập
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.sand200)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Nhắn cho La Boutique...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.mute),
                      filled: true,
                      fillColor: AppColors.sand50,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.clay500,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
