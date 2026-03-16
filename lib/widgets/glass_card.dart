import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/theme.dart';

/// A frosted-glass card with backdrop blur, semi-transparent background,
/// and configurable border. Used as a content container throughout the app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.backgroundOpacity = 0.15,
    this.blurSigma = 12.0,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final double blurSigma;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.borderRadius;
    final bgColor = backgroundColor ?? Colors.white;
    final border = borderColor ?? Colors.white.withValues(alpha: 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: backgroundOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: border,
              width: borderWidth,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
