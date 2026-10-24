import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

/// Chat khách ↔ shop — nối BE thật bằng POLLING (không WebSocket, theo thiết kế BE).
/// Mở màn → tải lịch sử + hỏi tin mới mỗi 3 giây; đóng màn → dừng hỏi.
class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Timer? _poll;
  DateTime? _sinceUtc; // mốc instant của tin cuối, để hỏi "tin mới hơn mốc này"

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  /// Tải lịch sử (BE trả mới→cũ, đảo lại cũ→mới để hiển thị) + đánh dấu đã đọc.
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.get(
        ApiConstants.conversationMessages,
        queryParams: {'size': 50},
        requiresAuth: true,
      );
      if (result is Map<String, dynamic> && result['content'] is List) {
        final list = (result['content'] as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        _messages
          ..clear()
          ..addAll(list);
        _updateSince();
      }
      await markRead();
    } catch (e) {
      debugPrint('[ChatProvider] loadHistory error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateSince() {
    if (_messages.isNotEmpty) _sinceUtc = _messages.last.timestamp.toUtc();
  }

  Future<void> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    try {
      final result = await _api.post(
        ApiConstants.conversationSend,
        body: {'content': content},
        requiresAuth: true,
      );
      if (result is Map<String, dynamic>) {
        final msg = ChatMessage.fromJson(result);
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
          _updateSince();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ChatProvider] send error: $e');
    }
  }

  void startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _pollNew());
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> _pollNew() async {
    try {
      final qp = <String, dynamic>{};
      if (_sinceUtc != null) qp['since'] = _sinceUtc!.toIso8601String();
      final result = await _api.get(
        ApiConstants.conversationMessagesNew,
        queryParams: qp.isEmpty ? null : qp,
        requiresAuth: true,
      );
      if (result is List && result.isNotEmpty) {
        var changed = false;
        for (final e in result) {
          final msg = ChatMessage.fromJson(e as Map<String, dynamic>);
          if (!_messages.any((m) => m.id == msg.id)) {
            _messages.add(msg);
            changed = true;
          }
        }
        if (changed) {
          _updateSince();
          await markRead();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ChatProvider] poll error: $e');
    }
  }

  Future<void> markRead() async {
    try {
      await _api.patch(ApiConstants.conversationRead, requiresAuth: true);
    } catch (_) {
      // không quan trọng nếu lỗi
    }
  }

  void clear() {
    _messages.clear();
    _sinceUtc = null;
    stopPolling();
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
