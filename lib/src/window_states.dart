import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_states/src/utils/transition_utils.dart';

class TransitionController extends ChangeNotifier {
  int _currentViewIndex = 0;
  bool _isTransitioning = false;
  int _totalViews = 0;

  int get currentViewIndex => _currentViewIndex;
  bool get isTransitioning => _isTransitioning;
  int get totalViews => _totalViews;

  void _setCurrentViewIndex(int index) {
    if (index >= 0 && index < _totalViews) {
      _currentViewIndex = index;
      notifyListeners();
    }
  }

  void _setTotalViews(int count) {
    _totalViews = count;
  }

  void _setTransitioning(bool transitioning) {
    _isTransitioning = transitioning;
    notifyListeners();
  }
}

class TransitionManager extends StatefulWidget {
  final TransitionController controller;
  final List<ViewEntry> views;
  final int initialViewIndex;
  final Widget? loadingWidget;
  final AnimationConfig defaultAnimationConfig;
  final TransitionService? transitionService;

  const TransitionManager({
    super.key,
    required this.controller,
    required this.views,
    this.initialViewIndex = 0,
    this.loadingWidget,
    this.defaultAnimationConfig = AnimationConfig.defaultConfig,
    this.transitionService,
  }) : assert(views.length > 0, 'At least one view is required');

  @override
  State<TransitionManager> createState() => _TransitionManagerState();

  /// Navigate to a specific view by widget type
  static Future<void> navigateTo(
    BuildContext context,
    Widget targetView, {
    AnimationConfig? animationConfig,
  }) async {
    final manager = context.findAncestorStateOfType<_TransitionManagerState>();
    if (manager != null) {
      await manager._transitionToWidget(
        targetView,
        animationConfig: animationConfig,
      );
    }
  }

  /// Navigate to a specific view by index
  static Future<void> navigateToIndex(
    BuildContext context,
    int index, {
    AnimationConfig? animationConfig,
  }) async {
    final manager = context.findAncestorStateOfType<_TransitionManagerState>();
    if (manager != null) {
      await manager._transitionToViewIndex(
        index,
        animationConfig: animationConfig,
      );
    }
  }
}

class TransitionService {
  final bool isDesktop =
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  Future<void> animateWindowTransition({
    required Size fromSize,
    required Size toSize,
    required Offset fromPosition,
    required Offset toPosition,
    required AnimationConfig animConfig,
    required bool isExpanding,
  }) async {
    if (!isDesktop) return;

    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(100, 100));
    await windowManager.setMaximumSize(const Size(10000, 10000));

    for (int i = 1; i <= animConfig.steps; i++) {
      final t = i / animConfig.steps;
      final curvedT = isExpanding ? 1 - pow(1 - t, 3) : pow(t, 2).toDouble();

      final intermediateWidth =
          fromSize.width + (toSize.width - fromSize.width) * curvedT;
      final intermediateHeight =
          fromSize.height + (toSize.height - fromSize.height) * curvedT;
      final intermediateX =
          fromPosition.dx + (toPosition.dx - fromPosition.dx) * curvedT;
      final intermediateY =
          fromPosition.dy + (toPosition.dy - fromPosition.dy) * curvedT;

      await Future.wait([
        windowManager.setSize(
          Size(intermediateWidth, intermediateHeight),
          animate: false,
        ),
        windowManager.setPosition(
          Offset(intermediateX, intermediateY),
          animate: false,
        ),
      ]);

      await Future.delayed(animConfig.stepDuration);
    }
  }

  Future<void> applyWindowConfiguration({
    required Size size,
    required Offset position,
    required bool resizable,
    required bool alwaysOnTop,
    required WindowShadow shadow,
  }) async {
    if (!isDesktop) return;

    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(100, 100));
    await windowManager.setMaximumSize(const Size(10000, 10000));

    await Future.wait([
      windowManager.setSize(size, animate: false),
      windowManager.setPosition(position, animate: false),
    ]);

    // Apply shadow setting (works on macOS and Windows with frameless windows)
    try {
      await windowManager.setHasShadow(shadow.isEnabled);
    } catch (e) {
      debugPrint('Shadow setting not supported on this platform: $e');
    }

    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.setResizable(resizable);

    if (!resizable) {
      await windowManager.setMinimumSize(size);
      await windowManager.setMaximumSize(size);
    }
  }

  Future<Offset?> getCurrentWindowPosition() async {
    if (!isDesktop) return null;

    try {
      final windowInfo = await windowManager.getBounds();
      return Offset(windowInfo.left, windowInfo.top);
    } catch (e) {
      debugPrint('Error getting window position: $e');
      return null;
    }
  }

  Future<Size> getScreenSize() async {
    if (!isDesktop) return Size.zero;

    try {
      final primaryDisplay = await screenRetriever.getPrimaryDisplay();
      return primaryDisplay.size;
    } catch (e) {
      debugPrint('Error getting screen size: $e');
      return const Size(1920, 1080);
    }
  }

  Future<Size> resolveSize(Size configuredSize, Size screenSize) async {
    if (configuredSize.width <= 1.0 || configuredSize.height <= 1.0) {
      return Size(
        configuredSize.width <= 1.0
            ? screenSize.width * configuredSize.width
            : configuredSize.width,
        configuredSize.height <= 1.0
            ? screenSize.height * configuredSize.height
            : configuredSize.height,
      );
    }
    return configuredSize;
  }
}

