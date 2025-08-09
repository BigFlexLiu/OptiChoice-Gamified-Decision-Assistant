import 'package:decision_spinner/consts/spinner_template_definitions.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:decision_spinner/widgets/spinner_card.dart';
import 'package:decision_spinner/widgets/dialogs/spinner_conflict_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpinnerTemplatesView extends StatelessWidget {
  const SpinnerTemplatesView({super.key});

  static final _tabs = [
    _TabConfig(
      icon: Icons.home,
      label: 'Home',
      description: 'Daily tasks, chores, and household decisions',
      spinnerTemplates: SpinnerTemplateDefinitions.lifeAndHome,
    ),
    _TabConfig(
      icon: Icons.favorite,
      label: 'Wellness',
      description: 'Wellness, mindfulness, and personal growth',
      spinnerTemplates: SpinnerTemplateDefinitions.healthAndSelfCare,
    ),
    _TabConfig(
      icon: Icons.celebration,
      label: 'Fun',
      description: 'Entertainment, games, and social activities',
      spinnerTemplates: SpinnerTemplateDefinitions.funAndSocial,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Spinner Templates'),
          bottom: TabBar(
            tabs: _tabs
                .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
                .toList(),
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        body: TabBarView(
          children: [
            _SpinnerTemplatesTabView(config: _tabs[0]),
            _SpinnerTemplatesTabView(config: _tabs[1]),
            _SpinnerTemplatesTabView(config: _tabs[2]),
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
    required this.spinnerTemplates,
  });

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

  List<SpinnerModel> get spinnerTemplates => widget.config.spinnerTemplates;

  @override
  void initState() {
    super.initState();
    for (SpinnerModel spinnerModel in spinnerTemplates) {
      _expansionStateByItemId[spinnerModel.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      SpinnerConflictResult? dialogResult;
      String? targetSpinnerId;

      // Check for existing spinner with same content first
      final existingSpinnerWithSameContent = spinnersNotifier
          .findSpinnerWithIdenticalContent(spinner);

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
      } else if (spinnersNotifier.spinnerNameExists(spinner.name)) {
        // Name conflict only
        final existingSpinnerWithSameName = spinnersNotifier.findSpinnerByName(
          spinner.name,
        );
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
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );
      if (dialogResult?.action == SpinnerConflictAction.createNew &&
          dialogResult?.newName != null) {
        spinner.name = dialogResult!.newName!;
        await spinnerProvider.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      } else if (dialogResult?.action == SpinnerConflictAction.cancel) {
        return; // User cancelled
      } else if (targetSpinnerId == null) {
        // No conflicts, save directly
        await spinnerProvider.saveSpinner(spinner);
        targetSpinnerId = spinner.id;
      }

      // Set active spinner - no need for clearCache since notifier handles state updates
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
