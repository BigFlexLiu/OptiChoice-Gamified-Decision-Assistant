import 'package:decision_spin/widget/roulette_preview.dart';
import 'package:decision_spin/widget/roulette_wheel.dart';
import 'package:flutter/material.dart';
import '../storage/roulette_storage_service.dart';
import '../storage/roulette_wheel_model.dart';
import '../enums/roulette_paint_mode.dart';
import 'roulette_manager.dart';

class AllRouletteView extends StatefulWidget {
  const AllRouletteView({super.key});

  @override
  State<AllRouletteView> createState() => _AllRouletteViewState();
}

class _AllRouletteViewState extends State<AllRouletteView> {
  Map<String, RouletteWheelModel> _roulettes = {};
  String? _activeRouletteId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final roulettes = await RouletteStorageService.loadAllRoulettes();
      final activeRouletteId =
          await RouletteStorageService.getActiveRouletteId();

      setState(() {
        _roulettes = roulettes;
        _activeRouletteId = activeRouletteId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load roulettes');
    }
  }

  Future<void> _createNewRoulette() async {
    String? name;
    bool nameExists = false;

    do {
      name = await _showTextInputDialog(
        'Create New Roulette',
        'Enter roulette name:',
        nameExists ? '' : 'New Roulette',
        errorMessage: nameExists
            ? 'A roulette with this name already exists. Please choose a different name.'
            : null,
      );

      if (name == null || name.isEmpty) {
        return; // User cancelled or entered empty name
      }

      // Check if name already exists
      nameExists = await RouletteStorageService.rouletteNameExists(name);

      if (!nameExists) {
        // Create default options
        final defaultOptions = [
          RouletteOption(text: 'Option 1', weight: 1.0),
          RouletteOption(text: 'Option 2', weight: 1.0),
          RouletteOption(text: 'Option 3', weight: 1.0),
        ];

        final newRoulette = await RouletteStorageService.createRoulette(
          name,
          defaultOptions,
        );

        if (newRoulette != null) {
          _loadData();
          _showSnackBar('Roulette "$name" created and set as active');
        } else {
          _showSnackBar('Failed to create roulette. Please try again.');
        }
        return;
      }
    } while (nameExists);
  }

