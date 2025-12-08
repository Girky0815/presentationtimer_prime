import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/bell_config.dart';
import '../services/preferences_service.dart';

// --- State Management ---
class TimerState extends ChangeNotifier {
  // Settings
  int durationMin = 10;
  int durationSec = 0;
  List<BellConfig> bells = [
    BellConfig(id: 1, min: 8, sec: 0, count: 1),
    BellConfig(id: 2, min: 10, sec: 0, count: 2),
    BellConfig(id: 3, min: 14, sec: 0, count: 3),
  ];

  List<BellConfig> get sortedBells {
    final sorted = List<BellConfig>.from(bells);
    sorted.sort((a, b) => a.totalSeconds.compareTo(b.totalSeconds));
    return sorted;
  }

  ThemeMode themeMode = ThemeMode.system;
  bool useDynamicColor = false;

  // Timer State
  Timer? _timer;
  bool isRunning = false;
  int elapsedSeconds = 0;
  String mode = 'stopwatch'; // 'timer' | 'stopwatch'

  // SoLoud engine
  final SoLoud _soloud = SoLoud.instance;
  AudioSource? _bellSource;
  late final AppLifecycleListener _lifecycleListener;

  final PreferencesService _prefs = PreferencesService();

  TimerState() {
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: _onExitRequested,
    );
    _initAudio();
    _loadSettings();
  }

  Future<ui.AppExitResponse> _onExitRequested() async {
    try {
      _soloud.deinit();
    } catch (e) {
      debugPrint("Error during deinit: $e");
    }
    return ui.AppExitResponse.exit;
  }

  Future<void> _loadSettings() async {
    // Load Theme
    themeMode = await _prefs.loadThemeMode();
    useDynamicColor = await _prefs.loadDynamicColor();

    // Load Duration
    final duration = await _prefs.loadDuration();
    if (duration != null) {
      durationMin = duration['min']!;
      durationSec = duration['sec']!;
    }

    // Load Bells
    final loadedBells = await _prefs.loadBells();
    if (loadedBells != null) {
      bells = loadedBells;
    }

    notifyListeners();
  }

  Future<void> _initAudio() async {
    try {
      // Initialize SoLoud engine
      await _soloud.init();
      // Load bell sound into memory
      _bellSource = await _soloud.loadAsset('assets/sounds/bell.mp3');
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  int get totalDuration => durationMin * 60 + durationSec;

  int get displayTime {
    if (mode == 'timer') {
      return totalDuration - elapsedSeconds;
    } else {
      return elapsedSeconds;
    }
  }

  bool get isOvertime {
    if (mode == 'timer') {
      return displayTime < 0;
    } else {
      return elapsedSeconds > totalDuration;
    }
  }

  void toggleMode(String newMode) {
    mode = newMode;
    // React版同様、タイマー切り替え時にストップさせる挙動にするならここで stop()
    // 今回は同期重視で走り続ける仕様とする
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs.saveThemeMode(mode);
    notifyListeners();
  }

  void toggleDynamicColor(bool value) {
    useDynamicColor = value;
    _prefs.saveDynamicColor(value);
    notifyListeners();
  }

  void startStop() {
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
    } else {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsedSeconds++;
        _checkBells();
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    elapsedSeconds = 0;
    notifyListeners();
  }

  void updateDuration(int min, int sec) {
    durationMin = min;
    durationSec = sec;
    _prefs.saveDuration(min, sec);
    notifyListeners();
  }

  // Bells Logic
  void addBell(int min, int sec, int count) {
    int newId = (bells.isNotEmpty
            ? bells.map((b) => b.id).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    bells.add(BellConfig(id: newId, min: min, sec: sec, count: count));
    _prefs.saveBells(bells);
    notifyListeners();
  }

  void removeBell(int id) {
    bells.removeWhere((b) => b.id == id);
    _prefs.saveBells(bells);
    notifyListeners();
  }

  void updateBell(int id, {int? min, int? sec, int? count}) {
    var bell = bells.firstWhere((b) => b.id == id);
    if (min != null) bell.min = min;
    if (sec != null) bell.sec = sec;
    if (count != null) bell.count = count;
    _prefs.saveBells(bells);
    notifyListeners();
  }

  Future<void> _checkBells() async {
    for (var bell in bells) {
      if (bell.totalSeconds == elapsedSeconds) {
        // Play sound 'bell.count' times
        for (int i = 0; i < bell.count; i++) {
          // Fire and forget playback to ensure consistent timing
          _playBellFromPool();

          // Delay between bells (500ms)
          if (i < bell.count - 1) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }
    }
  }

  void _playBellFromPool() {
    try {
      if (_bellSource != null) {
        _soloud.play(_bellSource!);
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _soloud.deinit();
    super.dispose();
  }
}
