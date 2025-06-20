import 'package:decision_spinner/views/premade_spinners_view.dart';
import 'package:decision_spinner/widgets/spinner.dart';
import 'package:flutter/material.dart';
import '../storage/spinner_storage_service.dart';
import '../storage/spinner_model.dart';
import 'spinner_options_view.dart';

class AllSpinnerView extends StatefulWidget {
  const AllSpinnerView({super.key});

  @override
  State<AllSpinnerView> createState() => _AllSpinnerViewState();
}

class _AllSpinnerViewState extends State<AllSpinnerView> {
  Map<String, SpinnerModel> _spinners = {};
  late String _activeSpinnerId;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    // If focus is lost and search field is empty, cancel search
    if (!_searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        _isSearching) {
      _toggleSearch();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final spinners = await SpinnerStorageService.loadAllSpinners();
      final activeSpinnerId = await SpinnerStorageService.getActiveSpinnerId();

      setState(() {
        _spinners = spinners;
        _activeSpinnerId = activeSpinnerId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load spinners');
    }
  }

  Future<void> _createNewSpinner() async {
    String? name;
    bool nameExists = false;

    do {
      name = await _showTextInputDialog(
        'Create New Spinner',
        'Enter spinner name:',
        nameExists ? '' : 'New Spinner',
        errorMessage: nameExists
            ? 'A spinner with this name already exists. Please choose a different name.'
            : null,
      );

      if (name == null || name.isEmpty) {
        return; // User cancelled or entered empty name
      }

      // Check if name already exists
      nameExists = await SpinnerStorageService.spinnerNameExists(name);

      if (!nameExists) {
        // Create default options
        final defaultOptions = [
          SpinnerOption(text: 'Option 1', weight: 1.0),
          SpinnerOption(text: 'Option 2', weight: 1.0),
          SpinnerOption(text: 'Option 3', weight: 1.0),
        ];

        final newSpinner = await SpinnerStorageService.createSpinner(
          name,
          defaultOptions,
        );

        if (newSpinner != null) {
          _loadData();
          _showSnackBar('Spinner "$name" created and set as active');
        } else {
          _showSnackBar('Failed to create spinner. Please try again.');
        }
        return;
      }
    } while (nameExists);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Map<String, SpinnerModel> get _filteredSpinners {
    if (_searchQuery.isEmpty) {
      return _spinners;
    }

    return Map.fromEntries(
      _spinners.entries.where(
        (entry) => entry.value.name.toLowerCase().contains(_searchQuery),
      ),
    );
  }

  Future<void> _deleteSpinner(String id) async {
    final spinner = _spinners[id];
    if (spinner == null) return;

    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Spinner',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${spinner.name}"?',
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
      final success = await SpinnerStorageService.deleteSpinner(id);
      if (success) {
        _loadData();
        _showSnackBar('Spinner "${spinner.name}" deleted');
      } else {
        _showSnackBar('Cannot delete the last spinner');
      }
    }
  }

  Future<void> _duplicateSpinner(String originalId) async {
    final originalSpinner = _spinners[originalId];
    if (originalSpinner == null) return;

    final newName = await _showTextInputDialog(
      'Duplicate Spinner',
      'Enter name for the copy:',
      '${originalSpinner.name} (Copy)',
    );

    if (newName != null && newName.isNotEmpty) {
      final duplicatedSpinner = await SpinnerStorageService.duplicateSpinner(
        originalId,
        newName,
      );

      if (duplicatedSpinner != null) {
        _loadData();
        _showSnackBar('Spinner duplicated as "$newName"');
      } else {
        _showSnackBar('Failed to duplicate. Name might already exist.');
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

  Future<void> _setActiveSpinner(String id) async {
    final success = await SpinnerStorageService.setActiveSpinnerId(id);
    if (success) {
      // Clear cache to force reload
      SpinnerStorageService.clearCache();

      // Update the local state immediately
      setState(() {
        _activeSpinnerId = id;
      });

      final spinnerName = _spinners[id]?.name ?? 'Unknown';
      _showSnackBar('Active spinner set to "$spinnerName"');
    } else {
      _showSnackBar('Failed to set active spinner');
    }
  }

  Future<void> _editSpinner(String id) async {
    final spinner = _spinners[id];
    if (spinner == null) return; // Add null check

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpinnerOptionsView(
          spinner: _spinners[id]!,
          onSpinnerChanged: (updatedSpinner) {
            setState(() {
              _spinners[id] = updatedSpinner;
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

  Future<void> _reorderSpinners(
    int oldIndex,
    int newIndex, [
    Map<String, SpinnerModel>? sourceMap,
  ]) async {
    // If we're in search mode, don't allow reordering
    if (_searchQuery.isNotEmpty) {
      _showSnackBar('Cannot reorder while searching. Clear search first.');
      return;
    }

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final spinnerIds = _spinners.keys.toList();
      final itemId = spinnerIds.removeAt(oldIndex);
      spinnerIds.insert(newIndex, itemId);

      // Rebuild the map with the new order
      final reorderedSpinners = <String, SpinnerModel>{};
      for (final id in spinnerIds) {
        reorderedSpinners[id] = _spinners[id]!;
      }
      _spinners = reorderedSpinners;
    });

    // Save the new order to storage
    await SpinnerStorageService.saveSpinnerOrder(_spinners.keys.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSpinners = _filteredSpinners;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search spinners...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: theme.textTheme.titleLarge,
                onChanged: _onSearchChanged,
              )
            : Text('All Spinners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () async {
              // Navigate to premade spinners and wait for result
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const PremadeSpinnersView(),
                ),
              );

              // If a spinner was successfully added, reload the data
              if (result == true) {
                await _loadData();
                // Get the name of the newly active spinner for the success message
                final activeSpinner = _spinners[_activeSpinnerId];
                if (activeSpinner != null) {
                  _showSnackBar(
                    'Spinner "${activeSpinner.name}" has been added and set as active!',
                  );
                }
              }
            },
            tooltip: 'Premade spinners',
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search spinners',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredSpinners.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.casino_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No spinners match "$_searchQuery"'
                          : 'No spinners found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: Text('Clear search'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSpinners.length,
              onReorder: (oldIndex, newIndex) =>
                  _reorderSpinners(oldIndex, newIndex, filteredSpinners),
              itemBuilder: (context, index) {
                final spinnerId = filteredSpinners.keys.elementAt(index);
                final spinner = filteredSpinners[spinnerId]!;
                final isActive = spinnerId == _activeSpinnerId;

                return SpinnerCard(
                  key: ValueKey(spinnerId), // Explicitly set the key here
                  spinnerId: spinnerId,
                  spinner: spinner,
                  isActive: isActive,
                  canReorder: _searchQuery.isEmpty,
                  subtitle: 'Created ${_formatDate(spinner.createdAt)}',
                  actions: _buildSpinnerActions(spinnerId, isActive, theme),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSpinner,
        tooltip: 'Create New Spinner',
        child: Icon(Icons.add),
      ),
    );
  }

  List<SpinnerCardAction> _buildSpinnerActions(
    String spinnerId,
    bool isActive,
    ThemeData theme,
  ) {
    final actions = <SpinnerCardAction>[];

    if (isActive) {
      actions.addAll([
        SpinnerCardAction(
          icon: Icons.edit,
          label: 'Edit Options',
          onPressed: () => _editSpinner(spinnerId),
          color: theme.colorScheme.primary,
        ),
        SpinnerCardAction(
          icon: Icons.copy,
          label: 'Duplicate',
          onPressed: () => _duplicateSpinner(spinnerId),
          color: theme.colorScheme.tertiary,
        ),
      ]);

      if (_spinners.length > 1) {
        actions.add(
          SpinnerCardAction(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () => _deleteSpinner(spinnerId),
            color: theme.colorScheme.error,
          ),
        );
      }
    } else {
      actions.addAll([
        SpinnerCardAction(
          icon: Icons.star,
          label: 'Set as Active',
          onPressed: () => _setActiveSpinner(spinnerId),
          color: theme.colorScheme.tertiary,
        ),
        SpinnerCardAction(
          icon: Icons.copy,
          label: 'Duplicate',
          onPressed: () => _duplicateSpinner(spinnerId),
          color: theme.colorScheme.tertiary,
        ),
      ]);

      if (_spinners.length > 1) {
        actions.add(
          SpinnerCardAction(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () => _deleteSpinner(spinnerId),
            color: theme.colorScheme.error,
          ),
        );
      }
    }

    return actions;
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