class _TransitionManagerState extends State<TransitionManager>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  late final AnimationController _transitionController;
  late final Animation<double> _transitionAnimation;
  late final TransitionService _transitionService;
  final List<Size> _resolvedSizes = [];
  final List<Offset> _resolvedPositions = [];
  late Size _screenSize;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return widget.loadingWidget ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentView =
            widget.views[widget.controller.currentViewIndex].view;

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _transitionAnimation,
            builder: (context, _) {
              return ClipRect(
                child: KeyedSubtree(
                  key: ValueKey(widget.controller.currentViewIndex),
                  child: currentView,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _transitionService = widget.transitionService ?? TransitionService();

    widget.controller._setTotalViews(widget.views.length);
    widget.controller._setCurrentViewIndex(widget.initialViewIndex);

    _transitionController = AnimationController(
      duration: widget.defaultAnimationConfig.duration,
      vsync: this,
    );

    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: widget.defaultAnimationConfig.curve,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!_transitionService.isDesktop) {
      setState(() => _initialized = true);
      return;
    }

    try {
      _screenSize = await _transitionService.getScreenSize();

      // Resolve all view configurations
      for (var entry in widget.views) {
        final config = entry.config;
        final resolvedSize = await _transitionService.resolveSize(
          config.size,
          _screenSize,
        );
        final resolvedPosition = config.calculatePosition(
          resolvedSize,
          _screenSize,
        );

        _resolvedSizes.add(resolvedSize);
        _resolvedPositions.add(resolvedPosition);
      }

      // Apply initial window configuration
      final initialConfig = widget.views[widget.initialViewIndex].config;
      await _transitionService.applyWindowConfiguration(
        size: _resolvedSizes[widget.initialViewIndex],
        position: _resolvedPositions[widget.initialViewIndex],
        resizable: initialConfig.resizable,
        alwaysOnTop: initialConfig.alwaysOnTop,
        shadow: initialConfig.shadow,
      );

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing: $e');
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  Future<void> _transitionToViewIndex(
    int targetIndex, {
    AnimationConfig? animationConfig,
  }) async {
    if (widget.controller.isTransitioning ||
        widget.controller.currentViewIndex == targetIndex ||
        !_transitionService.isDesktop ||
        !_initialized ||
        targetIndex < 0 ||
        targetIndex >= widget.views.length) {
      return;
    }

    widget.controller._setTransitioning(true);
    final previousIndex = widget.controller.currentViewIndex;

    final targetConfig = widget.views[targetIndex].config;
    final effectiveAnimConfig =
        animationConfig ??
        targetConfig.animationConfig ??
        widget.defaultAnimationConfig;

    try {
      _transitionController.duration = effectiveAnimConfig.duration;

      final fromSize = _resolvedSizes[previousIndex];
      final toSize = _resolvedSizes[targetIndex];
      // Get the current window position instead of using the pre-calculated position
      final currentPosition = await _transitionService
          .getCurrentWindowPosition();
      final fromPosition = currentPosition ?? _resolvedPositions[previousIndex];
      final toPosition = _resolvedPositions[targetIndex];

      final isExpanding =
          (toSize.width * toSize.height) > (fromSize.width * fromSize.height);

      if (isExpanding) {
        widget.controller._setCurrentViewIndex(targetIndex);
        _transitionController.forward();
      } else {
        _transitionController.reverse();
        await Future.delayed(const Duration(milliseconds: 50));
        widget.controller._setCurrentViewIndex(targetIndex);
      }

      await _transitionService.animateWindowTransition(
        fromSize: fromSize,
        toSize: toSize,
        fromPosition: fromPosition,
        toPosition: toPosition,
        animConfig: effectiveAnimConfig,
        isExpanding: isExpanding,
      );

      await _transitionService.applyWindowConfiguration(
        size: toSize,
        position: toPosition,
        resizable: targetConfig.resizable,
        alwaysOnTop: targetConfig.alwaysOnTop,
        shadow: targetConfig.shadow,
      );
    } catch (e) {
      debugPrint('Error during transition: $e');
    } finally {
      if (mounted) {
        widget.controller._setTransitioning(false);
      }
    }
  }

  Future<void> _transitionToWidget(
    Widget targetWidget, {
    AnimationConfig? animationConfig,
  }) async {
    int? targetIndex;

    // Find the view index by comparing widget runtime type
    for (int i = 0; i < widget.views.length; i++) {
      if (widget.views[i].view.runtimeType == targetWidget.runtimeType) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex == null) {
      debugPrint('Widget not found in registered views');
      return;
    }

    await _transitionToViewIndex(targetIndex, animationConfig: animationConfig);
  }
}
