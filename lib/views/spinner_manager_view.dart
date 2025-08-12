// ignore_for_file: use_build_context_synchronously

import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/utils/onboarding_test_utils.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:decision_spinner/widgets/spinner/spinner_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/spinner_model.dart';
import 'edit_spinner_view.dart';

class SpinnerManagerView extends StatefulWidget {
  const SpinnerManagerView({super.key});

  @override
  State<SpinnerManagerView> createState() => _SpinnerManagerViewState();
}

class _SpinnerManagerViewState extends State<SpinnerManagerView> {
  Map<String, SpinnerModel> _spinners = {};
  late String _activeSpinnerId;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, bool> _expansionStateByItemId = {};

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
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );

      // Ensure the notifier is initialized
      if (!spinnersNotifier.isInitialized) {
        await spinnersNotifier.initialize();
      }

      // Get the data from the notifier
      final spinners = spinnersNotifier.cachedSpinners ?? {};
      final activeSpinnerId = spinnersNotifier.activeSpinnerId ?? '';

      setState(() {
        _spinners = spinners;
        _activeSpinnerId = activeSpinnerId;
        _isLoading = false;
        for (var spinnerId in spinners.keys) {
          if (!_expansionStateByItemId.containsKey(spinnerId)) {
            _expansionStateByItemId[spinnerId] = false;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, 'Failed to load spinners');
    }
  }

  Future<void> _createNewSpinner() async {
    final spinnersNotifier = Provider.of<SpinnersNotifier>(
      context,
      listen: false,
    );
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
      nameExists = spinnersNotifier.spinnerNameExists(name);

      if (!nameExists) {
        // Create default slices
        final defaultSlices = [
          Slice(text: 'Option 1', weight: 1.0),
          Slice(text: 'Option 2', weight: 1.0),
          Slice(text: 'Option 3', weight: 1.0),
        ];

        final spinnerProvider = Provider.of<SpinnerProvider>(
          context,
          listen: false,
        );
        final newSpinner = await spinnerProvider.createSpinner(
          name,
          defaultSlices,
        );

        if (newSpinner != null) {
          // No need to call _loadData() - Consumer will handle the update
          showSnackBar(context, 'Spinner "$name" created and set as active');
        } else {
          showSnackBar(context, 'Failed to create spinner. Please try again.');
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
    Map<String, SpinnerModel> filtered;

    if (_searchQuery.isEmpty) {
      filtered = _spinners;
    } else {
      filtered = Map.fromEntries(
        _spinners.entries.where(
          (entry) => entry.value.name.toLowerCase().contains(_searchQuery),
        ),
      );
    }

    // Sort to put active spinner first
    final sortedEntries = filtered.entries.toList()
      ..sort((a, b) {
        if (a.key == _activeSpinnerId) return -1;
        if (b.key == _activeSpinnerId) return 1;
        return 0;
      });

    return Map.fromEntries(sortedEntries);
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
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );
      final success = await spinnerProvider.deleteSpinner(id);
      if (success) {
        // No need to call _loadData() - Consumer will handle the update
        showSnackBar(context, 'Spinner "${spinner.name}" deleted');
      } else {
        showSnackBar(context, 'Cannot delete the last spinner');
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
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );
      final duplicatedSpinner = await spinnerProvider.duplicateSpinner(
        originalId,
        newName,
      );

      if (duplicatedSpinner != null) {
        // No need to call _loadData() - Consumer will handle the update
        showSnackBar(context, 'Spinner duplicated as "$newName"');
      } else {
        showSnackBar(context, 'Failed to duplicate. Name might already exist.');
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
    final spinnersNotifier = Provider.of<SpinnersNotifier>(
      context,
      listen: false,
    );
    final success = await spinnersNotifier.setActiveSpinnerId(id);
    if (success) {
      // Update the local state immediately
      setState(() {
        _activeSpinnerId = id;
      });

      final spinnerName = _spinners[id]?.name ?? 'Unknown';
      showSnackBar(context, 'Active spinner set to "$spinnerName"');

      // Navigate back to the previous screen
      Navigator.of(context).pop();
    } else {
      showSnackBar(context, 'Failed to set active spinner');
    }
  }

  Future<void> _editSpinner(String id) async {
    final spinner = _spinners[id];
    if (spinner == null) return; // Add null check

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSpinnerView(
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
      // No need to call _loadData() - Consumer will handle the update
      // The EditSpinnerView already updates through SpinnersNotifier
    }
  }

  Future<void> _reorderSpinners(
    int oldIndex,
    int newIndex, [
    Map<String, SpinnerModel>? sourceMap,
  ]) async {
    if (_searchQuery.isNotEmpty) {
      showSnackBar(
        context,
        'Cannot reorder while searching. Clear search first.',
      );
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

    // Save the new order to storage via SpinnersNotifier
    final spinnerProvider = Provider.of<SpinnerProvider>(
      context,
      listen: false,
    );
    await spinnerProvider.saveSpinnerOrder(_spinners.keys.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SpinnersNotifier>(
      builder: (context, spinnersNotifier, child) {
        // Update local state from notifier if initialized
        if (spinnersNotifier.isInitialized && !_isLoading) {
          final spinners = spinnersNotifier.cachedSpinners ?? {};
          final activeSpinnerId = spinnersNotifier.activeSpinnerId ?? '';

          // Update local state if different
          if (_spinners != spinners || _activeSpinnerId != activeSpinnerId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _spinners = spinners;
                  _activeSpinnerId = activeSpinnerId;

                  // Initialize expansion states for new spinners
                  for (var spinnerId in spinners.keys) {
                    if (!_expansionStateByItemId.containsKey(spinnerId)) {
                      _expansionStateByItemId[spinnerId] = false;
                    }
                  }
                });
              }
            });
          }
        }

        Map<String, SpinnerModel> filteredSpinners = _filteredSpinners;

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
                : Text('Manage Spinners'),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
                tooltip: _isSearching ? 'Close search' : 'Search spinners',
              ),
            ],
          ),
          body: _isLoading || !spinnersNotifier.isInitialized
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
                        const SizedBox(height: 24),
                        DebugOnboardingWidget(),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: filteredSpinners.length,
                  onReorder: (oldIndex, newIndex) =>
                      _reorderSpinners(oldIndex, newIndex, filteredSpinners),
                  itemBuilder: (context, index) {
                    // Show active spinner first if exists
                    final spinnerId = filteredSpinners.keys.elementAt(index);
                    final spinner = filteredSpinners[spinnerId]!;
                    final isActive = spinnerId == _activeSpinnerId;
                    final isExpanded = _expansionStateByItemId[spinnerId]!;

                    return SpinnerCard(
                      key: ValueKey(spinnerId),
                      spinner: spinner,
                      isActive: isActive,
                      isExpanded: isExpanded,
                      onExpansionChanged: (bool value) => setState(() {
                        _expansionStateByItemId[spinnerId] = value;
                      }),
                      canReorder: _searchQuery.isEmpty,
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
      },
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
          label: 'Edit Slices',
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
          label: 'Set Active',
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
}
