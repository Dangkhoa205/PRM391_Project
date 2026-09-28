import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => [..._messages];

  ChatProvider() {
    _initWelcomeMessages();
  }

  void _initWelcomeMessages() {
    _messages.addAll([
      ChatMessage(
        id: 'msg_0',
        text: 'Dạ La Boutique xin kính chào Quý khách! 🌸 Em có thể tư vấn mẫu váy áo hoặc hướng dẫn chọn size giúp nàng không ạ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isFromUser: false,
      ),
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      timestamp: DateTime.now(),
      isFromUser: true,
    );

    _messages.add(userMsg);
    notifyListeners();

    // Simulate smart shop assistant reply
    await Future.delayed(const Duration(milliseconds: 1000));
    final reply = _generateReply(text.toLowerCase());

    final botMsg = ChatMessage(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      text: reply,
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    _messages.add(botMsg);
    notifyListeners();
  }

  String _generateReply(String input) {
    if (input.contains('size') || input.contains('kích thước') || input.contains('kg')) {
      return 'Dạ bảng size chuẩn tại La Boutique:\n• Size S: Dưới 48kg (Vòng 1 < 84cm, Vòng 2 < 66cm)\n• Size M: 48 - 54kg (Vòng 1: 85-88cm, Vòng 2: 67-72cm)\n• Size L: 55 - 62kg (Vòng 1: 89-94cm, Vòng 2: 73-78cm)\nNàng cho em xin chiều cao và cân nặng để em chọn size chuẩn nhất cho nàng nhé!';
    } else if (input.contains('ship') || input.contains('giao') || input.contains('vận chuyển')) {
      return 'Dạ La Boutique hỗ trợ FREESHIP toàn quốc cho đơn hàng từ 1.000.000₫ hoặc khi nhập mã FREESHIP. Thời gian giao từ 1-2 ngày với nội thành và 2-3 ngày với các tỉnh thành khác ạ! ✨';
    } else if (input.contains('sunset') || input.contains('bộ sưu tập') || input.contains('mới')) {
      return 'Bộ sưu tập La Boutique Sunset SS26 mang phong cách lãng mạn hoàng hôn biển, kết hợp chất liệu lụa satin mượt và linen hữu cơ thoáng mát cực kỳ sang trọng ạ! 🌅';
    } else if (input.contains('đổi') || input.contains('trả') || input.contains('bảo hành')) {
      return 'Dạ La Boutique hỗ trợ đổi size trong vòng 7 ngày kể từ khi nhận hàng (sản phẩm còn nguyên tem mác). Nàng yên tâm mua sắm nhé ạ!';
    } else {
      return 'Dạ La Boutique đã nhận được thông tin từ nàng. Chuyên viên tư vấn đang kiểm tra kho và sẽ hỗ trợ nàng ngay trong giây lát nhé! 💕';
    }
  }
}
