import 'package:decision_spinner/consts/storage_constants.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/views/onboarding_view.dart';
import 'package:decision_spinner/views/spinner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
  bool _shouldShowOnboarding = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Check if onboarding should be shown
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool(StorageConstants.onboardingCompletedKey) ?? false;
    final shouldShowOnboarding = !completed;

    // Initialize SpinnersNotifier
    if (!mounted) return;
    final spinnersNotifier = Provider.of<SpinnersNotifier>(
      context,
      listen: false,
    );
    await spinnersNotifier.initialize();

    if (!mounted) return;
    setState(() {
      _shouldShowOnboarding = shouldShowOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpinnersNotifier>(
      builder: (context, spinnersNotifier, child) {
        if (!spinnersNotifier.isInitialized) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Show onboarding if it's the first time
        if (_shouldShowOnboarding) {
          return OnboardingView(
            onComplete: () {
              setState(() {
                _shouldShowOnboarding = false;
              });
            },
          );
        }

        return SpinnerView();
      },
    );
  }
}
