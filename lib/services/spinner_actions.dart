import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/spinner_model.dart';
import '../providers/spinners_notifier.dart';
import '../providers/spinner_provider.dart';
import '../utils/widget_utils.dart';
import '../widgets/dialogs/spinner_conflict_dialog.dart';

class SpinnerActions {
  static Future<void> handleManageSpinnersTap(
    BuildContext context,
    SpinnerModel spinner,
  ) async {
    try {
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );

      await spinnersNotifier.setActiveSpinnerId(spinner.id);
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Failed to set spinner as active: $e');
      }
    }
  }

  static Future<void> handleTemplateSelectionTap(
    BuildContext context,
    SpinnerModel spinner,
  ) async {
    try {
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );
      final spinnerProvider = Provider.of<SpinnerProvider>(
        context,
        listen: false,
      );

      final targetSpinnerId = await _resolveSpinnerConflicts(
        context,
        spinner,
        spinnersNotifier,
        spinnerProvider,
      );

      if (targetSpinnerId != null) {
        await spinnersNotifier.setActiveSpinnerId(targetSpinnerId);
        if (context.mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  static Future<String?> _resolveSpinnerConflicts(
    BuildContext context,
    SpinnerModel spinner,
    SpinnersNotifier spinnersNotifier,
    SpinnerProvider spinnerProvider,
  ) async {
    SpinnerConflictResult? dialogResult;

    // Check for existing spinner with identical content
    final existingSpinnerWithSameContent = spinnersNotifier
        .findSpinnerWithIdenticalContent(spinner);

    if (existingSpinnerWithSameContent != null) {
      if (!context.mounted) return null;
      dialogResult = await _showConflictDialog(
        context,
        spinner,
        existingSpinnerWithSameContent: existingSpinnerWithSameContent,
      );
      if (dialogResult?.action == SpinnerConflictAction.useExisting) {
        return existingSpinnerWithSameContent.id;
      }
    } else if (spinnersNotifier.spinnerNameExists(spinner.name)) {
      // Handle name conflict only
      final existingSpinnerWithSameName = spinnersNotifier.findSpinnerByName(
        spinner.name,
      );
      if (!context.mounted) return null;

      dialogResult = await _showConflictDialog(
        context,
        spinner,
        existingSpinnerWithSameName: existingSpinnerWithSameName,
      );
      if (dialogResult?.action == SpinnerConflictAction.useExisting &&
          existingSpinnerWithSameName != null) {
        return existingSpinnerWithSameName.id;
      }
    }

    // Handle dialog result and create/save spinner
    return await _processConflictResolution(
      dialogResult,
      spinner,
      spinnerProvider,
    );
  }

  static Future<SpinnerConflictResult?> _showConflictDialog(
    BuildContext context,
    SpinnerModel spinner, {
    SpinnerModel? existingSpinnerWithSameContent,
    SpinnerModel? existingSpinnerWithSameName,
  }) async {
    return await showDialog<SpinnerConflictResult>(
      context: context,
      builder: (context) => SpinnerConflictDialog(
        proposedName: spinner.name,
        existingSpinnerWithSameContent: existingSpinnerWithSameContent,
        existingSpinnerWithSameName: existingSpinnerWithSameName,
      ),
    );
  }

  static Future<String?> _processConflictResolution(
    SpinnerConflictResult? dialogResult,
    SpinnerModel spinner,
    SpinnerProvider spinnerProvider,
  ) async {
    if (dialogResult?.action == SpinnerConflictAction.createNew &&
        dialogResult?.newName != null) {
      spinner.name = dialogResult!.newName!;
      await spinnerProvider.saveSpinner(spinner);
      return spinner.id;
    } else if (dialogResult?.action == SpinnerConflictAction.cancel) {
      return null; // User cancelled
    } else {
      // No conflicts, save directly
      await spinnerProvider.saveSpinner(spinner);
      return spinner.id;
    }
  }
}
