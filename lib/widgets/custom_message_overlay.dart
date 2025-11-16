import 'package:flutter/material.dart';
import 'dart:async';

/// Custom animated message overlay for success and error messages
class CustomMessageOverlay {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static bool _isShowing = false;

  /// Show a custom message overlay
  static void show({
    required BuildContext context,
    required String message,
    required MessageType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Hide any existing message first
    hide();

    if (!context.mounted) return;

    _isShowing = true;

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _MessageOverlayWidget(
        message: message,
        type: type,
        onDismiss: hide,
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after duration
    _timer = Timer(duration, () {
      hide();
    });
  }

  /// Hide the message overlay
  static void hide() {
    _timer?.cancel();
    _timer = null;
    
    if (_isShowing && _overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        // Overlay might already be removed
      }
      _overlayEntry = null;
      _isShowing = false;
    }
  }
}

enum MessageType {
  success,
  error,
  warning,
  info,
}

class _MessageOverlayWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final VoidCallback onDismiss;

  const _MessageOverlayWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_MessageOverlayWidget> createState() => _MessageOverlayWidgetState();
}

class _MessageOverlayWidgetState extends State<_MessageOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backdropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide down animation
    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Scale animation for the card
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Backdrop fade animation
    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case MessageType.success:
        return const Color(0xFF10B981); // Green
      case MessageType.error:
        return const Color(0xFFEF4444); // Red
      case MessageType.warning:
        return const Color(0xFFF59E0B); // Orange
      case MessageType.info:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  Color _getIconColor() {
    return Colors.white;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning;
      case MessageType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Dark backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withOpacity(_backdropAnimation.value),
                ),
              ),
            ),
            // Message card
            Positioned(
              top: MediaQuery.of(context).padding.top + 20 + _slideAnimation.value,
              left: 20,
              right: 20,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _MessageCard(
                    message: widget.message,
                    type: widget.type,
                    backgroundColor: _getBackgroundColor(),
                    iconColor: _getIconColor(),
                    icon: _getIcon(),
                    onDismiss: _dismiss,
                    isSuccess: widget.type == MessageType.success,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageCard extends StatefulWidget {
  final String message;
  final MessageType type;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final bool isSuccess;

  const _MessageCard({
    required this.message,
    required this.type,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onDismiss,
    required this.isSuccess,
  });

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkRotationAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isSuccess) {
      _checkController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      _checkScaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ));

      _checkRotationAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _checkController,
        curve: Curves.easeOut,
      ));

      // Start check animation after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _checkController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.isSuccess) {
      _checkController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Animated icon
              if (widget.isSuccess)
                AnimatedBuilder(
                  animation: _checkController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _checkScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _checkRotationAnimation.value * 0.1,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 24,
                  ),
                ),
              const SizedBox(width: 16),
              // Message text
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Close button
              GestureDetector(
                onTap: widget.onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

