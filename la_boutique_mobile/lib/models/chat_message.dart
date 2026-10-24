/// Tin nhắn chat, khớp ChatMessageResponse của BE: { id, senderType, content, createdAt }.
/// `senderType` = CUSTOMER | ADMIN → quyết định bong bóng trái/phải.
class ChatMessage {
  final String id;
  final String text;        // BE: content
  final DateTime timestamp; // BE: createdAt
  final bool isFromUser;    // senderType == CUSTOMER

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': text,
        'senderType': isFromUser ? 'CUSTOMER' : 'ADMIN',
        'createdAt': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = (json['senderType'] ?? '').toString().toUpperCase();
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      text: (json['content'] ?? json['text'] ?? '').toString(),
      timestamp: DateTime.tryParse((json['createdAt'] ?? json['timestamp'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      isFromUser: sender.isNotEmpty ? sender == 'CUSTOMER' : (json['isFromUser'] as bool? ?? true),
    );
  }
}
