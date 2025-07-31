import 'package:decision_spinner/views/spinner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SoLoud audio engine
  await SoLoud.instance.init();

  runApp(SpinnerApp());
}

class SpinnerApp extends StatelessWidget {
  const SpinnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Spinner',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      themeMode:
          ThemeMode.system, // Automatically switches based on system preference
      home: SpinnerView(),
    );
  }
}
