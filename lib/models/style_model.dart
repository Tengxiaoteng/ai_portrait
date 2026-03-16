import 'package:flutter/material.dart';

/// Represents a single AI portrait style option.
class StyleModel {
  final String name;
  final String category;
  final String description;
  final String promptHint;
  final int peopleCount;
  final String? compositionHint;

  const StyleModel({
    required this.name,
    required this.category,
    required this.description,
    required this.promptHint,
    required this.peopleCount,
    this.compositionHint,
  });

  bool get isGroupStyle => peopleCount > 1;
}

/// Category constants used across the style system.
class StyleCategory {
  StyleCategory._();

  static const String all = '全部';
  static const String artPainting = '艺术绘画';
  static const String animeCartoon = '动漫卡通';
  static const String photography = '摄影风格';
  static const String sceneTheme = '场景主题';
  static const String groupPhoto = '多人合照';

  static const List<String> values = [
    all,
    artPainting,
    animeCartoon,
    photography,
    sceneTheme,
    groupPhoto,
  ];

  /// Returns the gradient colors for each category (grey-tone gradients).
  static List<Color> gradientColors(String category) {
    switch (category) {
      case artPainting:
        return const [Color(0xFF2A2A2A), Color(0xFF1A1A1A)];
      case animeCartoon:
        return const [Color(0xFF2D2525), Color(0xFF1A1A1A)];
      case photography:
        return const [Color(0xFF252A2D), Color(0xFF1A1A1A)];
      case sceneTheme:
        return const [Color(0xFF252D25), Color(0xFF1A1A1A)];
      case groupPhoto:
        return const [Color(0xFF2D2A25), Color(0xFF1A1A1A)];
      default:
        return const [Color(0xFF2A2A2A), Color(0xFF1A1A1A)];
    }
  }
}
