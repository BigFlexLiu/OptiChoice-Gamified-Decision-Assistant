import 'package:flutter/material.dart';

class EditNameDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;

  const EditNameDialog({
    super.key,
    required this.initialName,
    required this.onNameChanged,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Spinner Name'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: 'Spinner name'),
        autofocus: true,
        maxLength: 50,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onNameChanged(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
