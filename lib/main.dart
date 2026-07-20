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
          seedColor: const Color(0xFFF5D5B8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
