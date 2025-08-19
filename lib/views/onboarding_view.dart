import 'package:decision_spinner/consts/category_definitions.dart';
import 'package:decision_spinner/consts/storage_constants.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/storage/base_storage_service.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingView extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingView({super.key, this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  CategoryDefinition? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set the first category as default selection
    if (CategoryDefinitions.allCategories.isNotEmpty) {
      _selectedCategory = CategoryDefinitions.allCategories.first;
    }
  }

  static Future<void> markOnboardingCompleted() async {
    await BaseStorageService.saveBool(
      StorageConstants.onboardingCompletedKey,
      true,
    );
  }

  static Future<void> saveSelectedCategories(List<String> categoryIds) async {
    await BaseStorageService.saveJson(
      StorageConstants.selectedCategoriesKey,
      categoryIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(child: _buildCategoryGrid()),
              const SizedBox(height: 32),
              _buildActionButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Welcome to Decision Spinner!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select a category to get started.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return ListView.builder(
      itemCount: CategoryDefinitions.allCategories.length,
      itemBuilder: (context, index) {
        final category = CategoryDefinitions.allCategories[index];
        final isSelected = _selectedCategory == category;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildCategoryCard(category, isSelected),
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryDefinition category, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _toggleCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? category.color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: category.color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color
                          : category.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: 24,
                      color: isSelected ? Colors.white : category.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? category.color
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || _selectedCategory == null
            ? null
            : _completeOnboarding,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Get Started'),
      ),
    );
  }

  void _toggleCategory(CategoryDefinition category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_selectedCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );

      // Get example spinner from selected category
      // Take the first spinner from the selected category
      final exampleSpinner = _selectedCategory!.spinnerTemplates.first;

      // Create spinner
      final newSpinner = SpinnerModel.duplicate(exampleSpinner);
      await spinnerProvider.saveSpinner(newSpinner);
      final firstSpinnerId = newSpinner.id;

      // Set the first spinner as active
      await spinnersNotifier.setActiveSpinnerId(firstSpinnerId);

      // Save selected category
      final selectedCategoryIds = [_selectedCategory!.id];
      await saveSelectedCategories(selectedCategoryIds);

      // Mark onboarding as completed
      await markOnboardingCompleted();

      if (mounted) {
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error setting up spinners: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
