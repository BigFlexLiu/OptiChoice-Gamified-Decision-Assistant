import 'package:flutter/material.dart';
import '../storage/spinner_model.dart';
import 'spinner_preview.dart';

class SpinnerCard extends StatelessWidget {
  final SpinnerModel spinner;
  final bool isActive;
  final bool canReorder;
  final List<SpinnerCardAction> actions;
  final String? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final bool isExpanded;

  const SpinnerCard({
    super.key,
    required this.spinner,
    required this.actions,
    required this.onExpansionChanged,
    required this.isExpanded,
    this.isActive = false,
    this.canReorder = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double borderRadius = 24;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(borderRadius)),
      ),
      elevation: isActive || isExpanded ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ExpansionTile(
            onExpansionChanged: onExpansionChanged,
            initiallyExpanded: isExpanded,
            backgroundColor: isExpanded ? Theme.of(context).canvasColor : null,
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
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    spinner.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
                  '${spinner.options.length} options',
                  style: theme.textTheme.bodyMedium,
                ),
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith()),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spinner Preview
                    Expanded(child: SpinnerPreview(spinner: spinner)),
                    const SizedBox(width: 8),
                    // Action Buttons
                    IntrinsicWidth(
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

    return ElevatedButton(
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
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Text(
              label,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SpinnerCardAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const SpinnerCardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });
}
