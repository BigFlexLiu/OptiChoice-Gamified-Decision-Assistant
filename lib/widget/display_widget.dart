import 'package:flutter/material.dart';

class WinnerDisplay extends StatelessWidget {
  final String selectedOption;

  const WinnerDisplay({required this.selectedOption, super.key});

  @override
  Widget build(BuildContext context) {
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
            selectedOption,
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
