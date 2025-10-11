import 'dart:io';

import 'package:flutter/material.dart';

typedef CustomPositionCalculator =
    Offset Function(Size windowSize, Size screenSize);

/// Animation configuration for transitions
@immutable
class AnimationConfig {
  static const AnimationConfig defaultConfig = AnimationConfig();
  final Duration duration;
  final Curve curve;
  final int steps;

  final Duration stepDuration;

  const AnimationConfig({
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubicEmphasized,
    this.steps = 25,
    this.stepDuration = const Duration(milliseconds: 16),
  });

  const AnimationConfig.fast({
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.steps = 15,
    this.stepDuration = const Duration(milliseconds: 16),
  });

  const AnimationConfig.slow({
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.steps = 35,
    this.stepDuration = const Duration(milliseconds: 16),
  });
}

/// Custom shadow configuration (for potential future use)
/// Note: window_manager currently only supports enable/disable
/// but this structure allows for future enhancement
@immutable
class CustomShadow extends WindowShadow {
  final Color color;
  final double blurRadius;
  final Offset offset;
  final double spreadRadius;

  const CustomShadow({
    this.color = Colors.black26,
    this.blurRadius = 10.0,
    this.offset = const Offset(0, 4),
    this.spreadRadius = 0,
  });

  @override
  bool get isEnabled => true;

  CustomShadow copyWith({
    Color? color,
    double? blurRadius,
    Offset? offset,
    double? spreadRadius,
  }) {
    return CustomShadow(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      offset: offset ?? this.offset,
      spreadRadius: spreadRadius ?? this.spreadRadius,
    );
  }
}

/// View configurations for each window state
@immutable
class ViewConfig {
  final Size size;
  final WindowPosition position;
  final Offset offset;

  /// Padding creates equal insets from screen edges before positioning
  /// When applied, the window is positioned within the padded area
  final EdgeInsets padding;

  /// Additional margin for fine-tuning (applied after padding)
  /// Unlike padding, margin affects position based on anchor point
  final EdgeInsets margin;

  final CustomPositionCalculator? customPositionCalculator;
  final bool resizable;
  final bool alwaysOnTop;

  /// Window shadow configuration
  final WindowShadow shadow;

  final AnimationConfig? animationConfig;

  const ViewConfig({
    required this.size,
    this.position = WindowPosition.center,
    this.offset = Offset.zero,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.customPositionCalculator,
    this.resizable = false,
    this.alwaysOnTop = false,
    this.shadow = const _DefaultShadow(),
    this.animationConfig,
  });

  /// Calculate position with proper padding/margin handling
  /// Padding creates equal spacing on all sides within the screen bounds
  /// Margin provides additional offset based on position anchor
  Offset calculatePosition(Size windowSize, Size screenSize) {
    Offset basePosition;

    switch (position) {
      case WindowPosition.center:
        // For center, padding reduces the effective screen space equally
        final effectiveScreenSize = Size(
          screenSize.width - padding.horizontal,
          screenSize.height - padding.vertical,
        );
        basePosition = Offset(
          (effectiveScreenSize.width - windowSize.width) / 2 + padding.left,
          (effectiveScreenSize.height - windowSize.height) / 2 + padding.top,
        );
        break;

      case WindowPosition.topLeft:
        // Start from top-left with padding, then apply margin
        basePosition = Offset(
          padding.left + margin.left,
          padding.top + margin.top,
        );
        break;

      case WindowPosition.topRight:
        // Start from top-right with padding, then apply margin
        basePosition = Offset(
          screenSize.width - windowSize.width - padding.right - margin.right,
          padding.top + margin.top,
        );
        break;

      case WindowPosition.bottomLeft:
        // Start from bottom-left with padding, then apply margin
        basePosition = Offset(
          padding.left + margin.left,
          screenSize.height -
              windowSize.height -
              padding.bottom -
              margin.bottom,
        );
        break;

      case WindowPosition.bottomRight:
        // Start from bottom-right with padding, then apply margin
        basePosition = Offset(
          screenSize.width - windowSize.width - padding.right - margin.right,
          screenSize.height -
              windowSize.height -
              padding.bottom -
              margin.bottom,
        );
        break;

      case WindowPosition.centerLeft:
        // Vertically centered, aligned to left edge
        final effectiveScreenHeight = screenSize.height - padding.vertical;
        basePosition = Offset(
          padding.left + margin.left,
          (effectiveScreenHeight - windowSize.height) / 2 + padding.top,
        );
        break;

      case WindowPosition.centerRight:
        // Vertically centered, aligned to right edge
        final effectiveScreenHeight = screenSize.height - padding.vertical;
        basePosition = Offset(
          screenSize.width - windowSize.width - padding.right - margin.right,
          (effectiveScreenHeight - windowSize.height) / 2 + padding.top,
        );
        break;

      case WindowPosition.custom:
        if (customPositionCalculator != null) {
          basePosition = customPositionCalculator!(windowSize, screenSize);
        } else {
          basePosition = Offset.zero;
        }
        break;
    }

    // Apply additional offset
    return basePosition + offset;
  }

