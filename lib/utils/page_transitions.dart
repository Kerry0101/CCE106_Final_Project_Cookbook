import 'package:flutter/material.dart';

/// Custom page route with slide transition
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.left:
                begin = const Offset(1.0, 0.0); // Slide from right to left
                break;
              case AxisDirection.right:
                begin = const Offset(-1.0, 0.0); // Slide from left to right
                break;
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0); // Slide from bottom to top
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0); // Slide from top to bottom
                break;
            }
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
