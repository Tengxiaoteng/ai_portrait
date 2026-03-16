import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/adaptive_image.dart';
import 'style_picker_screen.dart';

/// Full-screen camera page optimised for tablet landscape.
/// Provides capture, camera-switch, and gallery-pick actions.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialised = false;
  bool _isCapturing = false;
  String? _errorMessage;

  late final AnimationController _shutterAnimController;
  late final Animation<double> _shutterScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shutterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _shutterScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _shutterAnimController,
        curve: Curves.easeInOut,
      ),
    );
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _shutterAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_currentCameraIndex]);
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = '\u672a\u68c0\u6d4b\u5230\u6444\u50cf\u5934');
        return;
      }
      // Prefer back camera as default.
      _currentCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_currentCameraIndex < 0) _currentCameraIndex = 0;
      await _initCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      setState(() => _errorMessage = '\u6444\u50cf\u5934\u521d\u59cb\u5316\u5931\u8d25: $e');
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    final previousController = _controller;
    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
    } catch (e) {
      setState(() => _errorMessage = '\u6444\u50cf\u5934\u521d\u59cb\u5316\u5931\u8d25: $e');
      return;
    }

    await previousController?.dispose();

    if (!mounted) return;
    setState(() {
      _controller = newController;
      _isInitialised = true;
      _errorMessage = null;
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_currentCameraIndex + 1) % _cameras.length;
    setState(() {
      _currentCameraIndex = nextIndex;
      _isInitialised = false;
    });
    await _initCamera(_cameras[nextIndex]);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    _shutterAnimController.forward().then((_) {
      _shutterAnimController.reverse();
    });

    try {
      final xFile = await _controller!.takePicture();
      if (!mounted) return;
      _navigateToStylePicker(xFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u62cd\u7167\u5931\u8d25: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image != null && mounted) {
      _navigateToStylePicker(image.path);
    }
  }

  void _navigateToStylePicker(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StylePickerScreen(imagePaths: [imagePath]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildTopBar(),
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isInitialised || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
                iconSize: 28,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarButton(
                icon: Icons.cameraswitch_rounded,
                label: '\u5207\u6362',
                onTap: _switchCamera,
              ),
              _buildShutterButton(),
              _ToolbarButton(
                icon: Icons.photo_library_rounded,
                label: '\u76f8\u518c',
                onTap: _pickFromGallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _capturePhoto,
      child: AnimatedBuilder(
        animation: _shutterScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _shutterScale.value,
            child: child,
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isCapturing ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
