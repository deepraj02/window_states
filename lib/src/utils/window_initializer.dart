import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_states/src/utils/transition_utils.dart';

/// Configuration for window initialization
@immutable
class WindowInitializerConfig {
  /// The initial view configuration to use for window setup
  /// If null, uses the first view (index 0) from TransitionManager
  final ViewConfig? initialViewConfig;

  /// Background color for the window
  final Color backgroundColor;

  /// Whether to center the window on startup
  final bool centerOnStartup;

  /// Whether to skip the taskbar
  final bool skipTaskbar;

  /// Title bar style
  final TitleBarStyle titleBarStyle;

  /// Whether to start in fullscreen mode
  final bool fullScreen;

  /// Default window size if no views are configured
  final Size defaultSize;

  final List<DesktopPlatform> enabledPlatforms;

  const WindowInitializerConfig({
    this.initialViewConfig,
    this.backgroundColor = Colors.transparent,
    this.centerOnStartup = false,
    this.skipTaskbar = false,
    this.titleBarStyle = TitleBarStyle.hidden,
    this.fullScreen = false,
    this.defaultSize = const Size(800, 600),
    this.enabledPlatforms = DesktopPlatform.all,
  });
}

class WindowStatesInitializer {
  static bool _isInitialized = false;
  static ViewConfig? _cachedInitialConfig;

  static Future<void> initialize({
    WindowInitializerConfig config = const WindowInitializerConfig(),
  }) async {
    if (_isInitialized) {
      debugPrint('WindowStatesInitializer: Already initialized, skipping...');
      return;
    }

    if (!_isDesktopPlatform()) {
      debugPrint(
        'WindowStatesInitializer: Not a desktop platform, skipping initialization',
      );
      _isInitialized = true;
      return;
    }

    // Check platform filtering
    if (!DesktopPlatform.isAnyOf(config.enabledPlatforms)) {
      debugPrint(
        'WindowStatesInitializer: Current platform not in enabledPlatforms, skipping initialization',
      );
      _isInitialized = true;
      return;
    }
    try {
      await windowManager.ensureInitialized();

      _cachedInitialConfig = config.initialViewConfig;
      final windowSize = config.initialViewConfig?.size ?? config.defaultSize;

      // Only basic WindowOptions - no position or view-specific settings yet
      final windowOptions = WindowOptions(
        size: windowSize,
        center: config.centerOnStartup,
        backgroundColor: config.backgroundColor,
        skipTaskbar: config.skipTaskbar,
        titleBarStyle: config.titleBarStyle,
        fullScreen: config.fullScreen,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      _isInitialized = true;
      debugPrint(
        'WindowStatesInitializer: Initialization complete (basic setup only)',
      );
    } catch (e) {
      debugPrint('WindowStatesInitializer: Error during initialization: $e');
      rethrow;
    }
  }

  static Future<void> initializeWithViews({
    required List<ViewEntry> views,
    int initialViewIndex = 0,
    WindowInitializerConfig config = const WindowInitializerConfig(),
    List<DesktopPlatform> enabledPlatforms = DesktopPlatform.all,
  }) async {
    if (views.isEmpty) {
      throw ArgumentError('At least one view is required');
    }

    if (initialViewIndex < 0 || initialViewIndex >= views.length) {
      throw ArgumentError('initialViewIndex must be within views range');
    }

    final initialViewConfig = views[initialViewIndex].config;

    final configWithView = WindowInitializerConfig(
      initialViewConfig: initialViewConfig,
      backgroundColor: config.backgroundColor,
      centerOnStartup: config.centerOnStartup,
      skipTaskbar: config.skipTaskbar,
      titleBarStyle: config.titleBarStyle,
      fullScreen: config.fullScreen,
      defaultSize: config.defaultSize,
      enabledPlatforms: enabledPlatforms,
    );

    await initialize(config: configWithView);
  }

  static bool get isInitialized => _isInitialized;
  static ViewConfig? get initialConfig => _cachedInitialConfig;

  @visibleForTesting
  static void reset() {
    _isInitialized = false;
    _cachedInitialConfig = null;
  }

  static bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
}
