import 'package:flutter/material.dart';

class SwipeCheckButton extends StatefulWidget {
  final VoidCallback? onCheckIn;
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
  bool _isSubmitting = false;

  @override
  void didUpdateWidget(covariant SwipeCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCheckedIn != oldWidget.isCheckedIn) {
      setState(() {
        _dragPosition = 0;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

if (widget.isCheckedIn) {
  final bool isDark = theme.brightness == Brightness.dark;

  return Container(
    height: 62,
    width: double.infinity,
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withValues(
        alpha: isDark ? 0.20 : 0.10,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.35 : 0.15,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Checked In',
          style: TextStyle(
            color: theme.colorScheme.primary,
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

        final double maxPosition =
            constraints.maxWidth - buttonSize - 12;

        return Container(
          height: 62,
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Swipe to Check In',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: _dragPosition,
                top: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _isSubmitting
                      ? null
                      : (details) {
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
                  onHorizontalDragEnd: _isSubmitting
                      ? null
                      : (_) {
                          final bool completed =
                              _dragPosition >= maxPosition * 0.8;

                          if (completed) {
                            setState(() {
                              _dragPosition = maxPosition;
                              _isSubmitting = true;
                            });

                            widget.onCheckIn?.call();
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
                      color: _isSubmitting
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
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
