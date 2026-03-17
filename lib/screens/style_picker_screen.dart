import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/style_data.dart';
import '../models/style_model.dart';
import '../widgets/adaptive_image.dart';

class StylePickerScreen extends StatefulWidget {
  final List<String> imagePaths;
  const StylePickerScreen({super.key, required this.imagePaths});

  @override
  State<StylePickerScreen> createState() => _StylePickerScreenState();
}

class _StylePickerScreenState extends State<StylePickerScreen>
    with SingleTickerProviderStateMixin {

  static const _bg = Color(0xFFF6F2EE);
  static const _cardBg = Colors.white;
  static const _accent = Color(0xFFD4A056);
  static const _dark = Color(0xFF2D2D2D);
  static const _textSec = Color(0xFF999999);
  static const _border = Color(0xFFE8E3DD);
  static const _maxSel = 10;
  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

  static const _styleColors = <String, List<Color>>{
    '艺术绘画': [Color(0xFFD4A574), Color(0xFFC09060)],
    '动漫卡通': [Color(0xFFCB8EC0), Color(0xFFB876AC)],
    '摄影风格': [Color(0xFF82B5C8), Color(0xFF6E9EAE)],
    '场景主题': [Color(0xFF8DC49A), Color(0xFF78AC84)],
    '多人合照': [Color(0xFFD49A9A), Color(0xFFBE8282)],
  };

  late final TabController _tabCtrl;
  final Set<StyleModel> _selected = {};
  late List<String> _photos; // 可变的照片列表
  String _category = StyleCategory.all;
  bool _isGroupPhoto = false; // 合照模式：一张照片里有多人
  int _groupPeopleCount = 2;  // 合照模式下的人数

  int get _personCount => _isGroupPhoto ? _groupPeopleCount : _photos.length;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.imagePaths);
    _tabCtrl = TabController(length: StyleCategory.values.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _category = StyleCategory.values[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<StyleModel> get _styles => StyleData.byCategory(_category);

  int _selIdx(StyleModel s) {
    final list = _selected.toList();
    for (var i = 0; i < list.length; i++) {
      if (list[i].name == s.name) return i + 1;
    }
    return -1;
  }

  // 添加人物照片
  Future<void> _addPhoto() async {
    if (_photos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多添加 6 个人物'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (kIsWeb) {
      // Web 模拟
      setState(() => _photos.add('mock_person_${_photos.length + 1}.jpg'));
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, maxWidth: 2048, imageQuality: 90);
    if (image != null) {
      setState(() => _photos.add(image.path));
    }
  }

  // 删除人物照片
  void _removePhoto(int index) {
    if (_photos.length <= 1) return; // 至少保留一张
    setState(() {
      _photos.removeAt(index);
      // 清除不匹配人数的已选风格
      _selected.removeWhere((s) => !s.matchesPeople(_photos.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
        child: Column(children: [
          _topBar(),
          Expanded(child: Row(children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.28, child: _leftPanel()),
            Container(width: 1, color: _border),
            Expanded(child: _rightPanel()),
          ])),
          _bottomBar(),
        ]),
      ),
      ),
    );
  }

  // ─── 顶栏 ───
  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(color: _bg, border: Border(bottom: BorderSide(color: _border))),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: _dark),
          ),
        ),
        const SizedBox(width: 16),
        const Text('选择风格', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark, letterSpacing: 2)),
        const Spacer(),
        // 人数指示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people_outline, size: 16, color: _textSec),
            const SizedBox(width: 6),
            Text('$_personCount 人', style: const TextStyle(fontSize: 13, color: _dark, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(width: 12),
        Text('已选 ${_selected.length}/$_maxSel', style: TextStyle(
          fontSize: 13, color: _selected.isNotEmpty ? _accent : _textSec, fontWeight: FontWeight.w600,
        )),
      ]),
    );
  }

  // ─── 左栏：人物照片管理 ───
  Widget _leftPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模式切换
          _modeSwitch(),
          const SizedBox(height: 16),
          // 内容
          Expanded(child: _isGroupPhoto ? _groupPhotoPanel() : _individualPanel()),
        ],
      ),
    );
  }

  Widget _modeSwitch() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Expanded(child: _modeTab('分开拍照', Icons.person_outline, !_isGroupPhoto, () {
          setState(() {
            _isGroupPhoto = false;
            _selected.clear();
          });
        })),
        Expanded(child: _modeTab('合照模式', Icons.groups_outlined, _isGroupPhoto, () {
          setState(() {
            _isGroupPhoto = true;
            _selected.clear();
          });
        })),
      ]),
    );
  }

  Widget _modeTab(String text, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: active ? _accent : _textSec),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(
              fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _dark : _textSec,
            )),
          ],
        ),
      ),
    );
  }

  // ─── 分开拍照模式 ───
  Widget _individualPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('每人拍一张，点 + 添加', style: TextStyle(fontSize: 11, color: _textSec)),
        const SizedBox(height: 12),
        Expanded(child: _photoGrid()),
      ],
    );
  }

  // ─── 合照模式 ───
  Widget _groupPhotoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('一张照片里有多个人', style: TextStyle(fontSize: 11, color: _textSec)),
        const SizedBox(height: 12),
        // 合照预览
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: const Color(0xFFF5F0EB),
              child: _photos.isNotEmpty
                  ? AdaptiveImage(path: _photos.first, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : const Center(child: Icon(Icons.groups, size: 48, color: Color(0xFFCCCCCC))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 人数选择
        const Text('照片里有几个人？', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final count = i + 2; // 2-6人
            final active = _groupPeopleCount == count;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _groupPeopleCount = count;
                  _selected.removeWhere((s) => !s.matchesPeople(count));
                }),
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: active ? _accent : const Color(0xFFF5F0EB),
                    border: Border.all(color: active ? _accent : _border),
                  ),
                  child: Column(children: [
                    Text('$count', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: active ? Colors.white : _dark,
                    )),
                    Text('人', style: TextStyle(
                      fontSize: 10, color: active ? Colors.white70 : _textSec,
                    )),
                  ]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _photoGrid() {
    final total = _photos.length + 1; // +1 是添加按钮
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: total > 7 ? _photos.length : total, // 最多6张+1添加按钮
      itemBuilder: (_, i) {
        if (i < _photos.length) {
          return _personCard(i);
        }
        return _addPhotoBtn();
      },
    );
  }

  Widget _personCard(int index) {
    final label = index < _labels.length ? '人物 ${_labels[index]}' : '人物 ${index + 1}';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        color: const Color(0xFFF5F0EB),
      ),
      child: Stack(children: [
        // 照片
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: AdaptiveImage(path: _photos[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        // 底部标签
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
              color: Colors.white.withOpacity(0.9),
            ),
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _dark,
            )),
          ),
        ),
        // 删除按钮（至少2张才显示）
        if (_photos.length > 1)
          Positioned(
            top: 6, right: 6,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _addPhotoBtn() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
          color: const Color(0xFFFFF9F0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _accent.withOpacity(0.12)),
              child: const Icon(Icons.add_a_photo_outlined, color: _accent, size: 20),
            ),
            const SizedBox(height: 8),
            const Text('添加人物', style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ─── 右栏 ───
  Widget _rightPanel() {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: _accent,
          indicatorWeight: 2.5,
          labelColor: _dark,
          unselectedLabelColor: _textSec,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          tabAlignment: TabAlignment.start,
          dividerColor: _border,
          tabs: StyleCategory.values.map((c) => Tab(text: c)).toList(),
        ),
      ),
      Expanded(child: _grid()),
    ]);
  }

  Widget _grid() {
    final list = _styles;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: GridView.builder(
        key: ValueKey(_category),
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.2,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => _styleCard(list[i]),
      ),
    );
  }

  // ─── 风格卡片 ───
  Widget _styleCard(StyleModel style) {
    final idx = _selIdx(style);
    final isSel = idx > 0;
    final colors = _styleColors[style.category] ?? [const Color(0xFFBBBBBB), const Color(0xFFAAAAAA)];
    final needPeople = style.minPeople;
    final match = style.matchesPeople(_personCount);

    return GestureDetector(
      onTap: () => _tapStyle(style),
      child: AnimatedScale(
        scale: isSel ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _cardBg,
            border: Border.all(
              color: isSel ? _accent : (!match ? const Color(0xFFE0D8D0) : _border),
              width: isSel ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSel ? _accent : Colors.black).withOpacity(isSel ? 0.15 : 0.04),
                blurRadius: isSel ? 12 : 6, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Opacity(
            opacity: match ? 1.0 : 0.45,
            child: Stack(children: [
              // 顶部色条
              Positioned(
                top: 0, left: 0, right: 0, height: 6,
                child: Container(decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  gradient: LinearGradient(colors: colors),
                )),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(style.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(style.description, style: const TextStyle(fontSize: 11, color: _textSec, height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    // 人数标签
                    _peopleTag(style),
                  ],
                ),
              ),
              // 选中序号
              if (isSel)
                Positioned(top: 10, right: 10, child: Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _accent),
                  alignment: Alignment.center,
                  child: Text('$idx', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                )),
              // 人数不匹配提示
              if (!match)
                Positioned(top: 10, right: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFEE8855), borderRadius: BorderRadius.circular(6)),
                  child: Text('需${needPeople}人+', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _peopleTag(StyleModel style) {
    final isGroup = style.isGroupStyle;
    final label = style.minPeople <= 1
        ? '单人'
        : '${style.minPeople}人+';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isGroup ? const Color(0xFFFFF3E6) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(6),
        border: isGroup ? Border.all(color: const Color(0xFFFFD4A8), width: 0.5) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isGroup ? Icons.people_outline : Icons.person_outline, size: 12,
          color: isGroup ? const Color(0xFFCC7733) : _textSec),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          fontSize: 10, color: isGroup ? const Color(0xFFCC7733) : _textSec, fontWeight: FontWeight.w500,
        )),
      ]),
    );
  }

  void _tapStyle(StyleModel style) {
    // 多人风格但人数不够
    if (!style.matchesPeople(_personCount)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('「${style.name}」至少需要 ${style.minPeople} 人，当前有 $_personCount 人'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: '添加人物', onPressed: _addPhoto),
      ));
      return;
    }

    setState(() {
      final existing = _selected.cast<StyleModel?>().firstWhere(
        (s) => s!.name == style.name, orElse: () => null,
      );
      if (existing != null) {
        _selected.remove(existing);
      } else if (_selected.length >= _maxSel) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('最多选择 10 种风格'), behavior: SnackBarBehavior.floating,
        ));
      } else {
        _selected.add(style);
      }
    });
  }

  // ─── 底栏 ───
  Widget _bottomBar() {
    final n = _selected.length;
    final ok = n > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _border))),
      child: Row(children: [
        if (ok) ...[const Icon(Icons.check_circle, color: _accent, size: 18), const SizedBox(width: 8)],
        Text(ok
          ? '已选 $n 种风格 · $_personCount 人${_isGroupPhoto ? "(合照)" : ""}'
          : '请选择风格',
          style: TextStyle(fontSize: 15, color: ok ? _dark : _textSec, fontWeight: FontWeight.w500)),
        const Spacer(),
        GestureDetector(
          onTap: ok ? _gen : null,
          child: AnimatedOpacity(
            opacity: ok ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), color: _dark,
                boxShadow: ok ? [BoxShadow(color: _dark.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('生成 $n 张', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 2)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: _accent, size: 18),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _gen() {
    if (_selected.isEmpty) return;
    Navigator.of(context).pushNamed('/processing', arguments: {
      'imagePaths': _photos,
      'styles': _selected.toList(),
    });
  }
}
