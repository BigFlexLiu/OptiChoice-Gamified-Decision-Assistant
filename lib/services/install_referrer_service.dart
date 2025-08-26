import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class InstallReferrerService {
  static final Logger _logger = Logger();
  // Toggle verbose logging automatically: verbose in debug/profile, minimal in release.
  static final bool _verbose = !kReleaseMode;
  static const String _referrerDataKey = 'install_referrer_data';
  static const String _referrerProcessedKey = 'install_referrer_processed';
  static const MethodChannel _channel = MethodChannel('install_referrer');

  /// Initialize the install referrer service
  /// This should be called once when the app starts
  static Future<void> initialize() async {
    try {
      // Only process referrer on Android
      if (!Platform.isAndroid) {
        if (_verbose) _logger.d('Install referrer only supported on Android');
        return;
      }

      // Check if we've already processed the referrer
      final prefs = await SharedPreferences.getInstance();
      final isProcessed = prefs.getBool(_referrerProcessedKey) ?? false;

      if (isProcessed) {
        if (_verbose)
          _logger.d('Install referrer already processed (flag true)');
        return;
      }

      // Get the install referrer information
      try {
        if (_verbose) _logger.i('Invoking getInstallReferrer...');
        final result = await _channel.invokeMethod('getInstallReferrer');
        if (_verbose) _logger.i('Raw MethodChannel result: $result');
        if (result != null && result is Map) {
          await _processReferrerData(result);
          await prefs.setBool(_referrerProcessedKey, true);
          if (_verbose) _logger.i('Install referrer marked processed');
        } else {
          // Log only once and minimal in release
          _logger.w('Install referrer empty');
          await prefs.setBool(
            _referrerProcessedKey,
            true,
          ); // prevent infinite retries on empty
        }
      } on PlatformException catch (e) {
        _logger.e('Install referrer platform exception: ${e.message}');
      }
    } catch (e) {
      _logger.e('Install referrer init error: $e');
    }
  }

  /// Process the referrer data and store it
  static Future<void> _processReferrerData(
    Map<dynamic, dynamic> details,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store the referrer data
      final referrerData = {
        'installReferrer': details['installReferrer']?.toString() ?? '',
        'referrerClickTimestamp':
            details['referrerClickTimestamp']?.toString() ?? '',
        'installBeginTimestamp':
            details['installBeginTimestamp']?.toString() ?? '',
        'googlePlayInstant':
            details['googlePlayInstant']?.toString() ?? 'false',
      };

      await prefs.setString(_referrerDataKey, referrerData.toString());

      if (_verbose) {
        _logger.i(
          'Install referrer processed referrer=${details['installReferrer']} clickTs=${details['referrerClickTimestamp']} installTs=${details['installBeginTimestamp']} instant=${details['googlePlayInstant']}',
        );
      } else {
        final hasRef =
            (details['installReferrer']?.toString().isNotEmpty ?? false);
        _logger.i('Install referrer ${hasRef ? 'received' : 'empty'}');
      }

      // Parse UTM parameters if present
      final installReferrer = details['installReferrer']?.toString() ?? '';
      if (installReferrer.isNotEmpty) {
        await _parseUtmParameters(installReferrer);
      }

      // Log custom event to Firebase Analytics
      // Log custom analytics event only if we actually have a referrer string.
      if (installReferrer.isNotEmpty) {
        try {
          await FirebaseAnalytics.instance.logEvent(
            name: 'install_referrer_observed',
            parameters: {
              'install_referrer': installReferrer,
              'referrer_click_ts':
                  details['referrerClickTimestamp']?.toString() ?? '',
              'install_begin_ts':
                  details['installBeginTimestamp']?.toString() ?? '',
              'google_play_instant':
                  details['googlePlayInstant']?.toString() ?? 'false',
            },
          );
          if (_verbose)
            _logger.i('Analytics event install_referrer_observed logged');
        } catch (e) {
          _logger.e('Analytics log error: $e');
        }
      }
    } catch (e) {
      _logger.e('Install referrer processing error: $e');
    }
  }

  static Future<void> _parseUtmParameters(String referrer) async {
    if (referrer.isEmpty) {
      if (_verbose) _logger.d('Empty referrer, skip UTM parse');
      return;
    }

    final decoded = Uri.decodeComponent(referrer);
    Map<String, String> params;
    try {
      params = Uri.splitQueryString(decoded);
    } catch (e) {
      if (_verbose)
        _logger.w('Failed to split referrer query: $decoded error: $e');
      return;
    }

    if (params.isEmpty) {
      if (_verbose) _logger.d('No params in referrer: $decoded');
      return;
    }
    if (_verbose) _logger.i('Decoded referrer params: $params');

    final prefs = await SharedPreferences.getInstance();
    const utmKeys = [
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
    ];

    for (final key in utmKeys) {
      final v = params[key];
      if (v != null && v.isNotEmpty) {
        await prefs.setString(key, v);
        if (_verbose) _logger.i('${key.toUpperCase()}: $v');
      }
    }

    for (final entry in params.entries) {
      if (!entry.key.startsWith('utm_')) {
        await prefs.setString('referrer_${entry.key}', entry.value);
        if (_verbose) _logger.i('Custom ${entry.key}: ${entry.value}');
      }
    }
  }

  /// Get stored referrer data
  static Future<Map<String, String?>> getReferrerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'utm_source': prefs.getString('utm_source'),
        'utm_medium': prefs.getString('utm_medium'),
        'utm_campaign': prefs.getString('utm_campaign'),
        'utm_term': prefs.getString('utm_term'),
        'utm_content': prefs.getString('utm_content'),
        'raw_referrer_data': prefs.getString(_referrerDataKey),
      };
    } catch (e) {
      _logger.e('Error getting referrer data: $e');
      return {};
    }
  }

  /// Debug helper to dump all stored referrer-related preferences.
  static Future<Map<String, String>> debugDumpAllReferrerPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = <String>{
      _referrerDataKey,
      _referrerProcessedKey,
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
      ...prefs.getKeys().where((k) => k.startsWith('referrer_')),
    };
    final map = <String, String>{};
    for (final k in keys) {
      final v = prefs.get(k);
      map[k] = v?.toString() ?? 'null';
    }
    if (_verbose) _logger.i('Referrer prefs dump: $map');
    return map;
  }

  /// Check if referrer has been processed
  static Future<bool> isReferrerProcessed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_referrerProcessedKey) ?? false;
    } catch (e) {
      if (_verbose) _logger.e('Error checking processed status: $e');
      return false;
    }
  }

  /// Reset referrer data (for testing purposes)
  static Future<void> resetReferrerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // List of all keys to remove
      final keysToRemove = [
        _referrerDataKey,
        _referrerProcessedKey,
        'utm_source',
        'utm_medium',
        'utm_campaign',
        'utm_term',
        'utm_content',
      ];

      // Remove each key
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      // Also remove any custom referrer parameters
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('referrer_')) {
          await prefs.remove(key);
        }
      }

      if (_verbose) _logger.i('Referrer data reset');
    } catch (e) {
      if (_verbose) _logger.e('Error resetting referrer data: $e');
    }
  }
}
