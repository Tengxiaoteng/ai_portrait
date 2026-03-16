/// 应用配置层
///
/// 集中管理 API 地址、模型 ID、图片生成参数等全局配置。
/// API Key 优先从环境变量读取，其次从本地存储读取。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  // ─── API 配置 ──────────────────────────────────────────

  static const String apiBaseUrl =
      'https://ark.cn-beijing.volces.com/api/v3';

  static const String chatCompletionsPath = '/chat/completions';
  static const String imageGenerationsPath = '/images/generations';

  static String get chatCompletionsUrl => '$apiBaseUrl$chatCompletionsPath';
  static String get imageGenerationsUrl => '$apiBaseUrl$imageGenerationsPath';

  // ─── 模型 ID ──────────────────────────────────────────

  /// 豆包视觉理解模型 - 用于人像/风格分析
  static const String visionModel = 'doubao-1-5-vision-pro-32k-250115';

  /// 豆包大语言模型 - 用于提示词整合生成
  static const String llmModel = 'doubao-1-5-pro-32k-250115';

  /// 豆包 Seedream 图像生成模型
  static const String imageModel = 'doubao-seedream-4-0-250828';

  // ─── 图片生成设置 ─────────────────────────────────────

  /// 输出图片尺寸，可选: 512x512, 1024x1024, 2K, 4K
  static const String imageSize = '4K';

  /// 是否添加水印
  static const bool imageWatermark = false;

  /// 画质增强后缀，附加到每个生成提示词末尾
  static const String qualitySuffix =
      'masterpiece, best quality, ultra detailed, sharp focus, '
      'high resolution, realistic skin texture, natural teeth, '
      'detailed eyes and lips, professional photography quality';

  /// 负面提示，指导模型避免的缺陷
  static const String negativeHints =
      'blurry, low quality, distorted face, bad teeth, deformed, '
      'disfigured, extra fingers, mutated hands';

  // ─── 服装适配规则 ─────────────────────────────────────

  static const String adaptationLabel = '保守模式';

  static const String adaptationRules =
      '根据人物的性别和气质做合理适配：'
      '女装→对应风格的男装（如抹胸裙→黑色西装三件套），'
      '男装→对应风格的女装（如西装→同色系连衣裙）。'
      '夸张配饰适当减少，动作保持但更自然，整体保持得体。'
      '服装转换规则：裙子↔西裤、抹胸↔衬衫/西装、'
      '高跟鞋↔皮鞋、夸张首饰→简约腕表或袖扣。';

  // ─── API Key 管理 ─────────────────────────────────────

  static String? _cachedApiKey;

  /// 获取 API Key。
  ///
  /// 优先级:
  /// 1. 内存缓存（运行时设置的）
  /// 2. 环境变量 ARK_API_KEY
  /// 3. 返回 null，由调用方从本地存储获取
  static String? getApiKey() {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey;
    }

    final envKey = Platform.environment['ARK_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      _cachedApiKey = envKey;
      return envKey;
    }

    return null;
  }

  /// 运行时设置 API Key（从本地存储加载后调用）
  static void setApiKey(String key) {
    if (key.isEmpty) {
      debugPrint('[AppConfig] 警告: 尝试设置空的 API Key');
      return;
    }
    _cachedApiKey = key;
  }

  /// 清除缓存的 API Key
  static void clearApiKey() {
    _cachedApiKey = null;
  }

  /// 检查 API Key 是否已配置
  static bool get hasApiKey {
    final key = getApiKey();
    return key != null && key.isNotEmpty;
  }
}
