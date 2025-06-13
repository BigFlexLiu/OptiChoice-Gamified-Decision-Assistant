import 'package:decision_spin/views/all_roulette_view.dart';
import 'package:decision_spin/views/roulette_manager.dart';
import 'package:decision_spin/widget/roulette_wheel.dart';
import 'package:flutter/material.dart';
import '../storage/roulette_storage_service.dart';
import '../storage/roulette_wheel_model.dart';

class RouletteView extends StatefulWidget {
  const RouletteView({super.key});

  @override
  RouletteViewState createState() => RouletteViewState();
}

class RouletteViewState extends State<RouletteView>
    with WidgetsBindingObserver {
  RouletteWheelModel? _activeWheel;
  String _currentPointingOption = '';
  bool _isSpinning = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadActiveWheel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadActiveWheel();
    }
  }

  Future<void> _loadActiveWheel() async {
    setState(() => _isLoading = true);

    try {
      // Load the active wheel from the storage service
      final wheel = await RouletteStorageService.loadActiveRoulette();

      if (wheel != null) {
        setState(() {
          _activeWheel = wheel;
          _currentPointingOption = wheel.options.isNotEmpty
              ? wheel.options[0].text
              : '';
          _isLoading = false;
        });
      } else {
        // This shouldn't happen as RouletteStorageService creates default if none exist
        // But handle it gracefully just in case
        setState(() {
          _activeWheel = null;
          _currentPointingOption = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error by setting loading to false and showing empty state
      setState(() {
        _activeWheel = null;
        _currentPointingOption = '';
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

  void _navigateToWheelsManagement() async {
    // Navigate to RouletteManager and reload active wheel when returning
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => RouletteManager()));

    // Reload active wheel when returning from management screen
    await _loadActiveWheel();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activeWheel == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Decision Roulette'),
          actions: [
            Tooltip(
              message: 'Manage Wheels',
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: _navigateToWheelsManagement,
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No roulette wheel found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Please check your settings or try restarting the app',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loadActiveWheel, child: Text('Retry')),
            ],
          ),
        ),
      );
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
      title: Text(_activeWheel?.name ?? 'Decision Roulette'),
      actions: [
        Tooltip(
          message: 'All Roulettes',
          child: IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AllRouletteView()),
              );
              // Reload active wheel when returning from all roulettes view
              await _loadActiveWheel();
            },
          ),
        ),
        Tooltip(
          message: 'Manage Wheels',
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToWheelsManagement,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPointingOption() {
    final theme = Theme.of(context);

    if (_activeWheel!.options.isEmpty) {
      return Center(
        child: Text(
          'No options available',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: Text(
        _currentPointingOption,
        style: theme.textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRouletteWheelSection() {
    if (_activeWheel!.options.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.casino_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No options to spin',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add some options to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Convert RouletteOption objects to just the text strings for the wheel
    final optionTexts = _activeWheel!.options
        .map((option) => option.text)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: RouletteWheel(
        options: optionTexts,
        isSpinning: _isSpinning,
        onSpinStart: _onSpinStart,
        onSpinComplete: _onSpinComplete,
        onPointingOptionChanged: _onPointingOptionChanged,
        gradientColors: _activeWheel!.gradientColors,
        solidColors: _activeWheel!.solidColors,
        paintMode: _activeWheel!.paintMode,
      ),
    );
  }
}
