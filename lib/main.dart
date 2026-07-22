import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'ads.dart';
import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  // 광고를 미리 받아둔다. 실패해도 앱은 그대로 돌아가야 한다.
  unawaited(Ads.instance.init());
  runApp(const FocusCatApp());
}

/// 위젯을 탭해서 앱이 열렸으면 곧바로 집중을 시작한다.
///
/// 위젯 안에서는 타이머를 돌릴 수 없다(그릴 뿐 프로세스가 없다).
/// 게다가 이 앱은 앱을 벗어나면 실패로 치므로, 위젯의 역할은
/// "집중 화면까지 한 번에 데려다주는 것"까지다.
void _startFocusFrom(Uri? uri) {
  debugPrint('WIDGET uri=$uri running=${FocusScreen.isRunning}');
  if (uri?.host != 'start') return;
  // 이미 집중 중이면 아무것도 하지 않는다. 위젯 탭으로 앱이 앞으로 나오는
  // 것만으로 충분하고, 새로 띄우면 세션이 둘 겹쳐 돌아간다.
  if (FocusScreen.isRunning) return;
  final navigator = _navigatorKey.currentState;
  if (navigator == null) return;
  navigator.push(
    MaterialPageRoute(
      // 마지막에 고른 시간으로 시작한다. 위젯에는 시간을 고를 자리가 없다.
      builder: (_) => FocusScreen(minutes: appState.lastMinutes),
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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
