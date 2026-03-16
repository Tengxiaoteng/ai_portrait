import 'package:flutter/material.dart';

import '../config/theme.dart';

/// A reusable gradient button with tap-scale animation, optional icon,
/// and loading state. Designed for tablet touch targets.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradient,
    this.width,
    this.height = 56,
    this.borderRadius,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Gradient? gradient;
  final double? width;
  final double height;
  final double? borderRadius;
  final TextStyle? textStyle;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isEnabled) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_isEnabled) _scaleController.reverse();
  }

  void _onTapCancel() {
    if (_isEnabled) _scaleController.reverse();
  }

  void _onTap() {
    if (_isEnabled) widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppTheme.borderRadius;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isEnabled ? 1.0 : 0.5,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: (widget.gradient ?? AppTheme.primaryGradient)
                      .colors
                      .first
                      .withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final style = widget.textStyle ?? AppTheme.labelLarge;

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(widget.text, style: style),
        ],
      );
    }

    return Center(
      child: Text(widget.text, style: style),
    );
  }
}
