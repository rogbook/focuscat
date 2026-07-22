import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'app_state.dart';
import 'screens.dart';

/// 위젯 탭으로 시작할 때 쓰는 집중 시간(분).
const kWidgetStartMinutes = 25;

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  runApp(const FocusCatApp());
}

/// 위젯을 탭해서 앱이 열렸으면 곧바로 집중을 시작한다.
///
/// 위젯 안에서는 타이머를 돌릴 수 없다(그릴 뿐 프로세스가 없다).
/// 게다가 이 앱은 앱을 벗어나면 실패로 치므로, 위젯의 역할은
/// "집중 화면까지 한 번에 데려다주는 것"까지다.
void _startFocusFrom(Uri? uri) {
  if (uri?.host != 'start') return;
  final navigator = _navigatorKey.currentState;
  if (navigator == null) return;
  navigator.push(
    MaterialPageRoute(
      builder: (_) => const FocusScreen(minutes: kWidgetStartMinutes),
    ),
  );
}

class FocusCatApp extends StatefulWidget {
  const FocusCatApp({super.key});

  @override
  State<FocusCatApp> createState() => _FocusCatAppState();
}

class _FocusCatAppState extends State<FocusCatApp> {
  StreamSubscription<Uri?>? _widgetTaps;

  @override
  void initState() {
    super.initState();
    // 앱이 떠 있는 동안의 탭.
    _widgetTaps = HomeWidget.widgetClicked.listen(_startFocusFrom);
    // 앱이 꺼져 있다가 위젯 탭으로 켜진 경우 — 첫 프레임 뒤라야 navigator가 있다.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _startFocusFrom(await HomeWidget.initiallyLaunchedFromHomeWidget());
    });
  }

  @override
  void dispose() {
    _widgetTaps?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '집중냥이',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kTeal,
          brightness: Brightness.light,
          primary: kTeal,
        ),
        scaffoldBackgroundColor: kBg,
        useMaterial3: true,
        chipTheme: ChipThemeData(
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: kTeal,
          side: const BorderSide(color: Color(0x1F000000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kTeal,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
