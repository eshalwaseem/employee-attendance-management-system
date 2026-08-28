import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app.dart';

class ProfileImage extends StatelessWidget {
  final String? image;
  final double size;
  final VoidCallback? onTap;

  const ProfileImage({super.key, this.image, this.size = 96, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasImage = image != null && image!.isNotEmpty;

    // AppColors.primaryLight (0xFFFDECEF) is a light-mode-only tint;
    // in dark mode we fall back to a translucent primary, same pattern
    // used elsewhere in the app.
    final avatarBg = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: avatarBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: hasImage
                  ? Image.memory(
                      base64Decode(image!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_rounded,
                          color: theme.colorScheme.primary,
                          size: 48,
                        );
                      },
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.primary,
                      size: 48,
                    ),
            ),
          ),

          Positioned(
            right: -5,
            bottom: -5,
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                // Matches whatever surface this badge sits on, so it
                // reads as a cutout ring rather than a stark white edge.
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
