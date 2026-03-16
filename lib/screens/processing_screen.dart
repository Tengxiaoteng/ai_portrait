/// AI 生成等待页面
///
/// 展示带高级动效的加载状态：呼吸光效照片、旋转光环、
/// 打字机步骤文字、流动渐变进度条。
/// 生成完成后自动跳转 ResultScreen。
library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/style_model.dart';
import 'result_screen.dart';

/// 处理步骤描述
const List<String> _stepTexts = [
  '正在分析人像特征...',
  '正在解析风格要素...',
  '正在融合创意灵感...',
  '正在生成 4K 高清图片...',
];

/// 每步持续时间
const Duration _stepDuration = Duration(seconds: 12);

/// 总生成时间（模拟）
const Duration _totalDuration = Duration(seconds: 48);

class ProcessingScreen extends StatefulWidget {
  /// 用户选择的照片路径列表
  final List<String> imagePaths;

  /// 选择的风格
  final StyleModel style;

  /// 自定义风格参考图路径（可选）
  final String? customStylePath;

  const ProcessingScreen({
    super.key,
    required this.imagePaths,
    required this.style,
    this.customStylePath,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  // ─── 动画控制器 ──────────────────────────────────────

  /// 呼吸缩放动画
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  /// 光环旋转动画
  late final AnimationController _haloController;

  /// 进度条流动渐变动画
  late final AnimationController _shimmerController;

  // ─── 状态 ────────────────────────────────────────────

  int _currentStep = 0;
  double _progress = 0.0;
  String _displayedText = '';
  bool _isDisposed = false;

  Timer? _stepTimer;
  Timer? _progressTimer;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTypewriter(_stepTexts[0]);
    _startProcessing();
  }

  void _initAnimations() {
    // 呼吸缩放：1.0 → 1.06 循环
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathController.repeat(reverse: true);

    // 光环旋转
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 进度条流动
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  // ─── 模拟生成流程 ────────────────────────────────────

  void _startProcessing() {
    // 进度条平滑更新
    const progressTick = Duration(milliseconds: 200);
    final totalTicks = _totalDuration.inMilliseconds ~/ progressTick.inMilliseconds;
    int tick = 0;

    _progressTimer = Timer.periodic(progressTick, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      tick++;
      setState(() {
        _progress = (tick / totalTicks).clamp(0.0, 1.0);
      });
      if (tick >= totalTicks) {
        timer.cancel();
      }
    });

    // 步骤文字切换
    _stepTimer = Timer.periodic(_stepDuration, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      final nextStep = _currentStep + 1;
      if (nextStep < _stepTexts.length) {
        setState(() {
          _currentStep = nextStep;
        });
        _startTypewriter(_stepTexts[nextStep]);
      } else {
        timer.cancel();
      }
    });

    // TODO: 接入 PortraitApiService 替换 mock 流程
    // 实际调用示例:
    // final result = await PortraitApiService.generate(
    //   imagePaths: widget.imagePaths,
    //   style: widget.style,
    //   customStylePath: widget.customStylePath,
    // );
    Future.delayed(_totalDuration, _onGenerationComplete);
  }

  void _onGenerationComplete() {
    if (_isDisposed || !mounted) return;

    // TODO: 替换为实际生成结果
    final mockGeneratedPath = widget.imagePaths.first;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
          originalImagePath: widget.imagePaths.first,
          generatedImagePath: mockGeneratedPath,
          styleName: widget.style.name,
          prompt: '${widget.style.promptHint} (mock prompt)',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // ─── 打字机效果 ──────────────────────────────────────

  void _startTypewriter(String text) {
    _typewriterTimer?.cancel();
    _displayedText = '';
    int charIndex = 0;

    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 60),
      (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        if (charIndex < text.length) {
          setState(() {
            _displayedText = text.substring(0, charIndex + 1);
          });
          charIndex++;
        } else {
          timer.cancel();
        }
      },
    );
  }

  // ─── 释放资源 ────────────────────────────────────────

  @override
  void dispose() {
    _isDisposed = true;
    _stepTimer?.cancel();
    _progressTimer?.cancel();
    _typewriterTimer?.cancel();
    _breathController.dispose();
    _haloController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ─── 构建 UI ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildPhotoWithHalo(),
                const SizedBox(height: 48),
                _buildStepText(),
                const SizedBox(height: 32),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildTimeEstimate(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 照片 + 呼吸光效 + 旋转光环
  Widget _buildPhotoWithHalo() {
    const double photoSize = 200.0;
    const double haloSize = 260.0;

    return SizedBox(
      width: haloSize + 20,
      height: haloSize + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 旋转光环
          AnimatedBuilder(
            animation: _haloController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _haloController.value * 2 * math.pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(haloSize, haloSize),
              painter: _HaloPainter(),
            ),
          ),
          // 呼吸缩放照片
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: photoSize,
              height: photoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3C72).withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildPhotoImage(photoSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoImage(double size) {
    final path = widget.imagePaths.first;
    final file = File(path);

    if (file.existsSync()) {
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) => _buildPlaceholder(size),
      );
    }
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1A1F36),
      child: const Icon(Icons.person, size: 80, color: Colors.white24),
    );
  }

  /// 步骤文字（带 fade 过渡 + 打字机效果）
  Widget _buildStepText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        key: ValueKey<int>(_currentStep),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Text(
              _displayedText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '步骤 ${_currentStep + 1} / ${_stepTexts.length}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 渐变流动进度条
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // 背景轨道
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // 填充部分
                  FractionallySizedBox(
                    widthFactor: _progress,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: const [
                                Color(0xFF1E3C72),
                                Color(0xFF2A5298),
                                Color(0xFF1E3C72),
                              ],
                              stops: [
                                (_shimmerController.value - 0.3)
                                    .clamp(0.0, 1.0),
                                _shimmerController.value,
                                (_shimmerController.value + 0.3)
                                    .clamp(0.0, 1.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 预计等待时间
  Widget _buildTimeEstimate() {
    final remaining =
        ((_totalDuration.inSeconds) * (1.0 - _progress)).round();
    return Text(
      '大约需要 $remaining 秒',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 14,
      ),
    );
  }
}

// ─── 光环画笔 ──────────────────────────────────────────

class _HaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // 绘制多段渐变弧线
    const arcCount = 3;
    const sweepAngle = math.pi * 0.6;
    const gapAngle = (2 * math.pi - sweepAngle * arcCount) / arcCount;

    for (int i = 0; i < arcCount; i++) {
      final startAngle = i * (sweepAngle + gapAngle);
      final opacity = 0.3 + 0.4 * (i / arcCount);

      paint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          const Color(0xFF1E3C72).withValues(alpha: 0.0),
          Color.fromRGBO(30, 60, 114, opacity),
          const Color(0xFFFF6B6B).withValues(alpha: opacity),
          const Color(0xFF1E3C72).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
