import 'package:decision_spinner/storage/base_storage_service.dart';
import 'package:flutter/material.dart';

class OnboardingTestUtils {
  /// Clear all onboarding preferences to simulate first-time user
  static Future<void> resetOnboarding() async {
    await BaseStorageService.remove('onboarding_completed');
  }

  /// Check onboarding status
  static Future<bool> isOnboardingCompleted() async {
    final completed = await BaseStorageService.getBool('onboarding_completed');
    return completed ?? false;
  }
}

class DebugOnboardingWidget extends StatefulWidget {
  const DebugOnboardingWidget({super.key});

  @override
  State<DebugOnboardingWidget> createState() => _DebugOnboardingWidgetState();
}

class _DebugOnboardingWidgetState extends State<DebugOnboardingWidget> {
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final completed = await OnboardingTestUtils.isOnboardingCompleted();
    setState(() {
      _onboardingCompleted = completed;
    });
  }

  Future<void> _resetOnboarding() async {
    await OnboardingTestUtils.resetOnboarding();
    await _checkOnboardingStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding reset! Restart the app to see onboarding.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Onboarding Debug',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_onboardingCompleted ? 'Completed' : 'Not completed'}',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _resetOnboarding,
              child: const Text('Reset Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
