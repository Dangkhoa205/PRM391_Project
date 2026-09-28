import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'Tư vấn chọn size 📏',
    'Thời gian giao hàng 🚚',
    'BST Sunset SS26 🌅',
    'Chính sách đổi trả 🔄',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text;
    if (text.trim().isEmpty) return;

    context.read<ChatProvider>().sendMessage(text);
    if (customText == null) {
      _textController.clear();
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

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
                Text('Trực tuyến 24/7', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.clay500 : AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(2),
                        bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(14),
                      ),
                      border: isUser ? null : Border.all(color: AppColors.sand200),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppColors.ink,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatDateShort(msg.timestamp),
                          style: TextStyle(
                            color: isUser ? Colors.white.withOpacity(0.7) : AppColors.mute.withOpacity(0.7),
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

          // Quick question chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_quickPrompts[index]),
                  onPressed: () => _sendMessage(_quickPrompts[index]),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.sand300),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.ink, fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.sand200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Nhắn cho La Boutique...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.mute),
                        filled: true,
                        fillColor: AppColors.sand50,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
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
      ),
    );
  }
}
