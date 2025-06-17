import 'package:decision_spin/consts/premade_roulette_definitions.dart';
import 'package:decision_spin/storage/roulette_wheel_model.dart';
import 'package:decision_spin/storage/roulette_storage_service.dart';
import 'package:decision_spin/widgets/roulette_card.dart';
import 'package:flutter/material.dart';

class PremadeRoulettesView extends StatelessWidget {
  const PremadeRoulettesView({super.key});

  static const _tabs = [
    _TabConfig(
      icon: Icons.quiz,
      label: 'Common Decisions',
      title: 'Common Decisions',
      description: 'Premade roulettes for everyday decisions',
    ),
    _TabConfig(
      icon: Icons.party_mode,
      label: 'Party Games',
      title: 'Party Games',
      description: 'Fun roulettes for parties and groups',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Premade Roulettes'),
          bottom: TabBar(
            tabs: _tabs
                .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: [
            _PremadeRouletteTabView(
              config: _tabs[0],
              rouletteWheels: [PremadeRouletteDefinitions.yesNoRoulette],
            ),
            _PremadeRouletteTabView(config: _tabs[1], rouletteWheels: const []),
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
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String title;
  final String description;
}

class _PremadeRouletteTabView extends StatelessWidget {
  const _PremadeRouletteTabView({
    required this.config,
    required this.rouletteWheels,
  });

  final _TabConfig config;
  final List<RouletteModel> rouletteWheels;

  @override
  Widget build(BuildContext context) {
    if (rouletteWheels.isEmpty) {
      return _EmptyStateWidget(config: config);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rouletteWheels.length,
      itemBuilder: (context, index) {
        final roulette = rouletteWheels[index];

        return RouletteCard(
          rouletteId: 'premade_${index}_${roulette.name}',
          roulette: roulette,
          isActive: false,
          canReorder: false,
          subtitle: '${roulette.options.length} options • Premade',
          actions: _buildActions(context, roulette),
        );
      },
    );
  }

  List<RouletteCardAction> _buildActions(
    BuildContext context,
    RouletteModel roulette,
  ) {
    final theme = Theme.of(context);

    return [
      RouletteCardAction(
        icon: Icons.add_circle,
        label: 'Add to My Roulettes',
        onPressed: () => _addRoulette(context, roulette),
        color: theme.colorScheme.primary,
      ),
      RouletteCardAction(
        icon: Icons.preview,
        label: 'Preview Options',
        onPressed: () => _showPreview(context, roulette),
        color: theme.colorScheme.secondary,
      ),
    ];
  }

  Future<void> _addRoulette(
    BuildContext context,
    RouletteModel roulette,
  ) async {
    try {
      final finalName = await _generateUniqueName(roulette.name);

      final createdRoulette = await RouletteStorageService.createRoulette(
        finalName,
        roulette.options,
        colorThemeIndex: roulette.colorThemeIndex,
      );

      if (createdRoulette != null && context.mounted) {
        RouletteStorageService.clearCache();
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Failed to create roulette. Please try again.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<String> _generateUniqueName(String baseName) async {
    if (!await RouletteStorageService.rouletteNameExists(baseName)) {
      return baseName;
    }

    int counter = 1;
    String candidateName;
    do {
      candidateName = '$baseName ($counter)';
      counter++;
    } while (await RouletteStorageService.rouletteNameExists(candidateName));

    return candidateName;
  }

  void _showPreview(BuildContext context, RouletteModel roulette) {
    showDialog(
      context: context,
      builder: (context) => _PreviewDialog(roulette: roulette),
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
            'No ${config.title} Available',
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
  const _PreviewDialog({required this.roulette});

  final RouletteModel roulette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('${roulette.name} - Options'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: roulette.options.length,
          itemBuilder: (context, index) {
            final option = roulette.options[index];
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
              subtitle: Text('Weight: ${option.weight}'),
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