  ViewConfig copyWith({
    Size? size,
    WindowPosition? position,
    Offset? offset,
    EdgeInsets? padding,
    EdgeInsets? margin,
    CustomPositionCalculator? customPositionCalculator,
    bool? resizable,
    bool? alwaysOnTop,
    WindowShadow? shadow,
    AnimationConfig? animationConfig,
  }) {
    return ViewConfig(
      size: size ?? this.size,
      position: position ?? this.position,
      offset: offset ?? this.offset,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      customPositionCalculator:
          customPositionCalculator ?? this.customPositionCalculator,
      resizable: resizable ?? this.resizable,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      shadow: shadow ?? this.shadow,
      animationConfig: animationConfig ?? this.animationConfig,
    );
  }
}

/// View entry wrapper to pair widget with configuration
@immutable
class ViewEntry {
  final Widget view;
  final ViewConfig config;

  const ViewEntry({required this.view, required this.config});
}

/// Window position enum for type-safe positioning
enum WindowPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  centerLeft,
  centerRight,
  custom,
}

/// Window shadow configuration
@immutable
sealed class WindowShadow {
  /// No shadow on the window
  static const WindowShadow none = _NoShadow();

  /// Default OS shadow (platform-specific)
  static const WindowShadow platformDefault = _DefaultShadow();

  const WindowShadow();

  /// Get the boolean value for window_manager API
  bool get isEnabled;
}

class _DefaultShadow extends WindowShadow {
  const _DefaultShadow();

  @override
  bool get isEnabled => true;
}

class _NoShadow extends WindowShadow {
  const _NoShadow();

  @override
  bool get isEnabled => false;
}

/// Supported desktop platforms for window management
enum DesktopPlatform {
  windows,
  macos,
  linux;

  /// Check if the current platform matches this enum value
  bool get isCurrent {
    switch (this) {
      case DesktopPlatform.windows:
        return Platform.isWindows;
      case DesktopPlatform.macos:
        return Platform.isMacOS;
      case DesktopPlatform.linux:
        return Platform.isLinux;
    }
  }

  /// Check if any of the given platforms match the current platform
  static bool isAnyOf(List<DesktopPlatform> platforms) {
    return platforms.any((platform) => platform.isCurrent);
  }

  /// Common platform combinations
  static const List<DesktopPlatform> all = [
    DesktopPlatform.windows,
    DesktopPlatform.macos,
    DesktopPlatform.linux,
  ];

  static const List<DesktopPlatform> windowsAndLinux = [
    DesktopPlatform.windows,
    DesktopPlatform.linux,
  ];

  static const List<DesktopPlatform> unixLike = [
    DesktopPlatform.macos,
    DesktopPlatform.linux,
  ];
}
