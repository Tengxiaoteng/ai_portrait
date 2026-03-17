import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'style_picker_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  static const _accent = Color(0xFFD4A056);
  static const _dark = Color(0xFF2D2D2D);

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIdx = 0;
  bool _ready = false;
  bool _capturing = false;
  String? _error;
  String? _capturedPath; // 拍完后预览

  late final AnimationController _shutterAnim;
  late final Animation<double> _shutterScale;
  late final AnimationController _flashAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shutterAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _shutterScale = Tween(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _shutterAnim, curve: Curves.easeInOut),
    );
    _flashAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _shutterAnim.dispose();
    _flashAnim.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_cameraIdx]);
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = '未检测到摄像头');
        return;
      }
      // 默认前置（自拍）
      _cameraIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (_cameraIdx < 0) _cameraIdx = 0;
      await _initCamera(_cameras[_cameraIdx]);
    } catch (e) {
      setState(() => _error = '摄像头初始化失败: $e');
    }
  }

  Future<void> _initCamera(CameraDescription cam) async {
    final prev = _controller;
    final ctrl = CameraController(cam, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      await ctrl.initialize();
    } catch (e) {
      setState(() => _error = '摄像头初始化失败: $e');
      return;
    }
    await prev?.dispose();
    if (!mounted) return;
    setState(() { _controller = ctrl; _ready = true; _error = null; });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIdx = (_cameraIdx + 1) % _cameras.length;
    setState(() => _ready = false);
    await _initCamera(_cameras[_cameraIdx]);
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    _shutterAnim.forward().then((_) => _shutterAnim.reverse());
    // 闪白效果
    _flashAnim.forward().then((_) => _flashAnim.reverse());

    try {
      final file = await _controller!.takePicture();
      if (!mounted) return;
      setState(() => _capturedPath = file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _retake() {
    setState(() => _capturedPath = null);
  }

  void _usePhoto() {
    if (_capturedPath == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StylePickerScreen(imagePaths: [_capturedPath!]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 拍照后显示预览确认
    if (_capturedPath != null) {
      return _previewScreen();
    }
    return _cameraViewScreen();
  }

  // ════════════════════════════════════════
  //  相机取景
  // ════════════════════════════════════════
  Widget _cameraViewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        _cameraPreview(),
        // 闪白效果
        AnimatedBuilder(
          animation: _flashAnim,
          builder: (_, __) => Opacity(
            opacity: _flashAnim.value * 0.6,
            child: Container(color: Colors.white),
          ),
        ),
        _topBar(),
        _bottomBar(),
        // 中间人脸引导框
        _faceGuide(),
      ]),
    );
  }

  Widget _cameraPreview() {
    if (_error != null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white54, fontSize: 16), textAlign: TextAlign.center),
        ],
      ));
    }
    if (!_ready || _controller == null) {
      return const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFD4A056)),
          SizedBox(height: 16),
          Text('正在启动相机...', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ));
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _faceGuide() {
    return Center(
      child: IgnorePointer(
        child: Container(
          width: 260,
          height: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(130),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            _circleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
            const Spacer(),
            // 提示文字
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('请将面部对准框内', style: TextStyle(
                    color: Colors.white70, fontSize: 13, letterSpacing: 1,
                  )),
                ),
              ),
            ),
            const Spacer(),
            _circleBtn(Icons.cameraswitch_rounded, _switchCamera),
          ]),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 拍照按钮
              GestureDetector(
                onTap: _capture,
                child: AnimatedBuilder(
                  animation: _shutterScale,
                  builder: (_, child) => Transform.scale(scale: _shutterScale.value, child: child),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 20)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _capturing ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  //  拍照后预览确认
  // ════════════════════════════════════════
  Widget _previewScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EE),
      body: SafeArea(
        child: Column(children: [
          // 顶栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              GestureDetector(
                onTap: _retake,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E3DD)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: _dark),
                ),
              ),
              const SizedBox(width: 16),
              const Text('确认照片', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: _dark, letterSpacing: 2,
              )),
            ]),
          ),
          // 照片预览
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(File(_capturedPath!), fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          // 底部按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            child: Row(children: [
              // 重拍
              Expanded(
                child: GestureDetector(
                  onTap: _retake,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE8E3DD)),
                      color: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: _dark, size: 20),
                        SizedBox(width: 8),
                        Text('重新拍照', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _dark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 使用
              Expanded(
                child: GestureDetector(
                  onTap: _usePhoto,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: _dark,
                      boxShadow: [BoxShadow(color: _dark.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('使用照片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: _accent, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
