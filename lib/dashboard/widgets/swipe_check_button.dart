import 'package:flutter/material.dart';

import '../../app.dart';

class SwipeCheckButton extends StatefulWidget {
  final VoidCallback onCheckIn;
  final bool isCheckedIn;

  const SwipeCheckButton({
    super.key,
    required this.onCheckIn,
    required this.isCheckedIn,
  });

  @override
  State<SwipeCheckButton> createState() => _SwipeCheckButtonState();
}

class _SwipeCheckButtonState extends State<SwipeCheckButton> {
  double _dragPosition = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isCheckedIn) {
      return Container(
        height: 62,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Checked In',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double buttonSize = 50;

        final maxPosition =
            constraints.maxWidth - buttonSize - 8;

        return Container(
          height: 62,
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'Swipe to Check In',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Positioned(
                left: _dragPosition,
                top: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;

                      if (_dragPosition < 0) {
                        _dragPosition = 0;
                      }

                      if (_dragPosition > maxPosition) {
                        _dragPosition = maxPosition;
                      }
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragPosition >= maxPosition * 0.8) {
                      widget.onCheckIn();
                    } else {
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
