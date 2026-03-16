import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _floatController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openCamera() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CameraScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变
          _buildBackground(),
          // 浮动光效
          ..._buildFloatingOrbs(),
          // 主内容
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E21),
            Color(0xFF141B3D),
            Color(0xFF0D1232),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      // 左上蓝色光球
      AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) {
          final t = _floatController.value * 2 * math.pi;
          return Positioned(
            left: -80 + math.sin(t) * 20,
            top: -60 + math.cos(t) * 15,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E3C72).withOpacity(0.4),
                    const Color(0xFF1E3C72).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // 右下紫色光球
      AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) {
          final t = _floatController.value * 2 * math.pi;
          return Positioned(
            right: -100 + math.cos(t) * 25,
            bottom: -80 + math.sin(t) * 20,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.3),
                    const Color(0xFF6C63FF).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // 中间粉色光球
      AnimatedBuilder(
        animation: _breathController,
        builder: (_, __) {
          return Positioned(
            right: 200,
            top: 80,
            child: Opacity(
              opacity: 0.15 + _breathController.value * 0.1,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.5),
                      const Color(0xFFFF6B6B).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Row(
          children: [
            // 左侧：标题区
            Expanded(
              flex: 5,
              child: _buildLeftSection(),
            ),
            const SizedBox(width: 48),
            // 右侧：拍照按钮 + 风格预览
            Expanded(
              flex: 5,
              child: _buildRightSection(size),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo 区域
        AnimatedBuilder(
          animation: _breathController,
          builder: (_, __) {
            return Transform.scale(
              scale: 1.0 + _breathController.value * 0.02,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        // 主标题
        const Text(
          'AI 人像写真',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
          ).createShader(bounds),
          child: const Text(
            'PORTRAIT STUDIO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '拍一张照片，AI 为你生成 32 种艺术风格\n油画 · 动漫 · 赛博朋克 · 古装汉服 · 情侣写真 ...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.5),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        // 数据指标
        Row(
          children: [
            _buildStat('32', '种风格'),
            const SizedBox(width: 40),
            _buildStat('4K', '超高清'),
            const SizedBox(width: 40),
            _buildStat('60s', '极速生成'),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildRightSection(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 拍照大按钮（毛玻璃卡片）
        _buildCameraButton(),
        const SizedBox(height: 36),
        // 风格预览横条
        _buildStylePreviewRow(),
      ],
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _openCamera,
      child: AnimatedBuilder(
        animation: _breathController,
        builder: (_, child) {
          return Transform.scale(
            scale: 1.0 + _breathController.value * 0.01,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 拍照图标（带光环）
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '点击拍照',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '拍摄一张清晰的正面照',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStylePreviewRow() {
    final styles = [
      ('油画', const Color(0xFFE8A87C), Icons.brush),
      ('动漫', const Color(0xFFCE93D8), Icons.animation),
      ('赛博', const Color(0xFF64B5F6), Icons.memory),
      ('汉服', const Color(0xFF81C784), Icons.checkroom),
      ('商务', const Color(0xFF90A4AE), Icons.business_center),
      ('水彩', const Color(0xFF80DEEA), Icons.water_drop),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '可选风格',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '共 32 种 >',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: styles.map((s) {
                  return _buildStyleChip(s.$1, s.$2, s.$3);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(String name, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withOpacity(0.15),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color.withOpacity(0.8), size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
