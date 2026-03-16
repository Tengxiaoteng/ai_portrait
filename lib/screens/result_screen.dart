/// 生成结果展示页面
///
/// 平板横屏布局：
/// - 单张结果：左右分栏对比原始照片与生成结果
/// - 多张结果：横向滑动画廊 + 缩略图条
/// 支持双指缩放、全屏查看、保存相册、分享、打印等操作。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/adaptive_image.dart';

// ─── 设计常量 ──────────────────────────────────────────

const Color _bgColor = Color(0xFF0D0D0D);
const Color _surfaceColor = Color(0xFF1A1A1A);
const Color _accentColor = Color(0xFFF5A623);
const Color _secondaryColor = Color(0xFFFF8C42);
const Color _borderColor = Color(0xFF333333);

class ResultScreen extends StatefulWidget {
  /// 多张结果列表，每个 map 包含:
  /// - 'originalPath': 原始照片路径
  /// - 'generatedPath': 生成结果路径
  /// - 'styleName': 风格名称
  final List<Map<String, String>> results;

  /// 生成使用的提示词
  final String prompt;

  // ── 兼容旧接口的工厂构造 ──

  /// 单张结果的便捷构造（兼容旧调用方式）
  ResultScreen.single({
    super.key,
    required String originalImagePath,
    required String generatedImagePath,
    required String styleName,
    required this.prompt,
  }) : results = [
         {
           'originalPath': originalImagePath,
           'generatedPath': generatedImagePath,
           'styleName': styleName,
         },
       ];

  /// 多张结果构造
  const ResultScreen({
    super.key,
    required this.results,
    required this.prompt,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final PageController _pageController;
  bool _isPromptExpanded = false;
  int _currentIndex = 0;

  bool get _isMultiple => widget.results.length > 1;

  @override
  void initState() {
    super.initState();
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _pageController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    // 恢复方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ─── 构建 UI ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // 顶部标题栏
              _buildTopBar(),
              // 图片区域
              Expanded(
                child: _isMultiple
                    ? _buildGalleryArea()
                    : _buildComparisonArea(),
              ),
              // 提示词折叠区
              _buildPromptSection(),
              // 底部操作栏
              _buildActionBar(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 顶部栏 ──────────────────────────────────────────

  Widget _buildTopBar() {
    final titleText = _isMultiple
        ? '第 ${_currentIndex + 1}/${widget.results.length} 张 · ${widget.results[_currentIndex]['styleName'] ?? ''}'
        : '生成结果';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            titleText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // 平衡返回按钮宽度
        ],
      ),
    );
  }

  // ─── 单张对比区 ────────────────────────────────────────

  Widget _buildComparisonArea() {
    final result = widget.results.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // 左侧：原始照片（45%）
          Expanded(
            flex: 45,
            child: _buildImageCard(
              label: '原始照片',
              imagePath: result['originalPath']!,
              labelColor: Colors.white70,
            ),
          ),
          // 中间：VS 分隔符（10%）
          Expanded(
            flex: 10,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_accentColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 右侧：生成结果（45%）
          Expanded(
            flex: 45,
            child: _buildImageCard(
              label: result['styleName'] ?? '',
              imagePath: result['generatedPath']!,
              labelColor: _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 多张画廊区 ────────────────────────────────────────

  Widget _buildGalleryArea() {
    return Column(
      children: [
        // 大图滑动
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.results.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final result = widget.results[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GestureDetector(
                  onTap: () => _openFullScreen(
                    result['generatedPath']!,
                    result['styleName'] ?? '',
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: AdaptiveImage(
                          path: result['generatedPath']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // 缩略图条
        _buildThumbnailBar(),
      ],
    );
  }

  Widget _buildThumbnailBar() {
    return SizedBox(
      height: 64,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          itemCount: widget.results.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = index == _currentIndex;
            final result = widget.results[index];
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? _accentColor : _borderColor,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AdaptiveImage(
                    path: result['generatedPath']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── 图片卡片（单张对比用） ────────────────────────────

  Widget _buildImageCard({
    required String label,
    required String imagePath,
    required Color labelColor,
  }) {
    return Column(
      children: [
        // 标签
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // 图片卡片
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullScreen(imagePath, label),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: AdaptiveImage(
                    path: imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      color: _surfaceColor,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 提示词折叠区 ────────────────────────────────────

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: GestureDetector(
        onTap: () => setState(() {
          _isPromptExpanded = !_isPromptExpanded;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: _accentColor.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '生成提示词',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isPromptExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
              if (_isPromptExpanded) ...[
                const SizedBox(height: 8),
                Text(
                  widget.prompt,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── 底部操作栏 ──────────────────────────────────────

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPrimaryButton(
            icon: Icons.save_alt_rounded,
            label: _isMultiple ? '保存全部' : '保存到相册',
            onPressed: _onSave,
          ),
          const SizedBox(width: 12),
          _buildPrimaryButton(
            icon: Icons.print_rounded,
            label: _isMultiple ? '打印全部' : '打印',
            onPressed: _onPrint,
          ),
          const SizedBox(width: 12),
          _buildSecondaryButton(
            icon: Icons.share_outlined,
            label: '分享',
            onPressed: _onShare,
          ),
          const SizedBox(width: 12),
          _buildSecondaryButton(
            icon: Icons.style_outlined,
            label: '换个风格',
            onPressed: _onChangeStyle,
          ),
          const SizedBox(width: 12),
          _buildSecondaryButton(
            icon: Icons.refresh_rounded,
            label: '重新生成',
            onPressed: _onRegenerate,
          ),
          const SizedBox(width: 12),
          _buildSecondaryButton(
            icon: Icons.home_outlined,
            label: '返回首页',
            onPressed: _onGoHome,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_accentColor, _secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _surfaceColor,
            border: Border.all(color: _borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF888888), size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 全屏查看 ────────────────────────────────────────

  void _openFullScreen(String imagePath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _FullScreenViewer(
          imagePath: imagePath,
          title: title,
        ),
      ),
    );
  }

  // ─── 操作回调 ────────────────────────────────────────

  void _onSave() {
    if (_isMultiple) {
      // TODO: 接入 image_gallery_saver 批量保存
      _showToast('已保存全部 ${widget.results.length} 张到相册');
    } else {
      // TODO: 接入 image_gallery_saver 或 photo_manager 保存到相册
      _showToast('已保存到相册');
    }
  }

  void _onPrint() {
    if (_isMultiple) {
      _showToast('正在连接打印机... (${widget.results.length} 张)');
    } else {
      _showToast('正在连接打印机...');
    }
    // TODO: 接入真实打印服务
  }

  void _onShare() {
    // TODO: 接入 share_plus 分享功能
    _showToast('分享功能开发中');
  }

  void _onChangeStyle() {
    // 返回到风格选择页面（弹出到 StylePickerScreen）
    // TODO: 根据实际路由栈调整 popUntil 条件
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onRegenerate() {
    // 同风格重新生成：返回 ProcessingScreen
    Navigator.of(context).pop();
  }

  void _onGoHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 120, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── 全屏查看器 ────────────────────────────────────────

class _FullScreenViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const _FullScreenViewer({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 6.0,
          child: AdaptiveImage(
            path: imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
