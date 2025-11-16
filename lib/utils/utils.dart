import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cookbook/widgets/custom_message_overlay.dart';
import 'package:cookbook/main.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Show a custom animated message overlay
  void showMessage(String? text, MessageType type, {Duration? duration}) {
    if (text == null || text.isEmpty) return;
    
    // Use post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        // Fallback to snackbar if no context available
        try {
          showSnackBar(text, _getColorFromType(type));
        } catch (e) {
          debugPrint('Failed to show message: $e');
        }
        return;
      }

      try {
        CustomMessageOverlay.show(
          context: context,
          message: text,
          type: type,
          duration: duration ?? const Duration(seconds: 3),
        );
      } catch (e) {
        debugPrint('Failed to show overlay: $e');
        // Last resort fallback
        try {
          showSnackBar(text, _getColorFromType(type));
        } catch (e2) {
          debugPrint('Failed to show snackbar: $e2');
        }
      }
    });
  }

  /// Show success message
  void showSuccess(String? text, {Duration? duration}) {
    showMessage(text, MessageType.success, duration: duration);
  }

  /// Show error message
  void showError(String? text, {Duration? duration}) {
    showMessage(text, MessageType.error, duration: duration);
  }

  /// Show warning message
  void showWarning(String? text, {Duration? duration}) {
    showMessage(text, MessageType.warning, duration: duration);
  }

  /// Show info message
  void showInfo(String? text, {Duration? duration}) {
    showMessage(text, MessageType.info, duration: duration);
  }

  /// Legacy snackbar method (kept for backward compatibility)
  void showSnackBar(String? text, Color backgroundColor) {
    if (text == null) return;
    
    final state = messengerKey.currentState;
    if (state == null) {
      debugPrint('ScaffoldMessenger not available');
      return;
    }
    
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: backgroundColor,
    );

    state
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Get color from message type (for fallback snackbar)
  Color _getColorFromType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return const Color(0xFF10B981);
      case MessageType.error:
        return const Color(0xFFEF4444);
      case MessageType.warning:
        return const Color(0xFFF59E0B);
      case MessageType.info:
        return const Color(0xFF3B82F6);
    }
  }
}
