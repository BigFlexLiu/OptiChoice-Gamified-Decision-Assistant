import 'package:flutter/material.dart';
import '../storage/roulette_wheel_model.dart';
import 'roulette_preview.dart';

class RouletteCard extends StatelessWidget {
  final String rouletteId;
  final RouletteModel roulette;
  final bool isActive;
  final bool canReorder;
  final List<RouletteCardAction> actions;
  final String? subtitle;

  const RouletteCard({
    super.key,
    required this.rouletteId,
    required this.roulette,
    this.isActive = false,
    this.canReorder = false,
    required this.actions,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Remove this line: key: ValueKey(rouletteId),
      elevation: isActive ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              )
            : null,
        child: ExpansionTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canReorder) ...[
                Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                backgroundColor: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
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
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
              if (subtitle != null)
                Text(
                  subtitle!,
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
                  // Roulette Preview
                  RoulettePreview(size: 196, roulette: roulette),
                  const SizedBox(width: 16),
                  // Action Buttons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: actions
                          .map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildActionButton(
                                context: context,
                                icon: action.icon,
                                label: action.label,
                                onPressed: action.onPressed,
                                color: action.color,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
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
}

class RouletteCardAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const RouletteCardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });
}
