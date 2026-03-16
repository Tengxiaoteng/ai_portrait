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

  /// Returns the gradient colors for each category.
  static List<Color> gradientColors(String category) {
    switch (category) {
      case artPainting:
        return const [Color(0xFF8D6E63), Color(0xFFD7CCC8)];
      case animeCartoon:
        return const [Color(0xFFCE93D8), Color(0xFFF8BBD0)];
      case photography:
        return const [Color(0xFF64B5F6), Color(0xFFBBDEFB)];
      case sceneTheme:
        return const [Color(0xFF81C784), Color(0xFFC8E6C9)];
      case groupPhoto:
        return const [Color(0xFFFFB74D), Color(0xFFFFE0B2)];
      default:
        return const [Color(0xFF90A4AE), Color(0xFFCFD8DC)];
    }
  }
}
