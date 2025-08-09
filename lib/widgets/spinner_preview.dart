import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'spinner_wheel.dart';
import '../storage/spinner_model.dart';
import '../providers/spinners_notifier.dart';
import '../providers/spinner_provider.dart';
import '../utils/widget_utils.dart';
import 'dialogs/spinner_conflict_dialog.dart';

class SpinnerPreview extends StatefulWidget {
  final SpinnerModel spinner;
  final double? size;
  final bool showSpinButton;
  final VoidCallback? onTap;
  final bool isFromSpinnerTemplates;

  const SpinnerPreview({
    super.key,
    required this.spinner,
    this.size,
    this.showSpinButton = false,
    this.onTap,
    this.isFromSpinnerTemplates = false,
  });

  @override
  State<SpinnerPreview> createState() => _SpinnerPreviewState();
}

class _SpinnerPreviewState extends State<SpinnerPreview> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => _handleSpinnerTap(context),
      child: SpinnerWheel(
        spinnerModel: widget.spinner,
        isSpinning: false,
        onSpinStart: () {},
        onSpinComplete: (_) {},
        showSpinButton: widget.showSpinButton,
        size: widget.size,
      ),
    );
  }

  Future<void> _handleSpinnerTap(BuildContext context) async {
    try {
      final spinnersNotifier = Provider.of<SpinnersNotifier>(
        context,
        listen: false,
      );

      // If this is from Manage Spinners view,
      // simply set as active and navigate back
      if (!widget.isFromSpinnerTemplates) {
        await spinnersNotifier.setActiveSpinnerId(widget.spinner.id);
        if (context.mounted) Navigator.of(context).pop(true);
        return;
      }

      SpinnerConflictResult? dialogResult;
      String? targetSpinnerId;

      // Check for existing spinner with same content first
      final existingSpinnerWithSameContent = spinnersNotifier
          .findSpinnerWithIdenticalContent(widget.spinner);

      if (existingSpinnerWithSameContent != null) {
        // Found identical content
        if (!context.mounted) return;
        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: widget.spinner.name,
            existingSpinnerWithSameContent: existingSpinnerWithSameContent,
          ),
        );
        if (dialogResult?.action == SpinnerConflictAction.useExisting) {
          targetSpinnerId = existingSpinnerWithSameContent.id;
        }
      } else if (spinnersNotifier.spinnerNameExists(widget.spinner.name)) {
        // Name conflict only
        final existingSpinnerWithSameName = spinnersNotifier.findSpinnerByName(
          widget.spinner.name,
        );
        if (!context.mounted) return;

        dialogResult = await showDialog<SpinnerConflictResult>(
          context: context,
          builder: (context) => SpinnerConflictDialog(
            proposedName: widget.spinner.name,
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
        widget.spinner.name = dialogResult!.newName!;
        await spinnerProvider.saveSpinner(widget.spinner);
        targetSpinnerId = widget.spinner.id;
      } else if (dialogResult?.action == SpinnerConflictAction.cancel) {
        return; // User cancelled
      } else if (targetSpinnerId == null) {
        // No conflicts, save directly
        await spinnerProvider.saveSpinner(widget.spinner);
        targetSpinnerId = widget.spinner.id;
      }

      // Set active spinner
      await spinnersNotifier.setActiveSpinnerId(targetSpinnerId);
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (context.mounted) {
        if (widget.isFromSpinnerTemplates) {
          showErrorSnackBar(context, 'Error: ${e.toString()}');
        } else {
          showErrorSnackBar(context, 'Failed to set spinner as active: $e');
        }
      }
    }
  }
}
