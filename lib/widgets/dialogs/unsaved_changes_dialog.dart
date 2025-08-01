import 'package:flutter/material.dart';

class UnsavedChangesDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final String? saveButtonText;
  final String? discardButtonText;

  const UnsavedChangesDialog({
    super.key,
    this.title,
    this.content,
    this.saveButtonText,
    this.discardButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Unsaved Changes'),
      content: Text(content ?? 'Do you want to save them?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('discard'),
          child: Text(discardButtonText ?? 'Discard'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop('save'),
          child: Text(saveButtonText ?? 'Save'),
        ),
      ],
    );
  }
}