  Future<void> _deleteRoulette(String id) async {
    final roulette = _roulettes[id];
    if (roulette == null) return;

    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Roulette',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${roulette.name}"?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await RouletteStorageService.deleteRoulette(id);
      if (success) {
        _loadData();
        _showSnackBar('Roulette "${roulette.name}" deleted');
      } else {
        _showSnackBar('Cannot delete the last roulette');
      }
    }
  }

  Future<void> _duplicateRoulette(String originalId) async {
    final originalRoulette = _roulettes[originalId];
    if (originalRoulette == null) return;

    final newName = await _showTextInputDialog(
      'Duplicate Roulette',
      'Enter name for the copy:',
      '${originalRoulette.name} (Copy)',
    );

    if (newName != null && newName.isNotEmpty) {
      final duplicatedRoulette = await RouletteStorageService.duplicateRoulette(
        originalId,
        newName,
      );

      if (duplicatedRoulette != null) {
        _loadData();
        _showSnackBar('Roulette duplicated as "$newName"');
      } else {
        _showSnackBar('Failed to duplicate. Name might already exist.');
      }
    }
  }

  Future<void> _renameRoulette(String id) async {
    final roulette = _roulettes[id];
    if (roulette == null) return;

    final newName = await _showTextInputDialog(
      'Rename Roulette',
      'Enter new name:',
      roulette.name,
    );

    if (newName != null && newName.isNotEmpty && newName != roulette.name) {
      final success = await RouletteStorageService.renameRoulette(id, newName);

      if (success) {
        _loadData();
        _showSnackBar('Roulette renamed to "$newName"');
      } else {
        _showSnackBar('Failed to rename. Name might already exist.');
      }
    }
  }

  Future<String?> _showTextInputDialog(
    String title,
    String hint,
    String initialValue, {
    String? errorMessage,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final theme = Theme.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: errorMessage != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: errorMessage != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop(text);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _setActiveRoulette(String id) async {
    final success = await RouletteStorageService.setActiveRouletteId(id);
    if (success) {
      _loadData();
      final rouletteName = _roulettes[id]?.name ?? 'Unknown';
      _showSnackBar('Active roulette set to "$rouletteName"');
    }
  }

  Future<void> _editRoulette(String id) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouletteManager(
          rouletteId: id,
          onRouletteChanged: (updatedRoulette) {
            setState(() {
              _roulettes[id] = updatedRoulette;
            });
          },
        ),
      ),
    );

    if (result != null) {
      _loadData(); // Reload to ensure consistency
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          textStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(icon, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reorderRoulettes(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final rouletteIds = _roulettes.keys.toList();
      final itemId = rouletteIds.removeAt(oldIndex);
      rouletteIds.insert(newIndex, itemId);

      // Rebuild the map with the new order
      final reorderedRoulettes = <String, RouletteWheelModel>{};
      for (final id in rouletteIds) {
        reorderedRoulettes[id] = _roulettes[id]!;
      }
      _roulettes = reorderedRoulettes;
    });

    // Save the new order to storage
    await RouletteStorageService.saveRouletteOrder(_roulettes.keys.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('All Roulettes')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _roulettes.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.casino_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No roulettes found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roulettes.length,
              onReorder: _reorderRoulettes,
              itemBuilder: (context, index) {
                final rouletteId = _roulettes.keys.elementAt(index);
                final roulette = _roulettes[rouletteId]!;
                final isActive = rouletteId == _activeRouletteId;

                return Card(
                  key: ValueKey(rouletteId),
                  elevation: isActive ? 8 : 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: isActive
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          )
                        : null,
                    child: ExpansionTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drag_handle,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant,
                            child: Icon(
                              isActive ? Icons.star : Icons.casino,
                              color: isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              roulette.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${roulette.options.length} options',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Created ${_formatDate(roulette.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Roulette Preview - Updated to use RoulettePreview with rouletteId
                              RoulettePreview(
                                options: roulette.options
                                    .map((option) => option.text)
                                    .toList(),
                                size: 196,
                                rouletteId: rouletteId,
                              ),
                              const SizedBox(width: 16),
                              // Action Buttons
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (isActive) ...[
                                      _buildActionButton(
                                        icon: Icons.edit,
                                        label: 'Edit Options',
                                        onPressed: () =>
                                            _editRoulette(rouletteId),
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildActionButton(
                                        icon: Icons.copy,
                                        label: 'Duplicate',
                                        onPressed: () =>
                                            _duplicateRoulette(rouletteId),
                                        color: theme.colorScheme.tertiary,
                                      ),
                                      if (_roulettes.length > 1) ...[
                                        const SizedBox(height: 8),
                                        _buildActionButton(
                                          icon: Icons.delete,
                                          label: 'Delete',
                                          onPressed: () =>
                                              _deleteRoulette(rouletteId),
                                          color: theme.colorScheme.error,
                                        ),
                                      ],
                                    ] else ...[
                                      _buildActionButton(
                                        icon: Icons.star,
                                        label: 'Set as Active',
                                        onPressed: () =>
                                            _setActiveRoulette(rouletteId),
                                        color: theme.colorScheme.tertiary,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildActionButton(
                                        icon: Icons.copy,
                                        label: 'Duplicate',
                                        onPressed: () =>
                                            _duplicateRoulette(rouletteId),
                                        color: theme.colorScheme.tertiary,
                                      ),
                                      if (_roulettes.length > 1) ...[
                                        const SizedBox(height: 8),
                                        _buildActionButton(
                                          icon: Icons.delete,
                                          label: 'Delete',
                                          onPressed: () =>
                                              _deleteRoulette(rouletteId),
                                          color: theme.colorScheme.error,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoulette,
        tooltip: 'Create New Roulette',
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
