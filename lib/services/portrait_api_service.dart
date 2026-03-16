/// 人像风格化 API 服务层
///
/// 封装 4 步 pipeline 的 API 调用：
/// 1. 提取人像特征 (Vision API)
/// 2. 提取风格特征 (Vision API)
/// 3. 整合生成提示词 (LLM API)
/// 4. 生成风格化图片 (Seedream API)
///
/// 使用 dart:io HttpClient，OpenAI 兼容格式。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../config/app_config.dart';
import '../models/generation_result.dart';
import '../models/style_data.dart';
import '../models/style_model.dart';

/// API 调用异常
class PortraitApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const PortraitApiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    final parts = ['PortraitApiException: $message'];
    if (statusCode != null) parts.add('status=$statusCode');
    if (responseBody != null && responseBody!.isNotEmpty) {
      final truncated = responseBody!.length > 200
          ? '${responseBody!.substring(0, 200)}...'
          : responseBody!;
      parts.add('body=$truncated');
    }
    return parts.join(', ');
  }
}

class PortraitApiService {
  final HttpClient _client;

  PortraitApiService() : _client = HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 30);
    _client.idleTimeout = const Duration(seconds: 60);
  }

  // ─── 内部工具方法 ─────────────────────────────────────

  String _requireApiKey() {
    final key = AppConfig.getApiKey();
    if (key == null || key.isEmpty) {
      throw const PortraitApiException(
        'API Key 未配置。请在设置中输入 ARK_API_KEY。',
      );
    }
    return key;
  }

  /// 将本地图片文件编码为 data URL
  Future<String> _imageToDataUrl(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw PortraitApiException('图片文件不存在: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);

    final ext = p.extension(imagePath).toLowerCase().replaceFirst('.', '');
    const mimeMap = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'webp': 'webp',
      'gif': 'gif',
    };
    final mime = mimeMap[ext] ?? 'jpeg';

    return 'data:image/$mime;base64,$base64Str';
  }

  /// 发送 POST 请求并返回解析后的 JSON
  Future<Map<String, dynamic>> _postJson(
    String url,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final apiKey = _requireApiKey();
    final uri = Uri.parse(url);

    debugPrint('[API] POST $url');

    try {
      final request = await _client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final jsonBody = jsonEncode(body);
      request.write(jsonBody);

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw PortraitApiException(
          'API 请求失败',
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json;
    } on SocketException catch (e) {
      throw PortraitApiException('网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      throw PortraitApiException('HTTP 请求异常: ${e.message}');
    } on FormatException catch (e) {
      throw PortraitApiException('响应 JSON 解析失败: ${e.message}');
    }
  }

  /// 从 chat completion 响应中提取文本内容
  String _extractChatContent(Map<String, dynamic> response) {
    final choices = response['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const PortraitApiException('API 响应中没有 choices');
    }
    final message = choices[0]['message'] as Map<String, dynamic>;
    final content = message['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const PortraitApiException('API 响应内容为空');
    }
    return content;
  }

  /// 从 LLM 回复中提取 JSON
  Map<String, dynamic> _parseJsonFromResponse(String raw) {
    var text = raw.trim();

    // 尝试提取 markdown 代码块中的 JSON
    if (text.contains('```json')) {
      text = text.split('```json')[1].split('```')[0].trim();
    } else if (text.contains('```')) {
      text = text.split('```')[1].split('```')[0].trim();
    }

    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } on FormatException {
      throw PortraitApiException(
        'LLM 返回的 JSON 格式无效',
        responseBody: text,
      );
    }
  }

  // ─── Step 1: 提取人像特征 ─────────────────────────────

  /// 调用豆包 Vision API 分析人像照片，返回结构化特征 JSON。
  ///
  /// [imagePath] 人像照片的本地路径。
  /// [personLabel] 多人时的人物标签，如 "人物A"。
  Future<Map<String, dynamic>> extractFaceFeatures(
    String imagePath, {
    String personLabel = '',
  }) async {
    final tag = personLabel.isNotEmpty ? '($personLabel)' : '';
    debugPrint('[Step 1] 正在分析人像照片$tag: ${p.basename(imagePath)}');

    final imageDataUrl = await _imageToDataUrl(imagePath);

    final body = {
      'model': AppConfig.visionModel,
      'messages': [
        {
          'role': 'system',
          'content': '你是一个专业的人像分析师。请仔细观察图片中的人物，'
              '输出严格的 JSON 格式描述。不要输出任何其他文字。',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '''请分析这张人像照片，输出以下 JSON 结构：
{
    "gender": "男/女",
    "age_range": "大致年龄段",
    "face_shape": "脸型描述",
    "skin_tone": "肤色描述",
    "hair": {
        "style": "发型",
        "color": "发色",
        "length": "长度"
    },
    "expression": "表情描述",
    "distinctive_features": "显著特征，如痣、胡须、眼镜等",
    "pose": "姿势描述（正面/侧面/半身等）",
    "clothing": "服装描述",
    "overall_vibe": "整体气质的一句话总结"
}''',
            },
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ],
      'temperature': 0.1,
    };

    final response = await _postJson(AppConfig.chatCompletionsUrl, body);
    final content = _extractChatContent(response);
    final faceJson = _parseJsonFromResponse(content);

    debugPrint(
      '   -> ${faceJson['gender'] ?? '?'}, '
      '${faceJson['age_range'] ?? '?'}, '
      '${faceJson['overall_vibe'] ?? '?'}',
    );

    return faceJson;
  }

  // ─── Step 2: 提取风格特征 ─────────────────────────────

  /// 调用豆包 Vision API 分析风格参考图，返回结构化特征 JSON。
  ///
  /// [imagePath] 风格参考图的本地路径。
  Future<Map<String, dynamic>> extractStyleFeatures(String imagePath) async {
    debugPrint('[Step 2] 正在分析风格参考图: ${p.basename(imagePath)}');

    final imageDataUrl = await _imageToDataUrl(imagePath);

    final body = {
      'model': AppConfig.visionModel,
      'messages': [
        {
          'role': 'system',
          'content': '你是一个专业的图像分析师。请仔细观察图片中的所有元素，'
              '包括人物的动作、服装、姿势，以及画面的艺术风格。'
              '输出严格的 JSON 格式描述。不要输出任何其他文字。',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '''请全面分析这张参考图片，输出以下 JSON 结构：
{
    "person": {
        "pose": "人物姿势的详细描述",
        "clothing": "服装的详细描述（类型、颜色、材质、款式）",
        "accessories": "配饰描述（项链、耳环、手表、帽子等）",
        "body_language": "肢体语言和情绪表达",
        "hair_style_in_scene": "参考图中人物的发型"
    },
    "scene": {
        "art_style": "艺术风格名称",
        "color_palette": "主要色彩描述",
        "lighting": "光影风格描述",
        "mood": "画面情绪氛围",
        "background": "背景环境的详细描述",
        "props": "场景中的道具和物件",
        "composition": "构图方式"
    },
    "prompt_keywords": "用英文列出10-15个最关键的关键词，逗号分隔"
}''',
            },
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ],
      'temperature': 0.1,
    };

    final response = await _postJson(AppConfig.chatCompletionsUrl, body);
    final content = _extractChatContent(response);
    final styleJson = _parseJsonFromResponse(content);

    final scene = styleJson['scene'] as Map<String, dynamic>? ?? {};
    debugPrint(
      '   风格: ${scene['art_style'] ?? '?'}, ${scene['mood'] ?? '?'}',
    );

    return styleJson;
  }

  /// 为预设风格构建风格特征 JSON（不需要调用 API）。
  Map<String, dynamic> buildPresetStyleFeatures(StyleModel style) {
    debugPrint('[Step 2] 使用预设风格: ${style.name} - ${style.description}');

    final features = <String, dynamic>{
      'art_style': style.name,
      'color_palette': '根据风格自动匹配',
      'lighting': '根据风格自动匹配',
      'mood': style.description,
      'composition': '根据风格自动匹配',
      'background': '根据风格自动匹配',
      'prompt_keywords': style.promptHint,
      'clothing_rule': '必须根据人物性别选择合适的服装：'
          '男性穿男装、女性穿女装，不要出现性别错位的穿搭',
    };

    if (style.peopleCount > 1) {
      features['people_count'] = style.peopleCount;
      features['composition_hint'] =
          StyleData.getCompositionHint(style.name) ?? '';
    }

    return features;
  }

  // ─── Step 3: 生成提示词 ───────────────────────────────

  /// 调用豆包 LLM 整合人像特征和风格特征，生成英文图像提示词。
  ///
  /// [faceJsons] 人像特征 JSON 列表（支持多人）。
  /// [styleJson] 风格特征 JSON。
  Future<String> generatePrompt(
    List<Map<String, dynamic>> faceJsons,
    Map<String, dynamic> styleJson,
  ) async {
    if (faceJsons.isEmpty) {
      throw const PortraitApiException('人像特征列表不能为空');
    }

    final isGroup = faceJsons.length > 1;
    final modeLabel = isGroup ? '多人合照' : AppConfig.adaptationLabel;
    debugPrint(
      '[Step 3] 正在用 LLM 整合生成提示词...($modeLabel, ${faceJsons.length}人)',
    );

    String systemPrompt;
    String userPrompt;

    if (isGroup) {
      final peopleDesc = StringBuffer();
      for (var i = 0; i < faceJsons.length; i++) {
        final label = '人物${String.fromCharCode(65 + i)}'; // A, B, C...
        final clean = Map<String, dynamic>.from(faceJsons[i])
          ..removeWhere((k, _) => k.startsWith('_'));
        peopleDesc.writeln('### $label');
        peopleDesc.writeln(
          '```json\n${const JsonEncoder.withIndent('  ').convert(clean)}\n```',
        );
        peopleDesc.writeln();
      }

      final compositionHint =
          styleJson['composition_hint'] as String? ?? '';
      final peopleCount =
          styleJson['people_count'] ?? faceJsons.length;

      systemPrompt = '你是一个专业的 AI 图像生成提示词工程师。\n'
          '你的任务是：生成一张 $peopleCount 人合照的提示词。\n\n'
          '核心规则（必须严格遵守）：\n'
          '1. 图中必须出现所有人物，每个人的面部特征必须清晰区分\n'
          '2. 每个人物要有明确的外貌描述\n'
          '3. 人物之间要有自然的互动和关系感\n'
          '4. 场景/背景/光影采用风格JSON中的设定\n\n'
          '## 构图指导\n$compositionHint\n\n'
          '## 服装适配规则：${AppConfig.adaptationLabel}\n'
          '${AppConfig.adaptationRules}\n\n'
          '输出要求：\n'
          '- 用英文输出\n'
          '- 长度 120-200 个英文单词\n'
          '- 明确描述每个人物的位置、外貌和互动\n'
          '- 只输出提示词本身，不要任何额外文字';

      final styleJsonStr =
          const JsonEncoder.withIndent('  ').convert(styleJson);
      userPrompt = '## 人物特征（共 ${faceJsons.length} 人）\n'
          '$peopleDesc\n'
          '## 风格特征 JSON\n```json\n$styleJsonStr\n```\n\n'
          '请将以上 ${faceJsons.length} 个人物的特征与风格整合，'
          '生成一段多人合照的英文提示词。';
    } else {
      final cleanFace = Map<String, dynamic>.from(faceJsons[0])
        ..removeWhere((k, _) => k.startsWith('_'));

      systemPrompt = '你是一个专业的 AI 图像生成提示词工程师。\n'
          '你的任务是：让「人物特征JSON」中的人，'
          '以「风格特征JSON」中的动作、服装、场景重新呈现。\n\n'
          '核心规则（必须严格遵守）：\n'
          '1. 只保留人物JSON中的面部特征：性别、年龄、脸型、肤色、五官特征\n'
          '2. 动作/姿势必须采用风格JSON中的姿势和肢体语言\n'
          '3. 场景/背景必须采用风格JSON中的背景环境和道具\n'
          '4. 光影/色调/氛围必须采用风格JSON中的风格\n\n'
          '## 服装适配规则：${AppConfig.adaptationLabel}\n'
          '${AppConfig.adaptationRules}\n\n'
          '输出要求：\n'
          '- 用英文输出\n'
          '- 长度 80-150 个英文单词\n'
          '- 只输出提示词本身，不要任何额外文字';

      final faceJsonStr =
          const JsonEncoder.withIndent('  ').convert(cleanFace);
      final styleJsonStr =
          const JsonEncoder.withIndent('  ').convert(styleJson);
      userPrompt = '## 人物特征 JSON\n```json\n$faceJsonStr\n```\n\n'
          '## 风格特征 JSON\n```json\n$styleJsonStr\n```\n\n'
          '请将以上两个 JSON 整合，生成一段用于 Seedream 图像生成模型的英文提示词。';
    }

    final body = {
      'model': AppConfig.llmModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.7,
    };

    final response = await _postJson(AppConfig.chatCompletionsUrl, body);
    var prompt = _extractChatContent(response).trim();

    // 去除可能的引号包裹
    if (prompt.startsWith('"') && prompt.endsWith('"')) {
      prompt = prompt.substring(1, prompt.length - 1);
    }

    // 追加画质后缀和负面提示
    if (AppConfig.qualitySuffix.isNotEmpty) {
      prompt = '$prompt, ${AppConfig.qualitySuffix}';
    }
    if (AppConfig.negativeHints.isNotEmpty) {
      prompt = '$prompt. Avoid: ${AppConfig.negativeHints}';
    }

    debugPrint(
      '   提示词: ${prompt.length > 120 ? '${prompt.substring(0, 120)}...' : prompt}',
    );

    return prompt;
  }

  // ─── Step 4: 生成图片 ─────────────────────────────────

  /// 调用 Seedream API 生成风格化图片。
  ///
  /// [prompt] 完整的英文提示词。
  /// [facePaths] 人脸图片路径列表。
  /// [stylePath] 可选的风格参考图路径。
  ///
  /// 返回生成图片的 URL。
  Future<String> generateImage(
    String prompt,
    List<String> facePaths, {
    String? stylePath,
  }) async {
    if (facePaths.isEmpty) {
      throw const PortraitApiException('人脸图片列表不能为空');
    }

    final isGroup = facePaths.length > 1;
    debugPrint('[Step 4] 正在调用 Seedream 生成图片...(${facePaths.length}人)');

    // 编码所有图片为 data URL
    final faceDataUrls = <String>[];
    for (final path in facePaths) {
      faceDataUrls.add(await _imageToDataUrl(path));
    }

    final allImages = List<String>.from(faceDataUrls);
    if (stylePath != null && await File(stylePath).exists()) {
      allImages.add(await _imageToDataUrl(stylePath));
    }

    // 构建请求体
    final payload = <String, dynamic>{
      'model': AppConfig.imageModel,
      'prompt': prompt,
      'response_format': 'url',
      'size': AppConfig.imageSize,
      'watermark': AppConfig.imageWatermark,
      'sequential_image_generation': 'disabled',
    };

    // image 参数：单张为字符串，多张为数组
    if (allImages.length == 1) {
      payload['image'] = allImages[0];
    } else {
      payload['image'] = allImages;
    }

    // 构建图片角色说明前缀
    final hasStyleRef =
        stylePath != null && await File(stylePath).exists();
    if (isGroup && hasStyleRef) {
      final faceRefs = List.generate(
        facePaths.length,
        (i) => '图${i + 1}的人物${String.fromCharCode(65 + i)}的面部特征和身份',
      ).join('、');
      final styleRef = '图${facePaths.length + 1}的艺术风格和色彩氛围';
      payload['prompt'] = '参考$faceRefs，参考$styleRef。$prompt';
    } else if (isGroup) {
      final faceRefs = List.generate(
        facePaths.length,
        (i) => '图${i + 1}的人物${String.fromCharCode(65 + i)}的面部特征和身份',
      ).join('、');
      payload['prompt'] = '参考$faceRefs。$prompt';
    } else if (hasStyleRef) {
      payload['prompt'] = '参考图1的人物面部特征和身份，'
          '参考图2的艺术风格和色彩氛围。$prompt';
    }

    final response = await _postJson(
      AppConfig.imageGenerationsUrl,
      payload,
      timeout: const Duration(seconds: 180),
    );

    // 解析响应
    final data = response['data'] as List?;
    if (data == null || data.isEmpty) {
      throw PortraitApiException(
        'API 未返回图片数据',
        responseBody: jsonEncode(response).substring(
          0,
          200.clamp(0, jsonEncode(response).length),
        ),
      );
    }

    final imageInfo = data[0] as Map<String, dynamic>;

    if (imageInfo.containsKey('url')) {
      final imageUrl = imageInfo['url'] as String;
      debugPrint('   图片 URL 已获取');
      return imageUrl;
    }

    if (imageInfo.containsKey('b64_json')) {
      // 如果返回 base64，转为 data URL
      final b64 = imageInfo['b64_json'] as String;
      debugPrint('   图片 base64 已获取');
      return 'data:image/png;base64,$b64';
    }

    throw const PortraitApiException('API 响应中未找到图片 URL 或 base64 数据');
  }

  // ─── Pipeline: 串联 4 步 ──────────────────────────────

  /// 执行完整的 4 步 pipeline。
  ///
  /// [facePaths] 人脸图片路径列表（单人传 1 个，多人传多个）。
  /// [style] 预设风格。
  /// [customStylePath] 自定义风格参考图路径，为 null 时使用预设风格。
  /// [onProgress] 进度回调 (步骤编号 1-4, 步骤描述)。
  Future<GenerationResult> runPipeline(
    List<String> facePaths,
    StyleModel style, {
    String? customStylePath,
    void Function(int step, String description)? onProgress,
  }) async {
    if (facePaths.isEmpty) {
      throw const PortraitApiException('请至少提供一张人像照片');
    }

    // 验证文件存在
    for (final path in facePaths) {
      if (!await File(path).exists()) {
        throw PortraitApiException('人像照片不存在: $path');
      }
    }
    if (customStylePath != null && !await File(customStylePath).exists()) {
      throw PortraitApiException('风格参考图不存在: $customStylePath');
    }

    debugPrint('');
    final divider = '─' * 55;
    debugPrint(divider);
    debugPrint('  人像: ${facePaths.map(p.basename).join(', ')} '
        '(${facePaths.length}人)');
    debugPrint('  风格: ${style.name}');
    debugPrint(divider);

    // Step 1: 提取所有人像特征
    onProgress?.call(1, '正在分析人像特征...');
    final faceJsons = <Map<String, dynamic>>[];
    final labels = ['人物A', '人物B', '人物C', '人物D', '人物E', '人物F'];
    for (var i = 0; i < facePaths.length; i++) {
      final label = i < labels.length ? labels[i] : '人物${i + 1}';
      final faceJson = await extractFaceFeatures(
        facePaths[i],
        personLabel: label,
      );
      faceJsons.add({...faceJson, '_label': label, '_path': facePaths[i]});
    }

    // Step 2: 获取风格特征
    onProgress?.call(2, '正在分析风格特征...');
    Map<String, dynamic> styleJson;
    if (customStylePath != null) {
      styleJson = await extractStyleFeatures(customStylePath);
    } else {
      styleJson = buildPresetStyleFeatures(style);
    }

    // Step 3: LLM 整合生成提示词
    onProgress?.call(3, '正在生成提示词...');
    final prompt = await generatePrompt(faceJsons, styleJson);

    // Step 4: 调用 Seedream 生成图片
    onProgress?.call(4, '正在生成图片...');
    final generatedImageUrl = await generateImage(
      prompt,
      facePaths,
      stylePath: customStylePath,
    );

    debugPrint('');
    debugPrint('  Pipeline 完成!');

    // 合并人像特征（单人取第一个，多人合并为列表）
    final mergedFaceFeatures = <String, dynamic>{};
    if (faceJsons.length == 1) {
      mergedFaceFeatures.addAll(
        Map<String, dynamic>.from(faceJsons[0])
          ..removeWhere((k, _) => k.startsWith('_')),
      );
    } else {
      mergedFaceFeatures['people'] = faceJsons
          .map((fj) => Map<String, dynamic>.from(fj)
            ..removeWhere((k, _) => k.startsWith('_')))
          .toList();
    }

    return GenerationResult(
      originalImagePath: facePaths.first,
      generatedImageUrl: generatedImageUrl,
      styleName: style.name,
      prompt: prompt,
      faceFeatures: mergedFaceFeatures,
      styleFeatures: styleJson,
      createdAt: DateTime.now(),
    );
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
