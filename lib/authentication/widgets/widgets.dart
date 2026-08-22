export 'auth_button.dart';
export 'email_field.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthIllustration extends StatefulWidget {
  const AuthIllustration({super.key});

  @override
  State<AuthIllustration> createState() => _AuthIllustrationState();
}

class _AuthIllustrationState extends State<AuthIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 120,
      height: 110,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = Curves.easeInOut.transform(_controller.value);

          final floatingOffset = math.sin(value * math.pi) * 6;

          final rotation = math.sin(value * math.pi * 2) * 0.035;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 10 + floatingOffset,
                right: 13,
                child: Transform.rotate(
                  angle: rotation,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 21,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              Positioned(
                left: 4,
                top: 31 - floatingOffset * 0.5,
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),

              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),

              Positioned(
                bottom: 10 + floatingOffset,
                child: Container(
                  width: 72,
                  height: 61,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 9,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 7,
                        child: Container(
                          width: 43,
                          height: 27,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 17,
                right: 6,
                child: Transform.rotate(
                  angle: -rotation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
