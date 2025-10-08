#  Effortless Window State Transitions for Flutter Desktop

A declarative Flutter package that brings **smooth, animated window transitions** to desktop applications. Transform your desktop app with animated window resizing and repositioning - perfect for mini players, sidebars, focus modes, and adaptive layouts.


## 🎯 The Problem

Building desktop apps with multiple window layouts is **surprisingly painful**:

```dart
// ❌ The old way - Manual window management
await windowManager.setSize(Size(400, 600));
await windowManager.setPosition(Offset(100, 100));
await windowManager.setResizable(false);
// Now manually animate...
// Now switch your UI...
// Now keep everything in sync...
// 😫 100+ lines of boilerplate per transition
```

**Common Pain Points:**

- 🔧 **Complex Coordination** - Manually sync window size, position, and UI changes
- 🎬 **Animation Hell** - Writing custom animations for every window transition
- 🐛 **State Management Chaos** - Tracking which view is active and preventing race conditions
- 📱 **Positioning Nightmares** - Calculating pixel-perfect positions for every screen size
- 🔄 **Boilerplate Explosion** - Hundreds of lines for simple multi-layout apps
- ⚠️ **Error-Prone** - One wrong calculation and your window is off-screen


## ✨ The Solution

Treat window configurations as **navigable states** with built-in animations:

```dart
// ✅ The new way - Declarative & animated
TransitionManager(
  controller: controller,
  views: [
    ViewEntry(
      view: CompactView(),
      config: ViewConfig(
        size: Size(400, 100),
        position: WindowPosition.bottomRight,
        padding: EdgeInsets.all(20),
        shadow: WindowShadow.platformDefault,
        animationConfig: AnimationConfig.fast(),
      ),
    ),
    ViewEntry(
      view: ExpandedView(),
      config: ViewConfig(
        size: Size(0.8, 0.9), // 80% width, 90% height
        position: WindowPosition.center,
        shadow: WindowShadow.none,
      ),
    ),
  ],
);

// Navigate with one line
TransitionManager.navigateToIndex(context, 1);
// 🎉 Automatic smooth animation, window resizing, and UI transition!
```


## 🚀 Key Features

- **Declarative Window Configurations**
    Define all your window states upfront - no imperative spaghetti code.
- **Smooth Built-in Animations**
    Professionally choreographed transitions between any window size/position.
- **Type-Safe Positioning System**
    - `WindowPosition.center` - Perfect centering
    - `WindowPosition.topLeft`, `topRight`, `bottomLeft`, `bottomRight`  Corner positioning
    - `WindowPosition.centerLeft`, `centerRight` - Edge-centered (perfect for sidebars)
    - `WindowPosition.custom` - Full control with custom calculators


- **Smart Sizing**
    Support for both absolute and relative sizes:

    ```dart
    size: Size(400, 300),        // Absolute pixels
    size: Size(0.5, 0.8),        // 50% width, 80% height
    ```


- **Shadow Control**
    Fine-grained window shadow management:

    ```dart
    shadow: WindowShadow.none,              // No shadow
    shadow: WindowShadow.platformDefault,   // OS default shadow
    shadow: CustomShadow(                   // Custom configuration
    color: Colors.black26,
    blurRadius: 15.0,
    offset: Offset(0, 8),
    )
    ```


- **Flexible Animations**

    Choose from presets or customize:

    ```dart
    AnimationConfig.fast()      // 250ms, snappy
    AnimationConfig.defaultConfig  // 400ms, balanced
    AnimationConfig.slow()      // 600ms, elegant
    AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
    steps: 20,
    )
    ```


- **Multiple Navigation Methods**

    ```dart
    // By index
    TransitionManager.navigateToIndex(context, 2);

    // By widget type (type-safe!)
    TransitionManager.navigateTo(context, DetailView());
    ```


## 📚 API Reference

### TransitionManager

The main widget that manages window transitions.

```dart
TransitionManager({
  required TransitionController controller,
  required List<ViewEntry> views,
  int initialViewIndex = 0,
  Widget? loadingWidget,
  AnimationConfig defaultAnimationConfig = AnimationConfig.defaultConfig,
  WindowTransitionService? transitionService,
})
```

**Properties:**

- `controller` - Controls the active view and transition state
- `views` - List of view configurations and their associated widgets
- `initialViewIndex` - Which view to show on startup (default: 0)
- `loadingWidget` - Custom widget shown during initialization
- `defaultAnimationConfig` - Default animation if not specified per-view

**Static Methods:**

```dart
// Navigate by index
static Future<void> navigateToIndex(
  BuildContext context,
  int index, {
  AnimationConfig? animationConfig,
})

// Navigate by widget type
static Future<void> navigateTo(
  BuildContext context,
  Widget targetView, {
  AnimationConfig? animationConfig,
})
```


### ViewConfig

Configuration for a single window state.

```dart
ViewConfig({
  required Size size,
  WindowPosition position = WindowPosition.center,
  Offset offset = Offset.zero,
  EdgeInsets padding = EdgeInsets.zero,
  EdgeInsets margin = EdgeInsets.zero,
  CustomPositionCalculator? customPositionCalculator,
  bool resizable = false,
  bool alwaysOnTop = false,
  WindowShadow shadow = WindowShadow.platformDefault,
  AnimationConfig? animationConfig,
})
```

