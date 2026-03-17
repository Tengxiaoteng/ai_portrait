import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/style_data.dart';
import 'camera_screen.dart';
import 'style_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _scrollCtrl;
  late final AnimationController _pulseCtrl;

  int get _styleCount => StyleData.allStyles.length;

  // 照片墙 - 真实图片
  static const _col1 = [
    _Img('油画', 'assets/styles/oil_painting.jpg'),
    _Img('赛博朋克', 'assets/styles/cyberpunk.jpg'),
    _Img('古装汉服', 'assets/styles/hanfu.jpg'),
    _Img('3D皮克斯', 'assets/styles/pixar.jpg'),
    _Img('日系清新', 'assets/styles/japanese.jpg'),
    _Img('情侣写真', 'assets/styles/couple.jpg'),
    _Img('毕业照', 'assets/styles/graduation.jpg'),
  ];
  static const _col2 = [
    _Img('动漫', 'assets/styles/anime.jpg'),
    _Img('水彩', 'assets/styles/watercolor.jpg'),
    _Img('婚纱照', 'assets/styles/wedding.jpg'),
    _Img('暗黑哥特', 'assets/styles/gothic.jpg'),
    _Img('商务照', 'assets/styles/business.jpg'),
    _Img('全家福', 'assets/styles/family.jpg'),
    _Img('旅行风', 'assets/styles/travel.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 45))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _go() {
    final target = kIsWeb
        ? const StylePickerScreen(imagePaths: ['mock_photo.jpg'])
        : const CameraScreen();
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => target,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EE),
      body: Row(children: [
        Expanded(flex: 50, child: _leftSide()),
        Expanded(flex: 50, child: _rightSide()),
      ]),
    );
  }

  // ════════════════════════════════════════
  //  左侧 - 温暖编辑式排版
  // ════════════════════════════════════════
  Widget _leftSide() {
    return Container(
      color: const Color(0xFFF6F2EE),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 40, top: 36, bottom: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部品牌标签
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFFD4A056), size: 14),
                        SizedBox(width: 6),
                        Text('AI STUDIO', style: TextStyle(
                          fontSize: 11, color: Color(0xFFD4D4D4),
                          letterSpacing: 3, fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // 大标题
              const Text('PORTRAIT', style: TextStyle(
                fontSize: 58, fontWeight: FontWeight.w300,
                color: Color(0xFF2D2D2D), letterSpacing: 10, height: 1.0,
              )),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('STUDIO', style: TextStyle(
                    fontSize: 58, fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D), letterSpacing: 10, height: 1.0,
                  )),
                  Container(
                    width: 10, height: 10,
                    margin: const EdgeInsets.only(left: 8, bottom: 12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD4A056),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 分割线+中文
              Row(children: [
                Container(width: 28, height: 2, color: const Color(0xFFD4A056)),
                const SizedBox(width: 14),
                const Text('人 像 写 真', style: TextStyle(
                  fontSize: 13, color: Color(0xFF999999), letterSpacing: 8,
                )),
              ]),

              const SizedBox(height: 28),

              // 描述
              Text(
                '拍摄一张照片，AI 为你智能生成\n${_styleCount}+ 种不同艺术风格的高清写真',
                style: const TextStyle(
                  fontSize: 15, color: Color(0xFF999999), height: 1.8, letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 32),

              // 指标
              Row(children: [
                _metric('${_styleCount}+', '风格'),
                const SizedBox(width: 32),
                _metric('4K', '分辨率'),
                const SizedBox(width: 32),
                _metric('60s', '生成'),
              ]),

              const Spacer(flex: 2),

              // 拍照按钮
              _shootBtn(),

              const SizedBox(height: 16),

              // 底部备注
              const Text(
                '支持单人 · 双人 · 全家福拍照',
                style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB), letterSpacing: 1),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: const TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: Color(0xFFD4A056), letterSpacing: 2,
        )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
          fontSize: 11, color: Color(0xFFAAAAAA), letterSpacing: 2,
        )),
      ],
    );
  }

  Widget _shootBtn() {
    return GestureDetector(
      onTap: _go,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + _pulseCtrl.value * 0.006,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: const Color(0xFF2D2D2D),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D2D2D).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('开始拍照', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.white, letterSpacing: 4,
              )),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Color(0xFFD4A056), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  //  右侧 - 亮色双列竖向滚动
  // ════════════════════════════════════════
  Widget _rightSide() {
    return Stack(children: [
      // 浅色底
      Container(color: const Color(0xFFF0EBE5)),
      // 双列照片
      LayoutBuilder(builder: (ctx, constraints) {
        final colW = (constraints.maxWidth - 34) / 2; // 12+10+12 padding
        final cardH = colW * 1.5; // 2:3 比例
        return AnimatedBuilder(
          animation: _scrollCtrl,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Expanded(child: _vCol(_col1, _scrollCtrl.value, false, cardH)),
              const SizedBox(width: 10),
              Expanded(child: _vCol(_col2, _scrollCtrl.value, true, cardH)),
            ]),
          ),
        );
      }),
      // 上渐隐
      Positioned(top: 0, left: 0, right: 0, height: 80,
        child: Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFFF0EBE5), const Color(0xFFF0EBE5).withOpacity(0)],
        ))),
      ),
      // 下渐隐
      Positioned(bottom: 0, left: 0, right: 0, height: 80,
        child: Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [const Color(0xFFF0EBE5), const Color(0xFFF0EBE5).withOpacity(0)],
        ))),
      ),
      // 左渐隐（衔接左区域）
      Positioned(top: 0, bottom: 0, left: 0, width: 40,
        child: Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [const Color(0xFFF6F2EE), const Color(0xFFF6F2EE).withOpacity(0)],
        ))),
      ),
    ]);
  }

  Widget _vCol(List<_Img> items, double t, bool rev, double ch) {
    const gap = 10.0;
    final unit = ch + gap;
    final total = items.length * unit;
    final all = [...items, ...items, ...items];
    final dy = rev ? t * total : -t * total;

    return ClipRect(
      child: OverflowBox(
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: Offset(0, -total + (dy % total)),
          child: Column(
            children: all.map((img) => Padding(
              padding: const EdgeInsets.only(bottom: gap),
              child: _card(img, ch),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _card(_Img img, double h) {
    return Container(
      height: h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          // 真实图片
          Positioned.fill(
            child: Image.asset(
              img.asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD4C4B0),
                child: const Center(child: Icon(Icons.image, color: Colors.white38, size: 32)),
              ),
            ),
          ),
          // 底部渐变遮罩
          Positioned(
            left: 0, right: 0, bottom: 0, height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          // 标签
          Positioned(
            left: 12, bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Text(img.name, style: const TextStyle(
                fontSize: 12, color: Colors.white,
                fontWeight: FontWeight.w600, letterSpacing: 2,
              )),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Img {
  final String name;
  final String asset;
  const _Img(this.name, this.asset);
}
