import 'style_model.dart';

/// 多人合照风格的构图提示映射
const Map<String, String> groupCompositionHints = {
  '情侣写真': '两人面对面或并肩，有自然的互动（牵手、依偎、对视），构图突出两人关系',
  '闺蜜照': '两人动作活泼有趣（背靠背、搭肩、比心），表情欢快，可以穿搭呼应',
  '兄弟照': '两人站姿随性潇洒（搭肩、击拳、并排站），表情自然自信',
  '全家福': '家庭成员自然聚集，大人在后小孩在前，或围坐一起，突出温馨幸福感',
  '亲子照': '父母与孩子有亲密互动（抱、举高、亲吻脸颊），展现亲子间的爱与快乐',
};

/// Static repository of all 32 available portrait styles.
class StyleData {
  StyleData._();

  static const List<StyleModel> allStyles = [
    // ─── 艺术绘画 (8) ────────────────────────────────

    StyleModel(
      name: '油画',
      category: StyleCategory.artPainting,
      description: '古典欧洲油画风格，厚重的笔触，温暖的光影，伦勃朗式打光',
      promptHint:
          'classical oil painting, thick brushstrokes, warm lighting, '
          'Rembrandt style, museum quality, canvas texture, rich colors, '
          'gender-appropriate classical attire, men wear tailored coat or '
          'shirt with cravat, women wear elegant period dress',
      peopleCount: 1,
    ),
    StyleModel(
      name: '水彩',
      category: StyleCategory.artPainting,
      description: '水彩画风格，透明感，色彩渐变，留白',
      promptHint:
          'watercolor painting, soft gradients, translucent layers, '
          'artistic splashes, paper texture, delicate brushwork, '
          'flowing colors',
      peopleCount: 1,
    ),
    StyleModel(
      name: '素描',
      category: StyleCategory.artPainting,
      description: '铅笔素描风格，黑白灰调，细腻的阴影和线条',
      promptHint:
          'pencil sketch portrait, black and white, detailed shading, '
          'fine lines, graphite drawing, realistic sketch, '
          'hatching technique',
      peopleCount: 1,
    ),
    StyleModel(
      name: '国风水墨',
      category: StyleCategory.artPainting,
      description: '中国传统水墨画风格，写意留白，墨色浓淡变化',
      promptHint:
          'Chinese ink wash painting, traditional brush art, '
          'elegant minimalism, ink gradients, xuan paper texture, '
          'Song dynasty style portrait',
      peopleCount: 1,
    ),
    StyleModel(
      name: '波普艺术',
      category: StyleCategory.artPainting,
      description: '安迪沃霍尔式波普艺术，高饱和色块，网点效果',
      promptHint:
          'pop art portrait, Andy Warhol style, bold colors, '
          'halftone dots, high contrast, comic book aesthetics, '
          'vibrant, screen print',
      peopleCount: 1,
    ),
    StyleModel(
      name: '印象派',
      category: StyleCategory.artPainting,
      description: '莫奈式印象派风格，光影斑驳，色彩柔和，户外自然光',
      promptHint:
          'impressionist painting, Monet style, dappled light, '
          'soft brushstrokes, plein air, pastel colors, '
          'dreamy atmosphere, garden scene',
      peopleCount: 1,
    ),
    StyleModel(
      name: '浮世绘',
      category: StyleCategory.artPainting,
      description: '日本浮世绘版画风格，平面色块，流畅线条，和风元素',
      promptHint:
          'ukiyo-e Japanese woodblock print, flat colors, bold outlines, '
          'traditional Japanese art, Hokusai style, elegant composition',
      peopleCount: 1,
    ),
    StyleModel(
      name: '彩铅',
      category: StyleCategory.artPainting,
      description: '彩色铅笔手绘风格，柔和渐变，细腻纹理，温暖手感',
      promptHint:
          'colored pencil drawing, soft blending, detailed texture, '
          'hand-drawn warmth, realistic colored pencil portrait, '
          'paper grain',
      peopleCount: 1,
    ),

    // ─── 动漫卡通 (5) ────────────────────────────────

    StyleModel(
      name: '动漫',
      category: StyleCategory.animeCartoon,
      description: '日系动漫风格，大眼睛，干净的线条，明亮的色彩',
      promptHint:
          'anime style portrait, clean lines, vibrant colors, '
          'detailed eyes, cel shading, studio ghibli quality, '
          'Japanese animation',
      peopleCount: 1,
    ),
    StyleModel(
      name: '3D皮克斯',
      category: StyleCategory.animeCartoon,
      description: '皮克斯3D动画风格，夸张可爱的五官，柔和的渲染',
      promptHint:
          '3D Pixar Disney style, soft rendering, exaggerated cute '
          'features, cartoon portrait, smooth skin, big expressive eyes, '
          'CGI quality',
      peopleCount: 1,
    ),
    StyleModel(
      name: '漫画',
      category: StyleCategory.animeCartoon,
      description: '美式漫画风格，粗线条，浓重阴影，超级英雄感',
      promptHint:
          'American comic book style, bold ink lines, dramatic shadows, '
          'Marvel DC aesthetics, heroic pose, dynamic composition, '
          'vibrant coloring',
      peopleCount: 1,
    ),
    StyleModel(
      name: 'Q版',
      category: StyleCategory.animeCartoon,
      description: 'Q版大头娃娃风格，2头身比例，圆润可爱',
      promptHint:
          'chibi style, super deformed, big head small body, cute kawaii, '
          'round face, simplified features, adorable cartoon, '
          'pastel colors',
      peopleCount: 1,
    ),
    StyleModel(
      name: '像素风',
      category: StyleCategory.animeCartoon,
      description: '复古像素游戏风格，8bit色彩，方块感',
      promptHint:
          'pixel art portrait, 8-bit retro game style, blocky pixels, '
          'limited color palette, nostalgic gaming aesthetics, sprite art',
      peopleCount: 1,
    ),

    // ─── 摄影风格 (8) ────────────────────────────────

    StyleModel(
      name: '商务照',
      category: StyleCategory.photography,
      description: '专业商务头像，干净背景，柔和打光，职业着装',
      promptHint:
          'professional business headshot, clean solid background, '
          'soft studio lighting, formal attire, corporate portrait, '
          'sharp focus, confident',
      peopleCount: 1,
    ),
    StyleModel(
      name: '复古胶片',
      category: StyleCategory.photography,
      description: '80年代胶片摄影风格，颗粒感，偏暖色调，怀旧',
      promptHint:
          'vintage film photography, 80s retro style, film grain, '
          'warm color cast, nostalgic mood, kodak portra colors, '
          'analog feel',
      peopleCount: 1,
    ),
    StyleModel(
      name: '赛博朋克',
      category: StyleCategory.photography,
      description: '赛博朋克风格，霓虹灯光，未来感，暗色调配高对比度',
      promptHint:
          'cyberpunk portrait, neon lights, futuristic city, '
          'dark atmosphere, high contrast, glowing effects, '
          'rain reflections, sci-fi',
      peopleCount: 1,
    ),
    StyleModel(
      name: '黑白电影',
      category: StyleCategory.photography,
      description: '经典黑白电影质感，强烈明暗对比，好莱坞黄金年代',
      promptHint:
          'classic black and white film noir, high contrast, '
          'dramatic shadows, Hollywood golden age, cinematic lighting, '
          'elegant monochrome',
      peopleCount: 1,
    ),
    StyleModel(
      name: '时尚杂志',
      category: StyleCategory.photography,
      description: '高端时尚杂志封面，精致打光，高级感色调',
      promptHint:
          'high fashion magazine cover, Vogue style, editorial lighting, '
          'glamorous, high-end retouching, sophisticated color grading, '
          'luxury',
      peopleCount: 1,
    ),
    StyleModel(
      name: '街拍',
      category: StyleCategory.photography,
      description: '城市街拍风格，自然光线，随性姿态，都市背景',
      promptHint:
          'urban street photography, natural lighting, candid pose, '
          'city background, casual style, depth of field, '
          'lifestyle photography',
      peopleCount: 1,
    ),
    StyleModel(
      name: '日系清新',
      category: StyleCategory.photography,
      description: '日系小清新风格，柔和过曝，淡雅色调，温柔氛围',
      promptHint:
          'Japanese soft photography, overexposed light, pastel tones, '
          'gentle atmosphere, airy feeling, natural daylight, '
          'dreamy soft focus',
      peopleCount: 1,
    ),
    StyleModel(
      name: '暗黑哥特',
      category: StyleCategory.photography,
      description: '哥特暗黑风格，深色调，神秘氛围，戏剧性光影',
      promptHint:
          'dark gothic portrait, moody shadows, mysterious atmosphere, '
          'dramatic chiaroscuro, dark elegance, Victorian gothic, '
          'haunting beauty',
      peopleCount: 1,
    ),

    // ─── 场景主题 (6) ────────────────────────────────

    StyleModel(
      name: '古装汉服',
      category: StyleCategory.sceneTheme,
      description: '中国古装汉服写真，古风发型，传统妆容，古典园林背景',
      promptHint:
          'Chinese traditional Hanfu costume, ancient hairstyle, '
          'classical garden background, Tang dynasty style, silk robes, '
          'elegant pose, cultural beauty',
      peopleCount: 1,
    ),
    StyleModel(
      name: '婚纱照',
      category: StyleCategory.sceneTheme,
      description: '唯美婚纱写真风格，白纱或西装，浪漫花园或教堂背景',
      promptHint:
          'romantic wedding portrait, beautiful wedding dress or '
          'formal suit, soft dreamy lighting, flower garden or church '
          'background, love atmosphere',
      peopleCount: 1,
    ),
    StyleModel(
      name: '运动活力',
      category: StyleCategory.sceneTheme,
      description: '运动风格写真，活力姿态，运动服饰，阳光户外',
      promptHint:
          'athletic sports portrait, dynamic pose, sportswear, '
          'outdoor sunshine, energetic vibe, healthy glow, '
          'action photography, fitness',
      peopleCount: 1,
    ),
    StyleModel(
      name: '旅行风',
      category: StyleCategory.sceneTheme,
      description: '旅行写真风格，异域风情背景，自然风光，轻松度假感',
      promptHint:
          'travel photography portrait, exotic location, natural scenery, '
          'casual vacation style, golden hour light, wanderlust, '
          'adventure vibe',
      peopleCount: 1,
    ),
    StyleModel(
      name: '圣诞节',
      category: StyleCategory.sceneTheme,
      description: '圣诞节主题，红绿配色，圣诞树/壁炉，温馨节日氛围',
      promptHint:
          'Christmas themed portrait, red and green colors, '
          'Christmas tree, fireplace, cozy holiday atmosphere, '
          'warm lights, festive sweater, snow',
      peopleCount: 1,
    ),
    StyleModel(
      name: '毕业照',
      category: StyleCategory.sceneTheme,
      description: '毕业典礼风格，学士帽学士服，校园背景，青春朝气',
      promptHint:
          'graduation portrait, cap and gown, campus background, '
          'youthful energy, achievement celebration, academic setting, '
          'proud smile',
      peopleCount: 1,
    ),

    // ─── 多人合照 (5) ────────────────────────────────

    StyleModel(
      name: '情侣写真',
      category: StyleCategory.groupPhoto,
      description: '情侣双人写真，浪漫互动，温馨甜蜜，柔和光线',
      promptHint:
          'romantic couple portrait, two people, intimate interaction, '
          'warm soft lighting, love and tenderness, beautiful background, '
          'holding hands or embracing',
      peopleCount: 2,
    ),
    StyleModel(
      name: '闺蜜照',
      category: StyleCategory.groupPhoto,
      description: '闺蜜双人写真，欢快活泼，姐妹情深，时尚穿搭',
      promptHint:
          'best friends portrait, two people, cheerful and playful, '
          'matching outfits, fun poses, bright colors, friendship vibes, '
          'laughing together',
      peopleCount: 2,
    ),
    StyleModel(
      name: '兄弟照',
      category: StyleCategory.groupPhoto,
      description: '兄弟双人合照，潇洒帅气，默契十足，酷感风格',
      promptHint:
          'bromance portrait, two men, cool and confident, stylish '
          'casual wear, relaxed poses, urban background, friendship bond, '
          'natural chemistry',
      peopleCount: 2,
    ),
    StyleModel(
      name: '全家福',
      category: StyleCategory.groupPhoto,
      description: '温馨全家福，家庭成员合影，幸福温暖，统一着装风格',
      promptHint:
          'warm family portrait, family members together, happy and '
          'loving, coordinated outfits, soft warm lighting, cozy home or '
          'garden background, genuine smiles',
      peopleCount: 6,
    ),
    StyleModel(
      name: '亲子照',
      category: StyleCategory.groupPhoto,
      description: '亲子互动写真，父母与孩子，天真烂漫，温情时刻',
      promptHint:
          'parent-child portrait, loving interaction, playful moment, '
          'warm natural lighting, tender embrace, joyful expressions, '
          'family love, candid feel',
      peopleCount: 3,
    ),
  ];

  /// Returns styles filtered by [category].
  /// If [category] is [StyleCategory.all], returns all styles.
  static List<StyleModel> byCategory(String category) {
    if (category == StyleCategory.all) return allStyles;
    return allStyles.where((s) => s.category == category).toList();
  }

  /// Returns all single-person styles (peopleCount == 1).
  static List<StyleModel> get singleStyles =>
      allStyles.where((s) => s.peopleCount == 1).toList();

  /// Returns all group styles (peopleCount > 1).
  static List<StyleModel> get groupOnlyStyles =>
      allStyles.where((s) => s.peopleCount > 1).toList();

  /// Find a style by its exact name, or null if not found.
  static StyleModel? findByName(String name) {
    for (final style in allStyles) {
      if (style.name == name) return style;
    }
    return null;
  }

  /// Returns the composition hint for a group style, or null.
  static String? getCompositionHint(String styleName) {
    return groupCompositionHints[styleName];
  }
}
