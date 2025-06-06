import 'package:decision_spin/views/roulette_options_view.dart';
import 'package:decision_spin/widget/roulette_wheel.dart';
import 'package:flutter/material.dart';

class RouletteView extends StatefulWidget {
  @override
  _RouletteViewState createState() => _RouletteViewState();
}

class _RouletteViewState extends State<RouletteView> {
  List<String> _options = ['Pizza', 'Burger', 'Thai', 'Taco', 'Soup'];
  String _selectedOption = '';
  bool _isSpinning = false;

  void _onSpinComplete(String selectedOption) {
    setState(() {
      _selectedOption = selectedOption;
      _isSpinning = false;
    });
  }

  void _onSpinStart() {
    setState(() {
      _isSpinning = true;
      _selectedOption = '';
    });
  }

  void _navigateToOptionsScreen() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) => RouletteOptionsView(initialOptions: _options),
      ),
    );

    if (result != null) {
      setState(() {
        _options = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            RouletteWheel(
              options: _options,
              isSpinning: _isSpinning,
              onSpinStart: _onSpinStart,
              onSpinComplete: _onSpinComplete,
            ),
            SizedBox(height: 20),
            _buildResultDisplay(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Decision Roulette'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: _navigateToOptionsScreen,
          tooltip: 'Manage Options',
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    if (_selectedOption.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green[300]!, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Winner!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedOption,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
}
