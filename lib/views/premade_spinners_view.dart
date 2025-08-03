import 'package:decision_spinner/consts/premade_spinner_definitions.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:decision_spinner/widgets/spinner_card.dart';
import 'package:decision_spinner/widgets/dialogs/spinner_conflict_dialog.dart';
import 'package:flutter/material.dart';

class PremadeSpinnersView extends StatelessWidget {
  const PremadeSpinnersView({super.key});

  static const _tabs = [
    _TabConfig(
      icon: Icons.person,
      label: 'Solo',
      description: 'Premade spinners for everyday decisions',
    ),
    _TabConfig(
      icon: Icons.people,
      label: 'Pair',
      description: 'Fun spinners for parties and groups',
    ),
    _TabConfig(
      icon: Icons.groups,
      label: 'Group',
      description: 'Fun spinners for parties and groups',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Premade Spinners'),
          bottom: TabBar(
            tabs: _tabs
                .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
                .toList(),
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        body: TabBarView(
          children: [
            _PremadeSpinnerTabView(
              config: _tabs[0],
              spinnerModels: PremadeSpinnerDefinitions.soloDecisions,
            ),
            _PremadeSpinnerTabView(
              config: _tabs[1],
              spinnerModels: PremadeSpinnerDefinitions.pairDecisions,
            ),
            _PremadeSpinnerTabView(
              config: _tabs[2],
              spinnerModels: PremadeSpinnerDefinitions.groupDecisions,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;
}

class _PremadeSpinnerTabView extends StatefulWidget {
  const _PremadeSpinnerTabView({
    required this.config,
    required this.spinnerModels,
  });

  final _TabConfig config;
  final List<SpinnerModel> spinnerModels;

  @override
  State<_PremadeSpinnerTabView> createState() => _PremadeSpinnerTabViewState();
}

class _PremadeSpinnerTabViewState extends State<_PremadeSpinnerTabView> {
  final Map<String, bool> _expansionStateByItemId = {};

  @override
  void initState() {
    super.initState();
    for (SpinnerModel spinnerModel in widget.spinnerModels) {
      _expansionStateByItemId[spinnerModel.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spinnerModels.isEmpty) {
      return _EmptyStateWidget(config: widget.config);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.spinnerModels.length,
      itemBuilder: (context, index) {
        final spinner = widget.spinnerModels[index];
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
      SpinnerConflictResult? dialogResult;
      String? targetSpinnerId;

      // Check for existing spinner with same content first
      final existingSpinnerWithSameContent =
          await SpinnerStorageService.findSpinnerWithIdenticalContent(spinner);

      if (existingSpinnerWithSameContent != null) {
        // Found identical content
        if (!context.mounted) return;
        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: spinner.name,
            existingSpinnerWithSameContent: existingSpinnerWithSameContent,
          ),
        );
        if (dialogResult?.action == SpinnerConflictAction.useExisting) {
          targetSpinnerId = existingSpinnerWithSameContent.id;
        }
      } else if (await SpinnerStorageService.spinnerNameExists(spinner.name)) {
        // Name conflict only
        final existingSpinnerWithSameName =
            await SpinnerStorageService.findSpinnerByName(spinner.name);
        if (!context.mounted) return;

        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: spinner.name,
            existingSpinnerWithSameName: existingSpinnerWithSameName,
          ),
        );
        if (dialogResult?.action == SpinnerConflictAction.useExisting &&
            existingSpinnerWithSameName != null) {
          targetSpinnerId = existingSpinnerWithSameName.id;
        }
      }

      // Handle dialog result and determine target spinner
      if (dialogResult?.action == SpinnerConflictAction.createNew &&
          dialogResult?.newName != null) {
        spinner.name = dialogResult!.newName!;
        await SpinnerStorageService.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      } else if (dialogResult?.action == SpinnerConflictAction.cancel) {
        return; // User cancelled
      } else if (targetSpinnerId == null) {
        // No conflicts, save directly
        await SpinnerStorageService.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      }

      // Set active spinner and cleanup
      await SpinnerStorageService.setActiveSpinnerId(targetSpinnerId);
      SpinnerStorageService.clearCache();
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
          itemCount: spinner.options.length,
          itemBuilder: (context, index) {
            final option = spinner.options[index];
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
