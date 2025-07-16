import 'package:flutter/material.dart';
import '../default_divider.dart';

class SpinDurationSection extends StatelessWidget {
  final Duration spinDuration;
  final Function(Duration) onDurationChanged;

  const SpinDurationSection({
    super.key,
    required this.spinDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = spinDuration.inMilliseconds / 1000.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(128),
              ),
              const SizedBox(width: 8),
              Text(
                '${seconds.toStringAsFixed(1)} ',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'seconds spin',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.titleSmall?.color?.withAlpha(128),
                ),
              ),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Slider(
                  value: seconds,
                  min: 0.5,
                  max: 5.0,
                  divisions: 45, // 0.1 second increments
                  label: '${seconds.toStringAsFixed(1)}s',
                  onChanged: (value) {
                    final duration = Duration(
                      milliseconds: (value * 1000).round(),
                    );
                    onDurationChanged(duration);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.0s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Fast',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      'Slow',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '5.0s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDurationDescription(seconds),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationDescription(double seconds) {
    if (seconds <= 1.5) {
      return 'Quick spin - great for fast decisions';
    } else if (seconds <= 2.5) {
      return 'Balanced spin - good for most situations';
    } else if (seconds <= 3.5) {
      return 'Moderate spin - builds anticipation';
    } else {
      return 'Long spin - maximum suspense';
    }
  }
}
