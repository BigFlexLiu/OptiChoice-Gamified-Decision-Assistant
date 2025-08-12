import 'package:flutter/material.dart';

class CategoryReorderDialog extends StatefulWidget {
  const CategoryReorderDialog({
    super.key,
    required this.categories,
    required this.onReorder,
  });

  final List<CategoryInfo> categories;
  final Function(List<String>) onReorder;

  @override
  State<CategoryReorderDialog> createState() => _CategoryReorderDialogState();
}

class _CategoryReorderDialogState extends State<CategoryReorderDialog> {
  late List<CategoryInfo> _reorderedCategories;

  @override
  void initState() {
    super.initState();
    _reorderedCategories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Reorder Categories'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Drag to reorder your preferred category sequence',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _reorderedCategories.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _reorderedCategories.removeAt(oldIndex);
                    _reorderedCategories.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final category = _reorderedCategories[index];
                  return _CategoryReorderTile(
                    key: ValueKey(category.id),
                    category: category,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reorderedIds = _reorderedCategories.map((c) => c.id).toList();
            widget.onReorder(reorderedIds);
            Navigator.of(context).pop();
          },
          child: const Text('Save Order'),
        ),
      ],
    );
  }
}

class _CategoryReorderTile extends StatelessWidget {
  const _CategoryReorderTile({
    super.key,
    required this.category,
    required this.index,
  });

  final CategoryInfo category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            category.icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(category.label),
        subtitle: Text(
          category.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
  });

  final String id;
  final IconData icon;
  final String label;
  final String description;
}
