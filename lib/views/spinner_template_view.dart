import 'package:decision_spinner/consts/spinner_template_definitions.dart';
import 'package:decision_spinner/consts/storage_constants.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/storage/base_storage_service.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:decision_spinner/widgets/spinner_card.dart';
import 'package:decision_spinner/widgets/dialogs/spinner_conflict_dialog.dart';
import 'package:decision_spinner/widgets/dialogs/category_reorder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpinnerTemplatesView extends StatefulWidget {
  const SpinnerTemplatesView({super.key});

  @override
  State<SpinnerTemplatesView> createState() => _SpinnerTemplatesViewState();
}

class _SpinnerTemplatesViewState extends State<SpinnerTemplatesView>
    with SingleTickerProviderStateMixin {
  List<_TabConfig> _tabs = [];
  bool _isLoading = true;
  TabController? _tabController;
  int _tabOrderVersion = 0;

  // Cache for quick lookups
  static final Map<String, _TabConfig> _categoryMap = {
    for (var cat in _allCategories) cat.id: cat,
  };

  // All available categories
  static final _allCategories = [
    _TabConfig(
      id: 'lifeAndHome',
      icon: Icons.home,
      label: 'Life & Home',
      description: 'Daily tasks, chores, and household decisions',
      spinnerTemplates: SpinnerTemplateDefinitions.lifeAndHome,
    ),
    _TabConfig(
      id: 'healthAndSelfCare',
      icon: Icons.favorite,
      label: 'Health & Self-Care',
      description: 'Wellness, mindfulness, and personal growth',
      spinnerTemplates: SpinnerTemplateDefinitions.healthAndSelfCare,
    ),
    _TabConfig(
      id: 'funAndSocial',
      icon: Icons.celebration,
      label: 'Fun & Social',
      description: 'Entertainment, games, and social activities',
      spinnerTemplates: SpinnerTemplateDefinitions.funAndSocial,
    ),
    _TabConfig(
      id: 'productivityAndWork',
      icon: Icons.work,
      label: 'Productivity',
      description: 'Focus, learning, and skill-building',
      spinnerTemplates: SpinnerTemplateDefinitions.productivityAndWork,
    ),
    _TabConfig(
      id: 'teachingAndClassroom',
      icon: Icons.school,
      label: 'Teaching',
      description: 'Educational tools and activities',
      spinnerTemplates: SpinnerTemplateDefinitions.teachingAndClassroom,
    ),
    _TabConfig(
      id: 'gamesAndChallenges',
      icon: Icons.games,
      label: 'Games',
      description: 'Gamification and light competition',
      spinnerTemplates: SpinnerTemplateDefinitions.gamesAndChallenges,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSelectedTabs();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserSelectedTabs() async {
    try {
      final categoriesJson = await BaseStorageService.getJson(
        StorageConstants.selectedCategoriesKey,
      );
      final selectedIds =
          (categoriesJson as List?)?.cast<String>() ?? <String>[];
      _updateTabs(_buildTabsFromIds(selectedIds));
    } catch (e) {
      _updateTabs(_allCategories);
    }
  }

  void _updateTabs(List<_TabConfig> newTabs) {
    _tabController?.dispose();
    setState(() {
      _tabs = newTabs;
      _tabController = TabController(
        length: newTabs.length,
        vsync: this,
        initialIndex: 0,
      );
      _isLoading = false;
      _tabOrderVersion++;
    });
  }

  List<_TabConfig> _buildTabsFromIds(List<String> selectedIds) {
    if (selectedIds.isEmpty) return _allCategories;

    final selectedTabs = selectedIds
        .where(_categoryMap.containsKey)
        .map((id) => _categoryMap[id]!)
        .toList();

    final selectedSet = selectedIds.toSet();
    final remainingTabs = _allCategories
        .where((cat) => !selectedSet.contains(cat.id))
        .toList();

    return [...selectedTabs, ...remainingTabs];
  }

  void _showReorderDialog() {
    final categories = _tabs
        .map(
          (tab) => CategoryInfo(
            id: tab.id,
            icon: tab.icon,
            label: tab.label,
            description: tab.description,
          ),
        )
        .toList();

    showDialog<void>(
      context: context,
      builder: (context) => CategoryReorderDialog(
        categories: categories,
        onReorder: _saveReorderedCategories,
      ),
    );
  }

  Future<void> _saveReorderedCategories(List<String> reorderedIds) async {
    try {
      await BaseStorageService.saveJson(
        StorageConstants.selectedCategoriesKey,
        reorderedIds,
      );
      _reorderTabsOnly(reorderedIds);
      if (mounted) {
        showSnackBar(context, 'Category order updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Failed to update category order: ${e.toString()}',
        );
      }
    }
  }

  void _reorderTabsOnly(List<String> reorderedIds) {
    final newTabs = _buildTabsFromIds(reorderedIds);
    if (_tabsAreEqual(_tabs, newTabs)) return;

    final currentTabId =
        _tabController?.index != null && _tabController!.index < _tabs.length
        ? _tabs[_tabController!.index].id
        : null;

    final newIndex = currentTabId != null
        ? newTabs
              .indexWhere((tab) => tab.id == currentTabId)
              .clamp(0, newTabs.length - 1)
        : 0;

    setState(() {
      _tabs = newTabs;
      _tabOrderVersion++;
      if (_tabController!.length != newTabs.length) {
        _tabController?.dispose();
        _tabController = TabController(
          length: newTabs.length,
          vsync: this,
          initialIndex: newIndex,
        );
      } else {
        _tabController!.animateTo(newIndex);
      }
    });
  }

  bool _tabsAreEqual(List<_TabConfig> tabs1, List<_TabConfig> tabs2) {
    if (tabs1.length != tabs2.length) return false;
    for (int i = 0; i < tabs1.length; i++) {
      if (tabs1[i].id != tabs2[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabController == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Spinner Templates'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Spinner Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.reorder),
            tooltip: 'Reorder Categories',
            onPressed: _showReorderDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          tabs: _tabs
              .map(
                (tab) => SizedBox(
                  width: MediaQuery.of(context).size.width / 3.5 - 16,
                  child: Tab(icon: Icon(tab.icon), text: tab.label),
                ),
              )
              .toList(),
          indicatorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body: TabBarView(
        key: ValueKey(_tabOrderVersion),
        controller: _tabController,
        children: _tabs
            .map((tab) => _SpinnerTemplatesTabView(config: tab))
            .toList(),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.spinnerTemplates,
  });

  final String id;
  final IconData icon;
  final String label;
  final String description;
  final List<SpinnerModel> spinnerTemplates;
}

class _SpinnerTemplatesTabView extends StatefulWidget {
  const _SpinnerTemplatesTabView({required this.config});

  final _TabConfig config;

  @override
  State<_SpinnerTemplatesTabView> createState() =>
      _SpinnerTemplatesTabViewState();
}

class _SpinnerTemplatesTabViewState extends State<_SpinnerTemplatesTabView> {
  final Map<String, bool> _expansionStateByItemId = {};

  @override
  void initState() {
    super.initState();
    _expansionStateByItemId.addAll({
      for (var spinner in widget.config.spinnerTemplates) spinner.id: false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final spinnerTemplates = widget.config.spinnerTemplates;

    if (spinnerTemplates.isEmpty) {
      return _EmptyStateWidget(config: widget.config);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spinnerTemplates.length,
      itemBuilder: (context, index) {
        final spinner = spinnerTemplates[index];
        final isExpanded = _expansionStateByItemId[spinner.id]!;

        return SpinnerCard(
          spinner: spinner,
          isExpanded: isExpanded,
          onExpansionChanged: (bool value) => setState(() {
            _expansionStateByItemId[spinner.id] = value;
          }),
          isActive: false,
          canReorder: false,
          actions: _buildActions(context, spinner),
          isFromSpinnerTemplates: true,
        );
      },
    );
  }

  List<SpinnerCardAction> _buildActions(
    BuildContext context,
    SpinnerModel spinner,
  ) {
    final theme = Theme.of(context);
    return [
      SpinnerCardAction(
        icon: Icons.add_circle,
        label: 'Add',
        onPressed: () => _addSpinner(context, spinner),
        color: theme.colorScheme.primary,
      ),
      SpinnerCardAction(
        icon: Icons.preview,
        label: 'Preview',
        onPressed: () => _showPreview(context, spinner),
        color: theme.colorScheme.secondary,
      ),
    ];
  }

  Future<void> _addSpinner(BuildContext context, SpinnerModel spinner) async {
    try {
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );

      String? targetSpinnerId;
      SpinnerConflictResult? dialogResult;

      // Check for existing spinner with same content
      final existingWithSameContent = spinnersNotifier
          .findSpinnerWithIdenticalContent(spinner);
      if (existingWithSameContent != null) {
        if (!context.mounted) return;
        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: spinner.name,
            existingSpinnerWithSameContent: existingWithSameContent,
          ),
        );
        if (dialogResult?.action == SpinnerConflictAction.useExisting) {
          targetSpinnerId = existingWithSameContent.id;
        }
      } else if (spinnersNotifier.spinnerNameExists(spinner.name)) {
        // Name conflict only
        final existingWithSameName = spinnersNotifier.findSpinnerByName(
          spinner.name,
        );
        if (!context.mounted) return;

        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: spinner.name,
            existingSpinnerWithSameName: existingWithSameName,
          ),
        );
        if (dialogResult?.action == SpinnerConflictAction.useExisting &&
            existingWithSameName != null) {
          targetSpinnerId = existingWithSameName.id;
        }
      }

      // Handle dialog result
      if (dialogResult?.action == SpinnerConflictAction.createNew &&
          dialogResult?.newName != null) {
        spinner.name = dialogResult!.newName!;
        await spinnerProvider.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      } else if (dialogResult?.action == SpinnerConflictAction.cancel) {
        return;
      } else if (targetSpinnerId == null) {
        await spinnerProvider.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      }

      await spinnersNotifier.setActiveSpinnerId(targetSpinnerId);
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  void _showPreview(BuildContext context, SpinnerModel spinner) {
    showDialog(
      context: context,
      builder: (context) => _PreviewDialog(spinner: spinner),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({required this.config});

  final _TabConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            config.icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${config.label} Available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for more options!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.spinner});

  final SpinnerModel spinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('${spinner.name} - Options'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: spinner.slices.length,
          itemBuilder: (context, index) {
            final option = spinner.slices[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              title: Text(option.text),
              // subtitle: Text('Weight: ${option.weight}'),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
