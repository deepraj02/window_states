
## [0.1.2](https://github.com/yourusername/window_states/releases/tag/v0.1.2) - 2025-10-11
This release introduces automatic window initialization capabilities, platform-specific window management, and eliminates the need for manual `**windowManager**` boilerplate code and introduces optional parameter `enabledPlatform` on `**TransitionManager**` to have better control for building platform specific behaviour.

### Changes
- `**WindowInitializerConfig**`, `**WindowStatesInitializer**` - Configuration class for window initialization.
- Added: `**DesktopPlatform**` enum
    - `**Values**`: windows, macos, linux
    - `**isCurrent**` getter
    - `**isAnyOf()**`() static method
    - `**Predefined**` combinations: `all`, `windowsAndLinux`, `unixLike`

**Before**
```dart
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(300, 120),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      fullScreen: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
```

**Now (0.1.2)**

```dart
return TransitionManager(
      controller: _dimensionController,
      initialViewIndex: 0,
      views: [
        ViewEntry(
          view: _collapsedView,
          config: const ViewConfig(
            size: Size(300, 120),
            position: WindowPosition.topLeft,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 20),
            alwaysOnTop: true,
            shadow: WindowShadow.none,
            animationConfig: AnimationConfig.fast(),
          ),
        ),
        ViewEntry(
          view: _expandedView,
          config: const ViewConfig(
            size: Size(450, 700),
            position: WindowPosition.centerLeft,
            padding: EdgeInsets.all(30),
            alwaysOnTop: false,
            shadow: WindowShadow.none,
            animationConfig: AnimationConfig.fast(),
          ),
        ),
      ],
      defaultAnimationConfig: const AnimationConfig(),
      windowInitializerConfig: WindowInitializerConfig(),
      enabledPlatforms: DesktopPlatform.unixLike,
    );
```
**Auto applies the config for defined platform**


## [0.1.1](https://github.com/yourusername/window_states/releases/tag/v0.1.1) - 2025-10-08

### Fixes
- **Window Transitions**: Fixed animations to start from the window's actual current position rather than its configured position. This creates smoother transitions when the window has been manually moved before switching states.



## [0.1.0](https://github.com/yourusername/window_states/releases/tag/v0.1.0) - 2025-10-08

### 🎉 Initial Release
Window States brings declarative, animated window state management to Flutter desktop applications. Transform your desktop app with smooth window transitions between different layouts, sizes, and positions.
### ✨ Added
#### Core Features

- **Declarative Window State Management** - Define window configurations as navigable states using `ViewConfig` and `ViewEntry`
- **Smooth Animated Transitions** - Built-in animations for window resizing and repositioning with customizable curves and durations
- **Type-Safe Navigation System** - Navigate between window states using widget references or indices
- **Positioning and Alignment System** - Provides API's to fine-tune the positioning and alignment your app window with respect to screen boundaries.