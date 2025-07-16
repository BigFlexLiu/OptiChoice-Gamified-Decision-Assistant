import 'package:flutter/material.dart';

class AddOptionDialog extends StatefulWidget {
  final Function(String) onOptionAdded;

  const AddOptionDialog({super.key, required this.onOptionAdded});

  @override
  State<AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<AddOptionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onOptionAdded(_controller.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Option'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Option text',
          hintText: 'Enter new option...',
        ),
        autofocus: true,
        onSubmitted: (_) => _addOption(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addOption, child: Text('Add')),
      ],
    );
  }
}
