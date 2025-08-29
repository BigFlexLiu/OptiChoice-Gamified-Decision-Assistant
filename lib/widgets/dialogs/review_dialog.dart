import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decision_spinner/consts/storage_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewDialog extends StatelessWidget {
  const ReviewDialog({super.key});

  static const String _storeUrl =
      'https://play.google.com/store/apps/details?id=dev.vfile.decision_spin';
  static const int _weekMs = 7 * 24 * 60 * 60 * 1000;
  static const int _dayMs = 24 * 60 * 60 * 1000;

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Don't show if already rated
    if (prefs.getBool(StorageConstants.reviewShownKey) ?? false) return;

    // Don't show if onboarding wasn't completed yet
    final onboardingCompleted =
        prefs.getBool(StorageConstants.onboardingCompletedKey) ?? false;
    if (!onboardingCompleted) return;

    // Don't show if less than 24 hours have passed since onboarding completion
    final onboardingTimestamp = prefs.getInt(
      StorageConstants.onboardingCompletedTimestampKey,
    );
    if (onboardingTimestamp != null) {
      final timeSinceOnboarding =
          DateTime.now().millisecondsSinceEpoch - onboardingTimestamp;
      if (timeSinceOnboarding < _dayMs) return;
    }

    // Don't show if postponed less than a week ago
    final postponed = prefs.getInt(StorageConstants.reviewPostponedKey);
    if (postponed != null &&
        DateTime.now().millisecondsSinceEpoch - postponed < _weekMs)
      return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ReviewDialog(),
      );
    }
  }

  Future<void> _handleRate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageConstants.reviewShownKey, true);
    Navigator.of(context).pop();

    try {
      await launchUrl(
        Uri.parse(_storeUrl),
        mode: LaunchMode.externalApplication,
      );
      _showSnackBar(context, 'Thank you! Opening Google Play Store...');
    } catch (e) {
      _showSnackBar(
        context,
        'Thank you! Please search for "Decision Spinner" in Google Play Store.',
      );
    }
  }

  Future<void> _handleRateLater(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      StorageConstants.reviewPostponedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    Navigator.of(context).pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enjoying Decision Spinner?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.star, color: Colors.amber, size: 40),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleRateLater(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Not now', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleRate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Rate It',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
