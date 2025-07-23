import 'package:flutter/material.dart';
import '../../consts/color_themes.dart';
import '../../utils/widget_utils.dart';
import '../../views/color_picker_view.dart';
import '../default_divider.dart';

class ColorThemeSelector extends StatelessWidget {
  final int selectedThemeIndex;
  final List<Color> customColors;
  final Function(int) onThemeChanged;
  final Function(List<Color>) onCustomColorsChanged;

  const ColorThemeSelector({
    super.key,
    required this.selectedThemeIndex,
    required this.customColors,
    required this.onThemeChanged,
    required this.onCustomColorsChanged,
  });

  void _showCustomColorPicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ColorPickerView(
          initialColors: customColors,
          onColorsChanged: (colors) {
            onCustomColorsChanged(colors);
          },
        ),
      ),
    );
  }

  Widget _buildThemeSelector({
    required BuildContext context,
    required List<Color> colors,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: colors.take(4).map((color) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: colorSampleDecoration(
                    context,
                    color,
                    width: name == 'Custom' ? 1 : 1,
                    alpha: name == 'Custom' ? 255 : 64,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Text(name, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(128),
              ),
              const SizedBox(width: 8),
              Text('Color Theme', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // Existing predefined themes
              ...DefaultColorThemes.all.asMap().entries.map((entry) {
                final index = entry.key;
                final colorTheme = entry.value;
                final isSelected = selectedThemeIndex == index;

                return _buildThemeSelector(
                  context: context,
                  colors: colorTheme.colors,
                  name: colorTheme.name,
                  isSelected: isSelected,
                  onTap: () => onThemeChanged(index),
                );
              }),

              // Custom theme option
              _buildThemeSelector(
                context: context,
                colors: customColors,
                name: 'Custom',
                isSelected: selectedThemeIndex == -1,
                onTap: () => _showCustomColorPicker(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
