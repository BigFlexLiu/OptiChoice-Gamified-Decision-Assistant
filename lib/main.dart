import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/views/spinner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SoLoud audio engine
  await SoLoud.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SpinnersNotifier()),
        ChangeNotifierProxyProvider<SpinnersNotifier, SpinnerProvider>(
          create: (context) => SpinnerProvider(),
          update: (context, spinnersNotifier, spinnerProvider) {
            spinnerProvider!.setSpinnersNotifier(spinnersNotifier);
            return spinnerProvider;
          },
        ),
      ],
      child: SpinnerApp(),
    ),
  );
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
      themeMode: ThemeMode.system,
      home: AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  AppInitializerState createState() => AppInitializerState();
}

class AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Initialize SpinnersNotifier
    final spinnersNotifier = Provider.of<SpinnersNotifier>(
      context,
      listen: false,
    );
    await spinnersNotifier.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpinnersNotifier>(
      builder: (context, spinnersNotifier, child) {
        if (!spinnersNotifier.isInitialized) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return SpinnerView();
      },
    );
  }
}
