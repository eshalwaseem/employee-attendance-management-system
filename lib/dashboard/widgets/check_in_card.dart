import 'package:flutter/material.dart';
import '../../app.dart';

class CheckInCard extends StatelessWidget {
  final bool isCheckedIn;
  final String? checkInTime;

  const CheckInCard({
    super.key,
    required this.isCheckedIn,
    required this.checkInTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Today's Check In",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                isCheckedIn
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            isCheckedIn ? checkInTime ?? '--:--' : '--:--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            isCheckedIn
                ? 'You are checked in'
                : 'You have not checked in yet',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}