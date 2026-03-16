/// 图片生成结果数据模型
///
/// 记录一次完整 pipeline 的输入、输出和中间数据。
library;

import 'package:flutter/foundation.dart';

@immutable
class GenerationResult {
  /// 原始人像照片的本地路径
  final String originalImagePath;

  /// 生成图片的 URL（来自 API 响应）
  final String generatedImageUrl;

  /// 使用的风格名称
  final String styleName;

  /// 最终发送给 Seedream 的完整提示词
  final String prompt;

  /// Step 1 提取的人像特征 JSON
  final Map<String, dynamic> faceFeatures;

  /// Step 2 提取/构建的风格特征 JSON
  final Map<String, dynamic> styleFeatures;

  /// 生成时间
  final DateTime createdAt;

  const GenerationResult({
    required this.originalImagePath,
    required this.generatedImageUrl,
    required this.styleName,
    required this.prompt,
    required this.faceFeatures,
    required this.styleFeatures,
    required this.createdAt,
  });

  /// 从 JSON Map 反序列化
  factory GenerationResult.fromJson(Map<String, dynamic> json) {
    return GenerationResult(
      originalImagePath: json['originalImagePath'] as String,
      generatedImageUrl: json['generatedImageUrl'] as String,
      styleName: json['styleName'] as String,
      prompt: json['prompt'] as String,
      faceFeatures:
          Map<String, dynamic>.from(json['faceFeatures'] as Map),
      styleFeatures:
          Map<String, dynamic>.from(json['styleFeatures'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 序列化为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'originalImagePath': originalImagePath,
      'generatedImageUrl': generatedImageUrl,
      'styleName': styleName,
      'prompt': prompt,
      'faceFeatures': faceFeatures,
      'styleFeatures': styleFeatures,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 创建副本并覆盖指定字段
  GenerationResult copyWith({
    String? originalImagePath,
    String? generatedImageUrl,
    String? styleName,
    String? prompt,
    Map<String, dynamic>? faceFeatures,
    Map<String, dynamic>? styleFeatures,
    DateTime? createdAt,
  }) {
    return GenerationResult(
      originalImagePath: originalImagePath ?? this.originalImagePath,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      styleName: styleName ?? this.styleName,
      prompt: prompt ?? this.prompt,
      faceFeatures: faceFeatures ?? this.faceFeatures,
      styleFeatures: styleFeatures ?? this.styleFeatures,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'GenerationResult(style: $styleName, '
      'created: ${createdAt.toIso8601String()})';
}
