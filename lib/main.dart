import 'dart:async';

import 'package:flutter/material.dart';

import 'ads.dart';
import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  // 광고를 미리 받아둔다. 실패해도 앱은 그대로 돌아가야 한다.
  unawaited(Ads.instance.init());
  runApp(const FocusCatApp());
}

class FocusCatApp extends StatelessWidget {
  const FocusCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
