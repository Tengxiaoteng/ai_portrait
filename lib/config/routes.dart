import 'package:flutter/material.dart';

import '../models/style_model.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/style_picker_screen.dart';
import '../screens/processing_screen.dart';
import '../screens/result_screen.dart';

/// Centralized route management for the AI Portrait app.
class AppRoutes {
  AppRoutes._();

  // ── Route name constants ──────────────────────────────────────────────
  static const String home = '/';
  static const String camera = '/camera';
  static const String stylePicker = '/style-picker';
  static const String processing = '/processing';
  static const String result = '/result';

  // ── Route generator ───────────────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen(), settings);

      case camera:
        return _buildRoute(const CameraScreen(), settings);

      case stylePicker:
        final map = args as Map<String, dynamic>;
        return _buildRoute(
          StylePickerScreen(imagePaths: map['imagePaths'] as List<String>),
          settings,
        );

      case processing:
        final map = args as Map<String, dynamic>;
        return _buildRoute(
          ProcessingScreen(
            imagePaths: map['imagePaths'] as List<String>,
            style: map['style'] as StyleModel,
            customStylePath: map['customStylePath'] as String?,
          ),
          settings,
        );

      case result:
        final map = args as Map<String, dynamic>;
        return _buildRoute(
          ResultScreen(
            originalImagePath: map['originalImagePath'] as String,
            generatedImagePath: map['generatedImagePath'] as String,
            styleName: map['styleName'] as String,
            prompt: map['prompt'] as String,
          ),
          settings,
        );

      default:
        return _buildRoute(const HomeScreen(), settings);
    }
  }

  // ── Shared page transition (fade + slide) ─────────────────────────────
  static PageRouteBuilder<T> _buildRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
