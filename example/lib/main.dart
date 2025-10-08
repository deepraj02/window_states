import 'dart:io' show Platform;

import 'package:example/pages/collapsed_screen.dart';
import 'package:example/pages/extended_screen.dart';
import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_states/window_states.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const TimerHomePage(),
    );
  }
}

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  late final TransitionController _dimensionController;
  late final TimerController _timerController;

  late final Widget _collapsedView;
  late final Widget _expandedView;

  @override
  Widget build(BuildContext context) {
    return TransitionManager(
      controller: _dimensionController,
      initialViewIndex: 1,
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
            shadow: WindowShadow.platformDefault,
            animationConfig: AnimationConfig.fast(),
          ),
        ),
      ],
      defaultAnimationConfig: const AnimationConfig(),
    );
  }

  @override
  void dispose() {
    _dimensionController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dimensionController = TransitionController();
    _timerController = TimerController();

    _collapsedView = CollapsedTimerView(
      timerController: _timerController,
      dimensionController: _dimensionController,
    );

    _expandedView = ExpandedTimerView(
      timerController: _timerController,
      dimensionController: _dimensionController,
    );
  }
}
