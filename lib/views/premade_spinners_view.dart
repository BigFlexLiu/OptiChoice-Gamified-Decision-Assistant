import 'package:decision_spinner/consts/premade_spinner_definitions.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';
import 'package:decision_spinner/widgets/spinner.dart';
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
              spinnerWheels: PremadeSpinnerDefinitions.soloDecisions,
            ),
            _PremadeSpinnerTabView(
              config: _tabs[1],
              spinnerWheels: PremadeSpinnerDefinitions.pairDecisions,
            ),
            _PremadeSpinnerTabView(
              config: _tabs[2],
              spinnerWheels: PremadeSpinnerDefinitions.groupDecisions,
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

class _PremadeSpinnerTabView extends StatelessWidget {
  const _PremadeSpinnerTabView({
    required this.config,
    required this.spinnerWheels,
  });

  final _TabConfig config;
  final List<SpinnerModel> spinnerWheels;

  @override
  Widget build(BuildContext context) {
    if (spinnerWheels.isEmpty) {
      return _EmptyStateWidget(config: config);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spinnerWheels.length,
      itemBuilder: (context, index) {
        final spinner = spinnerWheels[index];

        return SpinnerCard(
          spinnerId: 'premade_${index}_${spinner.name}',
          spinner: spinner,
          isActive: false,
          canReorder: false,
          subtitle: '${spinner.options.length} options • Premade',
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
        label: 'Add to My Spinners',
        onPressed: () => _addSpinner(context, spinner),
        color: theme.colorScheme.primary,
      ),
      SpinnerCardAction(
        icon: Icons.preview,
        label: 'Preview Options',
        onPressed: () => _showPreview(context, spinner),
        color: theme.colorScheme.secondary,
      ),
    ];
  }

  Future<void> _addSpinner(BuildContext context, SpinnerModel spinner) async {
    try {
      final finalName = await _generateUniqueName(spinner.name);
      spinner.name = finalName;

      final createdSpinner = await SpinnerStorageService.saveSpinner(spinner);

      if (createdSpinner && context.mounted) {
        SpinnerStorageService.clearCache();
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Failed to create spinner. Please try again.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<String> _generateUniqueName(String baseName) async {
    if (!await SpinnerStorageService.spinnerNameExists(baseName)) {
      return baseName;
    }

    int counter = 1;
    String candidateName;
    do {
      candidateName = '$baseName ($counter)';
      counter++;
    } while (await SpinnerStorageService.spinnerNameExists(candidateName));

    return candidateName;
  }

  void _showPreview(BuildContext context, SpinnerModel spinner) {
    showDialog(
      context: context,
      builder: (context) => _PreviewDialog(spinner: spinner),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
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
