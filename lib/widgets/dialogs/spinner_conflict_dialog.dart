import 'package:flutter/material.dart';
import '../../storage/spinner_model.dart';
import '../../storage/spinner_storage_service.dart';

enum SpinnerConflictAction { useExisting, createNew, cancel }

class SpinnerConflictResult {
  final SpinnerConflictAction action;
  final String? newName;

  SpinnerConflictResult(this.action, [this.newName]);
}

class SpinnerConflictDialog extends StatefulWidget {
  final String proposedName;
  final SpinnerModel? existingSpinnerWithSameName;
  final SpinnerModel? existingSpinnerWithSameContent;

  const SpinnerConflictDialog({
    super.key,
    required this.proposedName,
    this.existingSpinnerWithSameName,
    this.existingSpinnerWithSameContent,
  });

  @override
  State<SpinnerConflictDialog> createState() => _SpinnerConflictDialogState();
}

class _SpinnerConflictDialogState extends State<SpinnerConflictDialog> {
  final _nameController = TextEditingController();
  bool _showNameInput = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.proposedName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNameConflict = widget.existingSpinnerWithSameName != null;
    final hasContentMatch = widget.existingSpinnerWithSameContent != null;

    String title;
    String message;
    String existingName;

    if (hasContentMatch) {
      title = 'Duplicate Found';
      existingName = widget.existingSpinnerWithSameContent!.name;
      message =
          'A spinner with identical slices already exists: "$existingName"';
    } else {
      title = 'Name Exists';
      existingName =
          widget.existingSpinnerWithSameName?.name ?? widget.proposedName;
      message = 'A spinner named "$existingName" already exists.';
    }

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: theme.textTheme.bodyMedium),
          if (_showNameInput) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'New name',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _nameErrorText,
              ),
              autofocus: true,
              onChanged: (value) {
                if (_nameErrorText != null) {
                  setState(() => _nameErrorText = null);
                }
              },
            ),
          ],
        ],
      ),
      actions: _buildActions(context, hasContentMatch, hasNameConflict),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    bool hasContentMatch,
    bool hasNameConflict,
  ) {
    if (_showNameInput) {
      return [
        TextButton(
          onPressed: () => setState(() {
            _showNameInput = false;
            _nameErrorText = null;
            _nameController.text = widget.proposedName;
          }),
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: () async {
            final newName = _nameController.text.trim();
            final navigator = Navigator.of(context);

            // Only validate when saving, not on every keystroke
            if (newName.isEmpty) {
              setState(() => _nameErrorText = 'Name cannot be empty');
              return;
            }

            if (newName == widget.proposedName) {
              setState(
                () => _nameErrorText = 'This is the same name as before',
              );
              return;
            }

            // Check if name exists
            final nameExists = await SpinnerStorageService.spinnerNameExists(
              newName,
            );

            if (!mounted) return;

            if (nameExists) {
              setState(() => _nameErrorText = 'This name is already taken');
              return;
            }

            // Name is valid, proceed with save
            navigator.pop(
              SpinnerConflictResult(SpinnerConflictAction.createNew, newName),
            );
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(SpinnerConflictResult(SpinnerConflictAction.cancel)),
          child: const Text('Cancel'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.of(
          context,
        ).pop(SpinnerConflictResult(SpinnerConflictAction.useExisting)),
        child: const Text('Use Existing'),
      ),
      TextButton(
        onPressed: () => setState(() {
          _showNameInput = true;
          _nameErrorText = null;
        }),
        child: Text(hasContentMatch ? 'Create New' : 'Rename'),
      ),
      TextButton(
        onPressed: () => Navigator.of(
          context,
        ).pop(SpinnerConflictResult(SpinnerConflictAction.cancel)),
        child: const Text('Cancel'),
      ),
    ];
  }
}
