// ignore_for_file: unnecessary_underscores

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/style_data.dart';
import '../models/style_model.dart';
import '../widgets/adaptive_image.dart';

/// Style selection screen optimized for tablet landscape layout.
///
/// Left panel (30%): photo preview with count.
/// Right panel (70%): category tabs + style grid + generate button.
class StylePickerScreen extends StatefulWidget {
  final List<String> imagePaths;

  const StylePickerScreen({super.key, required this.imagePaths});

  @override
  State<StylePickerScreen> createState() => _StylePickerScreenState();
}

class _StylePickerScreenState extends State<StylePickerScreen>
    with SingleTickerProviderStateMixin {
  // -- Constants ----------------------------------------------------------
  static const _bgColor = Color(0xFF0A0E21);
  static const _primaryColor = Color(0xFF1E3C72);
  static const _accentColor = Color(0xFFFF6B6B);
  static const _cardRadius = 16.0;

  // -- State --------------------------------------------------------------
  late final TabController _tabController;
  StyleModel? _selectedStyle;
  String _currentCategory = StyleCategory.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: StyleCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentCategory = StyleCategory.values[_tabController.index];
    });
  }

  List<StyleModel> get _filteredStyles =>
      StyleData.byCategory(_currentCategory);

  // -- Build --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left panel – photo preview
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: _buildLeftPanel(),
                  ),
                  // Divider
                  Container(width: 1, color: Colors.white12),
                  // Right panel – style selection
                  Expanded(child: _buildRightPanel()),
                ],
              ),
            ),
            // Bottom action bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // -- Top bar ------------------------------------------------------------
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            '选择风格',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // -- Left panel ---------------------------------------------------------
  Widget _buildLeftPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main photo preview
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cardRadius),
              child: widget.imagePaths.isNotEmpty
                  ? AdaptiveImage(
                      path: widget.imagePaths.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : _photoPlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          // Photo count
          Text(
            '已选择 ${widget.imagePaths.length} 张照片',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Thumbnails row when multiple photos
          if (widget.imagePaths.length > 1) _buildThumbnailRow(),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: Colors.white10,
      child: const Center(
        child: Icon(Icons.person, size: 64, color: Colors.white24),
      ),
    );
  }

  Widget _buildThumbnailRow() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imagePaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AdaptiveImage(
              path: widget.imagePaths[index],
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  // -- Right panel --------------------------------------------------------
  Widget _buildRightPanel() {
    return Column(
      children: [
        _buildCategoryTabs(),
        Expanded(child: _buildStyleGrid()),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: _accentColor,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        tabAlignment: TabAlignment.start,
        tabs: StyleCategory.values
            .map((c) => Tab(text: c))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildStyleGrid() {
    final styles = _filteredStyles;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        key: ValueKey(_currentCategory),
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemCount: styles.length,
        itemBuilder: (context, index) =>
            _buildStyleCard(styles[index]),
      ),
    );
  }

  // -- Style card ---------------------------------------------------------
  Widget _buildStyleCard(StyleModel style) {
    final isSelected = _selectedStyle?.name == style.name;
    final gradientColors = StyleCategory.gradientColors(style.category);

    // Check people count mismatch for group category
    final bool hasMismatch = style.category == StyleCategory.groupPhoto &&
        widget.imagePaths.length != style.peopleCount;

    return GestureDetector(
      onTap: () => _onStyleTapped(style, hasMismatch),
      child: AnimatedScale(
        scale: isSelected ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: isSelected ? _accentColor : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withValues(alpha: 0.85),
                gradientColors[1].withValues(alpha: 0.65),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Card content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      style.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      style.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildPeopleTag(style.peopleCount),
                  ],
                ),
              ),
              // Selected check
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleTag(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count == 1 ? '单人' : '$count人',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }

  void _onStyleTapped(StyleModel style, bool hasMismatch) {
    if (hasMismatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '该风格需要 ${style.peopleCount} 张照片，'
            '当前已选 ${widget.imagePaths.length} 张',
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _selectedStyle = (_selectedStyle?.name == style.name) ? null : style;
    });
  }

  // -- Bottom bar ---------------------------------------------------------
  Widget _buildBottomBar() {
    final hasSelection = _selectedStyle != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _bgColor,
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          // Selected style label
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: hasSelection
                  ? Text(
                      '已选风格：${_selectedStyle!.name}',
                      key: ValueKey(_selectedStyle!.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const Text(
                      '请选择一个风格',
                      key: ValueKey('empty'),
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
            ),
          ),
          // Generate button
          _buildGenerateButton(hasSelection),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool enabled) {
    return GestureDetector(
      onTap: enabled ? _onGenerate : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [_primaryColor, _accentColor],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '开始生成',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _onGenerate() {
    if (_selectedStyle == null) return;

    // Navigate to ProcessingScreen (to be implemented).
    // For now, push a named route or placeholder.
    Navigator.of(context).pushNamed(
      '/processing',
      arguments: {
        'imagePaths': widget.imagePaths,
        'style': _selectedStyle,
      },
    );
  }
}
