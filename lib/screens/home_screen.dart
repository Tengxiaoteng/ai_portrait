import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_screen.dart';

/// Home screen for AI Portrait app.
/// Tablet landscape layout with gradient background,
/// action buttons, and style preview thumbnails.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primaryDark = Color(0xFF1E3C72);
  static const _primaryLight = Color(0xFF6C63FF);
  static const _accent = Color(0xFFFF6B6B);

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _StylePickerPlaceholder(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryDark, Color(0xFF2A0845)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildActionButtons(context, screenSize),
              const Spacer(flex: 2),
              _buildStylePreviews(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AI \u4eba\u50cf\u5199\u771f',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '\u4e0a\u4f20\u7167\u7247\uff0c\u4e00\u952e\u751f\u6210 32 \u79cd\u827a\u672f\u98ce\u683c',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Size screenSize) {
    final buttonWidth = (screenSize.width * 0.35).clamp(200.0, 360.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionCard(
          width: buttonWidth,
          icon: Icons.camera_alt_rounded,
          label: '\u62cd\u7167',
          color: _accent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            );
          },
        ),
        const SizedBox(width: 32),
        _ActionCard(
          width: buttonWidth,
          icon: Icons.photo_library_rounded,
          label: '\u4ece\u76f8\u518c\u9009\u62e9',
          color: _primaryLight,
          onTap: () => _pickFromGallery(context),
        ),
      ],
    );
  }

  Widget _buildStylePreviews() {
    const styleNames = [
      '\u6cb9\u753b',
      '\u6c34\u5f69',
      '\u7d20\u63cf',
      '\u6f2b\u753b',
      '\u8d5b\u535a\u670b\u514b',
      '\u6ce2\u666e\u827a\u672f',
      '\u65e5\u7cfb',
      '\u590d\u53e4',
      '\u672a\u6765\u79d1\u6280',
      '\u6c11\u56fd\u98ce',
    ];

    final colors = [
      const Color(0xFFE74C3C),
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFF39C12),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFE91E63),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFFFF5722),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 12),
          child: Text(
            '\u98ce\u683c\u9884\u89c8',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            itemCount: styleNames.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _StyleThumbnail(
                name: styleNames[index],
                color: colors[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: widget.color),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleThumbnail extends StatelessWidget {
  final String name;
  final Color color;

  const _StyleThumbnail({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.palette, color: Colors.white54, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Temporary placeholder for StylePickerScreen.
/// Replace this with the actual StylePickerScreen implementation.
class _StylePickerPlaceholder extends StatelessWidget {
  final String imagePath;

  const _StylePickerPlaceholder({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3C72),
      appBar: AppBar(
        title: const Text('\u9009\u62e9\u98ce\u683c'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '\u98ce\u683c\u9009\u62e9\u9875\u9762\uff08\u5f85\u5b9e\u73b0\uff09\n\u56fe\u7247\u8def\u5f84: $imagePath',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
