import 'package:decision_spin/storage/color_storage_service.dart';
import 'package:decision_spin/views/all_roulette_view.dart';
import 'package:decision_spin/widget/roulette_wheel.dart';
import 'package:decision_spin/views/roulette_options_view.dart';
import 'package:decision_spin/storage/options_storage_service.dart';
import 'package:flutter/material.dart';

class RouletteView extends StatefulWidget {
  @override
  _RouletteViewState createState() => _RouletteViewState();
}

class _RouletteViewState extends State<RouletteView>
    with WidgetsBindingObserver {
  List<String> _options = [];
  List<List<Color>> _gradientColors = [];
  String _activeRouletteName = '';
  String _currentPointingOption = '';
  bool _isSpinning = false;
  bool _isLoading = true;
  List<Color> _solidColors = [];
  bool _colorsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOptions();
    _loadColors();
  }

  Future<void> _loadColors() async {
    try {
      final gradientColors = await ColorStorageService.gradientColors;
      final solidColors = await ColorStorageService.solidColors;

      setState(() {
        _gradientColors = gradientColors;
        _solidColors = solidColors;
        _colorsLoaded = true;
      });
    } catch (e) {
      // Handle error - use default colors if loading fails
      setState(() {
        _gradientColors = [
          [Colors.red, Colors.pink],
          [Colors.blue, Colors.cyan],
          [Colors.green, Colors.lightGreen],
          [Colors.orange, Colors.yellow],
          [Colors.purple, Colors.purpleAccent],
        ];
        _solidColors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ];
        _colorsLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    try {
      final options = await OptionsStorageService.loadOptions();
      final activeRoulette = await OptionsStorageService.getActiveRoulette();

      setState(() {
        _options = options;
        _activeRouletteName = activeRoulette;
        _currentPointingOption = options.isNotEmpty ? options[0] : '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _options = ['Pizza', 'Burger', 'Thai', 'Taco', 'Soup'];
        _activeRouletteName = 'Food Options';
        _currentPointingOption = 'Pizza';
        _isLoading = false;
      });
    }
  }

  void _onSpinComplete(String selectedOption) {
    setState(() {
      _currentPointingOption = selectedOption;
      _isSpinning = false;
    });
  }

  void _onSpinStart() {
    setState(() {
      _isSpinning = true;
    });
  }

  void _onPointingOptionChanged(String option) {
    if (_isSpinning) {
      setState(() {
        _currentPointingOption = option;
      });
    }
  }

  void _navigateToOptionsScreen() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) => RouletteOptionsView(
          initialOptions: _options,
          onOptionsChanged: (newOptions) {
            setState(() {
              _options = newOptions;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _options = result;
      });
    }

    _loadOptions();
  }

  void _navigateToAllRouletteScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AllRouletteView()));

    _loadOptions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCurrentPointingOption(),
            const SizedBox(height: 16),
            _buildRouletteWheelSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Decision Roulette'),
      actions: [
        Tooltip(
          message: 'All Roulettes',
          child: IconButton(
            icon: Icon(Icons.view_list),
            onPressed: _navigateToAllRouletteScreen,
          ),
        ),
        Tooltip(
          message: 'Manage Options',
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToOptionsScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPointingOption() {
    final theme = Theme.of(context);

    if (_options.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Text(
        _currentPointingOption,
        style: theme.textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRouletteWheelSection() {
    if (!_colorsLoaded) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading roulette...'),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RouletteWheel(
        options: _options,
        isSpinning: _isSpinning,
        onSpinStart: _onSpinStart,
        onSpinComplete: _onSpinComplete,
        onPointingOptionChanged: _onPointingOptionChanged,
        gradientColors: _gradientColors,
        solidColors: _solidColors,
      ),
    );
  }
}