**Properties:**

- `size` - Window size (absolute pixels or relative 0.0-1.0)
- `position` - Where to position the window (enum)
- `offset` - Additional pixel offset after positioning
- `padding` - Equal spacing from all screen edges
- `margin` - Fine-tuning offset based on anchor point
- `customPositionCalculator` - Custom positioning logic
- `resizable` - Whether user can resize the window
- `alwaysOnTop` - Keep window above other apps
- `shadow` - Window shadow configuration
- `animationConfig` - Override default animation for this view


### WindowPosition

```dart
enum WindowPosition {
  center,        // Centered on screen
  topLeft,       // Top-left corner
  topRight,      // Top-right corner
  bottomLeft,    // Bottom-left corner
  bottomRight,   // Bottom-right corner
  centerLeft,    // Vertically centered, left edge
  centerRight,   // Vertically centered, right edge
  custom,        // Use customPositionCalculator
}
```


### WindowShadow

```dart
// No shadow
WindowShadow.none

// Platform default shadow
WindowShadow.platformDefault

// Custom shadow (for future enhancements)
CustomShadow(
  color: Colors.black26,
  blurRadius: 15.0,
  offset: Offset(0, 8),
  spreadRadius: 2.0,
)
```


### AnimationConfig

```dart
// Presets
AnimationConfig.fast()      // 250ms
AnimationConfig.defaultConfig  // 400ms
AnimationConfig.slow()      // 600ms

// Custom
AnimationConfig({
  Duration duration = Duration(milliseconds: 400),
  Curve curve = Curves.easeInOutCubicEmphasized,
  int steps = 25,
  Duration stepDuration = Duration(milliseconds: 16),
})
```


### TransitionController

```dart
class TransitionController extends ChangeNotifier {
  int get currentViewIndex;        // Active view index
  bool get isTransitioning;        // Is animation in progress?
  int get totalViews;              // Total number of views
}
```

**Usage with State Management:**

```dart
// Listen to transitions
controller.addListener(() {
  print('Current view: ${controller.currentViewIndex}');
  print('Transitioning: ${controller.isTransitioning}');
});

// Disable buttons during transition
ElevatedButton(
  onPressed: controller.isTransitioning ? null : () {
    // Navigate...
  },
  child: Text('Switch View'),
)
```


## 🎨 Positioning System Explained

### Padding vs Margin

**Padding** creates equal spacing from screen edges before positioning:

```dart
ViewConfig(
  position: WindowPosition.topLeft,
  padding: EdgeInsets.all(20), // 20px from all edges
  // Window starts at (20, 20)
)
```

**Margin** provides additional fine-tuning based on anchor point:

```dart
ViewConfig(
  position: WindowPosition.topLeft,
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.only(left: 10, top: 5),
  // Window at (20 + 10, 20 + 5) = (30, 25)
)
```


### Position Behavior

```dart
// Center - Equal padding on all sides
WindowPosition.center + padding: EdgeInsets.all(50)
// → Window centered in area 50px smaller on all sides

// TopLeft - Padding + margin from top-left
WindowPosition.topLeft + padding.left/top + margin.left/top

// BottomRight - Padding + margin from bottom-right
WindowPosition.bottomRight + padding.right/bottom + margin.right/bottom

// CenterLeft - Vertically centered, horizontally left
WindowPosition.centerLeft + padding.left + margin.left
// → Vertical centering respects padding.top/bottom

// CenterRight - Vertically centered, horizontally right
WindowPosition.centerRight + padding.right + margin.right
// → Vertical centering respects padding.top/bottom
```


## 🔍 Advanced Usage

### Conditional Navigation

```dart
void _handleNavigation() {
  if (controller.isTransitioning) {
    return; // Ignore if already transitioning
  }
  
  final nextIndex = (controller.currentViewIndex + 1) % controller.totalViews;
  TransitionManager.navigateToIndex(context, nextIndex);
}
```


### Animation Override

```dart
// Override animation for specific transition
TransitionManager.navigateToIndex(
  context,
  2,
  animationConfig: AnimationConfig(
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOut,
  ),
);
```


## 📋 Platform Support

| Platform | Supported | Notes                               |
| :------- | :-------- | :---------------------------------- |
| macOS    | ✅         | Full support with native animations |
| Windows  | ⏳         | Soon (work in progress)             |
| Linux    | ⏳         | Soon (work in progress)             |
| Web      | ❌         | Not applicable (browser windows)    |
| Mobile   | ❌         | Not applicable (fullscreen apps)    |

## ⚠️ Known Limitations
- **Single Monitor Only** - Currently positions windows on the primary display
- **No State Persistence** - Window configurations aren't saved between sessions (coming in v2.0)
- **Shadow Limitations** - Custom shadow parameters stored but not yet applied (waiting for window_manager API support)
- **No Mid-Transition Cancellation** - Transitions must complete before starting another

## Examples:
### [Pomodoro Timer](/example/lib/main.dart) - A simple Pomodoro Timer with Multiple Window Dimensions with a way to navigate in between them.

Uses:

- [window_manager](https://pub.dev/packages/window_manager) for window control
- [screen_retriever](https://pub.dev/packages/screen_retriever) for screen information


