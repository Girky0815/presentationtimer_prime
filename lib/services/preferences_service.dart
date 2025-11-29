import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import for BellConfig and ThemeMode

class PreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyDurationMin = 'duration_min';
  static const String _keyDurationSec = 'duration_sec';
  static const String _keyBells = 'bells';
  static const String _keyUseDynamicColor = 'use_dynamic_color';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.system; // Default
  }

  Future<void> saveDynamicColor(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDynamicColor, value);
  }

  Future<bool> loadDynamicColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseDynamicColor) ?? false;
  }

  Future<void> saveDuration(int min, int sec) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDurationMin, min);
    await prefs.setInt(_keyDurationSec, sec);
  }

  Future<Map<String, int>?> loadDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final min = prefs.getInt(_keyDurationMin);
    final sec = prefs.getInt(_keyDurationSec);
    if (min != null && sec != null) {
      return {'min': min, 'sec': sec};
    }
    return null;
  }

  Future<void> saveBells(List<BellConfig> bells) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        bells.map((bell) => jsonEncode(bell.toJson())).toList();
    await prefs.setStringList(_keyBells, jsonList);
  }

  Future<List<BellConfig>?> loadBells() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keyBells);

    if (jsonList != null) {
      return jsonList.map((jsonStr) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return BellConfig.fromJson(map);
      }).toList();
    }
    return null;
  }
}
