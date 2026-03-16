// ignore_for_file: unnecessary_underscores

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
  static const _bgColor = Color(0xFF0D0D0D);
  static const _cardColor = Color(0xFF1A1A1A);
  static const _accentColor = Color(0xFFF5A623);
  static const _accentEndColor = Color(0xFFFF8C42);
  static const _cardRadius = 16.0;
  static const _maxSelections = 10;
  static const _textSecondary = Color(0xFF888888);
  static const _borderColor = Color(0xFF333333);

  // -- State --------------------------------------------------------------
  late final TabController _tabController;
  final Set<StyleModel> _selectedStyles = {};
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

  /// Returns the 1-based selection order index for the given style,
  /// or -1 if not selected.
  int _selectionIndex(StyleModel style) {
    final list = _selectedStyles.toList();
    for (var i = 0; i < list.length; i++) {
      if (list[i].name == style.name) return i + 1;
    }
    return -1;
  }

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
                  // Left panel -- photo preview
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: _buildLeftPanel(),
                  ),
                  // Divider
                  Container(width: 1, color: Colors.white12),
                  // Right panel -- style selection
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
        itemBuilder: (context, index) => _buildStyleCard(styles[index]),
      ),
    );
  }

  // -- Style card ---------------------------------------------------------
  Widget _buildStyleCard(StyleModel style) {
    final selIndex = _selectionIndex(style);
    final isSelected = selIndex > 0;
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
              color: isSelected ? _accentColor : _borderColor,
              width: isSelected ? 2.5 : 1.0,
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
                gradientColors[0],
                gradientColors[1],
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
                      style: const TextStyle(
                        color: _textSecondary,
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
              // Selected order badge
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_accentColor, _accentEndColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$selIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPeopleTag(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
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
      // Check if already selected (by name equality)
      final existing = _selectedStyles
          .cast<StyleModel?>()
          .firstWhere((s) => s!.name == style.name, orElse: () => null);

      if (existing != null) {
        // Deselect
        _selectedStyles.remove(existing);
      } else if (_selectedStyles.length >= _maxSelections) {
        // Show limit snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('最多选择10种风格'),
            backgroundColor: _accentColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Select
        _selectedStyles.add(style);
      }
    });
  }

  // -- Bottom bar ---------------------------------------------------------
  Widget _buildBottomBar() {
    final count = _selectedStyles.length;
    final hasSelection = count > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          // Selected styles count
          Expanded(
            child: Text(
              '已选 $count/$_maxSelections 种风格',
              style: TextStyle(
                color: hasSelection ? Colors.white : _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
    final count = _selectedStyles.length;

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
              colors: [_accentColor, _accentEndColor],
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '生成 $count 张照片 \u2192',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGenerate() {
    if (_selectedStyles.isEmpty) return;

    // Navigate to ProcessingScreen.
    Navigator.of(context).pushNamed(
      '/processing',
      arguments: {
        'imagePaths': widget.imagePaths,
        'styles': _selectedStyles.toList(),
      },
    );
  }
}
