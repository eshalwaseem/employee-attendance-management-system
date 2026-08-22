import 'package:flutter/material.dart';

import '../../app.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.primary,
                size: 52,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Employee Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Smart. Simple. Reliable.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
