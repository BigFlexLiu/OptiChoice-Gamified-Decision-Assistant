import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class BaseStorageService {
  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  /// Save string value
  static Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setString(key, value);
    } catch (e) {
      return false;
    }
  }

  /// Get string value
  static Future<String?> getString(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// Save int value
  static Future<bool> saveInt(String key, int value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setInt(key, value);
    } catch (e) {
      return false;
    }
  }

  /// Get int value
  static Future<int?> getInt(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getInt(key);
    } catch (e) {
      return null;
    }
  }

  /// Save bool value
  static Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setBool(key, value);
    } catch (e) {
      return false;
    }
  }

  /// Get bool value
  static Future<bool?> getBool(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(key);
    } catch (e) {
      return null;
    }
  }

  /// Remove key
  static Future<bool> remove(String key) async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }

  /// Save JSON data
  static Future<bool> saveJson(String key, dynamic data) async {
    try {
      final jsonString = jsonEncode(data);
      return await saveString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get JSON data
  static Future<dynamic> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }
}
