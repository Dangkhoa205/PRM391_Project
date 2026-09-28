class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromUser: json['isFromUser'] as bool,
    );
  }
}
