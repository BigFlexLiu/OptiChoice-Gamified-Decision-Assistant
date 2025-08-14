import 'package:flutter/material.dart';
import '../../storage/spinner_model.dart';
import '../../consts/storage_constants.dart';

class EditOptionDialog extends StatefulWidget {
  final Slice option;
  final bool canDelete;
  final Function(String, double) onOptionChanged;
  final VoidCallback onDeleteRequested;

  const EditOptionDialog({
    super.key,
    required this.option,
    required this.canDelete,
    required this.onOptionChanged,
    required this.onDeleteRequested,
  });

  @override
  State<EditOptionDialog> createState() => _EditOptionDialogState();
}

class _EditOptionDialogState extends State<EditOptionDialog> {
  late final TextEditingController _nameController;
  late double _tempWeight;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.option.text);
    _tempWeight = widget.option.weight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Edit Option'),
          const Spacer(),
          if (widget.canDelete)
            IconButton(
              tooltip: 'Delete option',
              icon: Icon(Icons.delete_outline),
              onPressed: widget.onDeleteRequested,
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Option text',
                hintText: 'Enter option text...',
                prefixIcon: const Icon(Icons.lightbulb_outline),
              ),
              maxLength: StorageConstants.optionMaxLength,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onOptionChanged(_nameController.text, _tempWeight);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
