import 'package:decision_spin/views/premade_roulette_view.dart';
import 'package:decision_spin/widgets/roulette_card.dart';
import 'package:flutter/material.dart';
import '../storage/roulette_storage_service.dart';
import '../storage/roulette_wheel_model.dart';
import 'roulette_options_view.dart';

class AllRouletteView extends StatefulWidget {
  const AllRouletteView({super.key});

  @override
  State<AllRouletteView> createState() => _AllRouletteViewState();
}

class _AllRouletteViewState extends State<AllRouletteView> {
  Map<String, RouletteModel> _roulettes = {};
  late String _activeRouletteId;
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

  Map<String, RouletteModel> get _filteredRoulettes {
    if (_searchQuery.isEmpty) {
      return _roulettes;
    }

    return Map.fromEntries(
      _roulettes.entries.where(
        (entry) => entry.value.name.toLowerCase().contains(_searchQuery),
      ),
    );
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
      // Clear cache to force reload
      RouletteStorageService.clearCache();

      // Update the local state immediately
      setState(() {
        _activeRouletteId = id;
      });

      final rouletteName = _roulettes[id]?.name ?? 'Unknown';
      _showSnackBar('Active roulette set to "$rouletteName"');
    } else {
      _showSnackBar('Failed to set active roulette');
    }
  }

  Future<void> _editRoulette(String id) async {
    final roulette = _roulettes[id];
    if (roulette == null) return; // Add null check

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouletteOptionsView(
          roulette: _roulettes[id]!,
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

  Future<void> _reorderRoulettes(
    int oldIndex,
    int newIndex, [
    Map<String, RouletteModel>? sourceMap,
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

      final rouletteIds = _roulettes.keys.toList();
      final itemId = rouletteIds.removeAt(oldIndex);
      rouletteIds.insert(newIndex, itemId);

      // Rebuild the map with the new order
      final reorderedRoulettes = <String, RouletteModel>{};
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
    final filteredRoulettes = _filteredRoulettes;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search roulettes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: theme.textTheme.titleLarge,
                onChanged: _onSearchChanged,
              )
            : Text('All Roulettes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () async {
              // Navigate to premade roulettes and wait for result
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const PremadeRoulettesView(),
                ),
              );

              // If a roulette was successfully added, reload the data
              if (result == true) {
                await _loadData();
                // Get the name of the newly active roulette for the success message
                final activeRoulette = _roulettes[_activeRouletteId];
                if (activeRoulette != null) {
                  _showSnackBar(
                    'Roulette "${activeRoulette.name}" has been added and set as active!',
                  );
                }
              }
            },
            tooltip: 'Premade roulettes',
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search roulettes',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredRoulettes.isEmpty
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
                          ? 'No roulettes match "$_searchQuery"'
                          : 'No roulettes found',
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
              itemCount: filteredRoulettes.length,
              onReorder: (oldIndex, newIndex) =>
                  _reorderRoulettes(oldIndex, newIndex, filteredRoulettes),
              itemBuilder: (context, index) {
                final rouletteId = filteredRoulettes.keys.elementAt(index);
                final roulette = filteredRoulettes[rouletteId]!;
                final isActive = rouletteId == _activeRouletteId;

                return RouletteCard(
                  key: ValueKey(rouletteId), // Explicitly set the key here
                  rouletteId: rouletteId,
                  roulette: roulette,
                  isActive: isActive,
                  canReorder: _searchQuery.isEmpty,
                  subtitle: 'Created ${_formatDate(roulette.createdAt)}',
                  actions: _buildRouletteActions(rouletteId, isActive, theme),
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

  List<RouletteCardAction> _buildRouletteActions(
    String rouletteId,
    bool isActive,
    ThemeData theme,
  ) {
    final actions = <RouletteCardAction>[];

    if (isActive) {
      actions.addAll([
        RouletteCardAction(
          icon: Icons.edit,
          label: 'Edit Options',
          onPressed: () => _editRoulette(rouletteId),
          color: theme.colorScheme.primary,
        ),
        RouletteCardAction(
          icon: Icons.copy,
          label: 'Duplicate',
          onPressed: () => _duplicateRoulette(rouletteId),
          color: theme.colorScheme.tertiary,
        ),
      ]);

      if (_roulettes.length > 1) {
        actions.add(
          RouletteCardAction(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () => _deleteRoulette(rouletteId),
            color: theme.colorScheme.error,
          ),
        );
      }
    } else {
      actions.addAll([
        RouletteCardAction(
          icon: Icons.star,
          label: 'Set as Active',
          onPressed: () => _setActiveRoulette(rouletteId),
          color: theme.colorScheme.tertiary,
        ),
        RouletteCardAction(
          icon: Icons.copy,
          label: 'Duplicate',
          onPressed: () => _duplicateRoulette(rouletteId),
          color: theme.colorScheme.tertiary,
        ),
      ]);

      if (_roulettes.length > 1) {
        actions.add(
          RouletteCardAction(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () => _deleteRoulette(rouletteId),
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
