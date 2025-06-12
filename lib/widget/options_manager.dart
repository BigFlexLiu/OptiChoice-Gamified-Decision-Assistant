import 'package:flutter/material.dart';

class OptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;

  const OptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
  }) : super(key: key);

  @override
  _OptionsManagerState createState() => _OptionsManagerState();
}

class _OptionsManagerState extends State<OptionsManager> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_textController.text.trim().isNotEmpty) {
      final updatedOptions = [...widget.options, _textController.text.trim()];
      widget.onOptionsChanged(updatedOptions);
      _textController.clear();
    }
  }

  void _removeOption(int index) {
    if (widget.options.length > 2) {
      final updatedOptions = [...widget.options];
      updatedOptions.removeAt(index);
      widget.onOptionsChanged(updatedOptions);
    }
  }

  List<Color> _getGradientColorsForIndex(int index) {
    final gradients = [
      [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFf5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
      [Color(0xFFfa709a), Color(0xFFfee140)],
      [Color(0xFF30cfd0), Color(0xFF91a7ff)],
      [Color(0xFFa8edea), Color(0xFFfed6e3)],
      [Color(0xFFffecd2), Color(0xFFfcb69f)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddOptionSection(),
        SizedBox(height: 20),
        _buildOptionsListSection(),
      ],
    );
  }

  Widget _buildAddOptionSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Option',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter new option...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _addOption(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addOption,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsListSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Options (${widget.options.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...widget.options.asMap().entries.map((entry) {
              return _buildOptionListItem(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionListItem(int index, String option) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColorsForIndex(index),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(option, style: TextStyle(fontSize: 16))),
          if (widget.options.length > 2)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeOption(index),
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}
