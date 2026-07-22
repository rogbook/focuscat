import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  runApp(const FocusCatApp());
}

class FocusCatApp extends StatelessWidget {
  const FocusCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
