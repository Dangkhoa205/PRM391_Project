import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Thông báo trượt từ MÉP TRÊN xuống, tự ẩn sau [duration].
///
/// Dùng Overlay gốc (rootOverlay) nên banner **vẫn hiển thị sau khi màn hình hiện tại pop** —
/// hợp cho trường hợp "đăng nhập xong → quay về trang chủ → vẫn thấy lời chào".
class TopNotification {
  static void show(
    BuildContext context,
    String message, {
    bool success = true,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopBanner(
        message: message,
        success: success,
        duration: duration,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _TopBanner extends StatefulWidget {
  final String message;
  final bool success;
  final Duration duration;
  final VoidCallback onDone;

  const _TopBanner({
    required this.message,
    required this.success,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, -1.2), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success ? AppColors.success : Colors.red.shade700;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.success ? Icons.check_circle : Icons.error,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
