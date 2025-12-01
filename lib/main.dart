import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/preferences_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: const PresentationTimerApp(),
    ),
  );
}

// --- Custom Color Schemes (User Defined) ---
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF286A56),
  onPrimary: Color(0xFFE4FFF2),
  primaryContainer: Color(0xFFAEF0D7),
  onPrimaryContainer: Color(0xFF175C49),
  inversePrimary: Color(0xFFB9FCE2),
  secondary: Color(0xFF4C645A),
  onSecondary: Color(0xFFE4FFF2),
  secondaryContainer: Color(0xFFCEE9DC),
  onSecondaryContainer: Color(0xFF3F574D),
  tertiary: Color(0xFF2E6771),
  onTertiary: Color(0xFFEDFBFF),
  tertiaryContainer: Color(0xFFB7EFFB),
  onTertiaryContainer: Color(0xFF215B65),
  error: Color(0xFFA83836),
  onError: Color(0xFFFFF7F6),
  errorContainer: Color(0xFFFA746F),
  onErrorContainer: Color(0xFF6E0A12),
  background: Color(0xFFF6FAF6),
  onBackground: Color(0xFF2B3530),
  surface: Color(0xFFF6FAF6),
  onSurface: Color(0xFF2B3530),
  surfaceVariant: Color(0xFFDAE5DF),
  onSurfaceVariant: Color(0xFF57615C),
  inverseSurface: Color(0xFF0B0F0D),
  onInverseSurface: Color(0xFF999E9B),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFEFF5F0),
  surfaceContainer: Color(0xFFE8F0EA),
  surfaceContainerHigh: Color(0xFFE1EAE4),
  surfaceContainerHighest: Color(0xFFDAE5DF),
  surfaceDim: Color(0xFFD2DDD6),
  surfaceBright: Color(0xFFF6FAF6),
  outline: Color(0xFF737D78),
  outlineVariant: Color(0xFFAAB4AE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF9FD1BD),
  onPrimary: Color(0xFF174839),
  primaryContainer: Color(0xFF2C5B4B),
  onPrimaryContainer: Color(0xFFBCEED9),
  inversePrimary: Color(0xFF396858),
  secondary: Color(0xFFB2CCC0),
  onSecondary: Color(0xFF2E453C),
  secondaryContainer: Color(0xFF294037),
  onSecondaryContainer: Color(0xFFABC5B9),
  tertiary: Color(0xFFDDF9FF),
  onTertiary: Color(0xFF2B636E),
  tertiaryContainer: Color(0xFFB7EFFB),
  onTertiaryContainer: Color(0xFF205B65),
  error: Color(0xFFFA746F),
  onError: Color(0xFF490006),
  errorContainer: Color(0xFF871F21),
  onErrorContainer: Color(0xFFFF9993),
  background: Color(0xFF0B0F0D),
  onBackground: Color(0xFFDDE8E1),
  surface: Color(0xFF0B0F0D),
  onSurface: Color(0xFFDDE8E1),
  surfaceVariant: Color(0xFF1E2824),
  onSurfaceVariant: Color(0xFFA3AEA8),
  inverseSurface: Color(0xFFF6FAF6),
  onInverseSurface: Color(0xFF515653),
  surfaceContainerLowest: Color(0xFF000000),
  surfaceContainerLow: Color(0xFF0E1512),
  surfaceContainer: Color(0xFF141B18),
  surfaceContainerHigh: Color(0xFF19211E),
  surfaceContainerHighest: Color(0xFF1E2824),
  surfaceDim: Color(0xFF0B0F0D),
  surfaceBright: Color(0xFF242E2A),
  outline: Color(0xFF6D7872),
  outlineVariant: Color(0xFF404A45),
  scrim: Color(0xFF000000),
);

// --- Models ---
class BellConfig {
  final int id;
  int min;
  int sec;
  int count;

  BellConfig(
      {required this.id, required this.min, required this.sec, this.count = 1});

  int get totalSeconds => min * 60 + sec;

  Map<String, dynamic> toJson() => {
        'id': id,
        'min': min,
        'sec': sec,
        'count': count,
      };

  factory BellConfig.fromJson(Map<String, dynamic> json) {
    return BellConfig(
      id: json['id'],
      min: json['min'],
      sec: json['sec'],
      count: json['count'] ?? 1,
    );
  }
}

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

class PresentationTimerApp extends StatelessWidget {
  const PresentationTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final timerState = context.watch<TimerState>();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (timerState.useDynamicColor &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = lightColorScheme;
          darkScheme = darkColorScheme;
        }

        return MaterialApp(
          title: 'Presentation Timer',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja'), // Japanese
          ],
          locale: const Locale('ja'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightScheme.surfaceContainerHigh,
            cardTheme: CardThemeData(color: lightScheme.surfaceBright),
            dialogTheme:
                DialogThemeData(backgroundColor: lightScheme.surfaceBright),
            textTheme: _buildSmartTextTheme(
              ThemeData(brightness: Brightness.light).textTheme,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScheme.surfaceContainerHigh,
            cardTheme: CardThemeData(color: darkScheme.surfaceBright),
            dialogTheme:
                DialogThemeData(backgroundColor: darkScheme.surfaceBright),
            textTheme: _buildSmartTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
          ),
          themeMode: timerState.themeMode,
          home: const TimerScreen(),
        );
      },
    );
  }

  TextTheme _buildSmartTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: _getSmartTextStyle(baseStyle: base.displayLarge),
      displayMedium: _getSmartTextStyle(baseStyle: base.displayMedium),
      displaySmall: _getSmartTextStyle(baseStyle: base.displaySmall),
      headlineLarge: _getSmartTextStyle(baseStyle: base.headlineLarge),
      headlineMedium: _getSmartTextStyle(baseStyle: base.headlineMedium),
      headlineSmall: _getSmartTextStyle(baseStyle: base.headlineSmall),
      titleLarge: _getSmartTextStyle(baseStyle: base.titleLarge),
      titleMedium: _getSmartTextStyle(baseStyle: base.titleMedium),
      titleSmall: _getSmartTextStyle(baseStyle: base.titleSmall),
      bodyLarge: _getSmartTextStyle(baseStyle: base.bodyLarge),
      bodyMedium: _getSmartTextStyle(baseStyle: base.bodyMedium),
      bodySmall: _getSmartTextStyle(baseStyle: base.bodySmall),
      labelLarge: _getSmartTextStyle(baseStyle: base.labelLarge),
      labelMedium: _getSmartTextStyle(baseStyle: base.labelMedium),
      labelSmall: _getSmartTextStyle(baseStyle: base.labelSmall),
    );
  }

  static TextStyle _getSmartTextStyle({
    TextStyle? baseStyle,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    List<FontFeature>? fontFeatures,
    String? fallbackFamily,
  }) {
    final defaultFallback = 'Quicksand';
    final targetFallback = fallbackFamily ?? defaultFallback;

    try {
      return GoogleFonts.getFont(
        'Google Sans Flex',
        textStyle: baseStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFeatures: fontFeatures,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
      );
    } catch (e) {
      // Fallback to specified font (Quicksand or Roboto Mono)
      return GoogleFonts.getFont(
        targetFallback,
        textStyle: baseStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFeatures: fontFeatures,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
      );
    }
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final timerFontSize = screenHeight * 0.25;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnimatedModeSwitcher(
                        currentMode: state.mode,
                        onModeChanged: (newMode) => state.toggleMode(newMode),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bells List
                      SizedBox(
                        height: 100,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...state.sortedBells.map((bell) {
                                  return _BellChip(bell: bell);
                                }),
                                // Add Button
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (c) => BellEditDialog(
                                          initialBell: null, // New bell
                                          onSave: (min, sec, count) {
                                            state.addBell(min, sec, count);
                                          },
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 60,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colorScheme.outlineVariant,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(Icons.add,
                                          color: colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Huge Timer Display
                      GestureDetector(
                        onTap: () => state.toggleMode(
                            state.mode == 'timer' ? 'stopwatch' : 'timer'),
                        child: Hero(
                          tag: 'timer_text',
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatTime(state.displayTime),
                              style: TextStyle(
                                fontFamily: 'Google Sans Flex',
                                fontSize: timerFontSize,
                                fontWeight: FontWeight.w400,
                                color: state.isOvertime
                                    ? colorScheme.error
                                    : colorScheme.onSurface,
                                fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ],
                                fontVariations: const [
                                  FontVariation('ROND', 100),
                                  FontVariation('wdth', 75),
                                  FontVariation('wght', 400),
                                ],
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Text(
                        state.mode == 'timer'
                            ? (state.displayTime < 0 ? '超過' : '残り')
                            : (state.isOvertime ? '超過' : '経過'),
                        style: TextStyle(
                          fontSize: 24,
                          color: state.isOvertime
                              ? colorScheme.error
                              : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            onPressed: state.reset,
                            // Changed to restart_alt for better semantic (Counter-clockwise arrow)
                            icon: const Icon(Icons.restart_alt),
                            iconSize: 32,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(24),
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton.filled(
                            onPressed: state.startStop,
                            // Rounded play arrow feels more Material 3
                            icon: Icon(state.isRunning
                                ? Icons.pause
                                : Icons.play_arrow_rounded),
                            iconSize: 48,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(32),
                              backgroundColor: state.isRunning
                                  ? colorScheme.primary
                                  : colorScheme.primaryContainer,
                              foregroundColor: state.isRunning
                                  ? colorScheme.onPrimary
                                  : colorScheme.onPrimaryContainer,
                              shape: state.isRunning
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24))
                                  : const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Settings Button (Absolute)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                // Use outlined variant for settings
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Settings",
                    pageBuilder: (ctx, a1, a2) => const SettingsPanel(),
                    transitionBuilder: (ctx, a1, a2, child) {
                      return SlideTransition(
                        position:
                            Tween(begin: const Offset(1, 0), end: Offset.zero)
                                .animate(CurvedAnimation(
                                    parent: a1, curve: Curves.easeOutQuad)),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sub Widgets ---

class _AnimatedModeSwitcher extends StatefulWidget {
  final String currentMode;
  final Function(String) onModeChanged;

  const _AnimatedModeSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<_AnimatedModeSwitcher> createState() => _AnimatedModeSwitcherState();
}

class _AnimatedModeSwitcherState extends State<_AnimatedModeSwitcher> {
  final GlobalKey _stopwatchKey = GlobalKey();
  final GlobalKey _timerKey = GlobalKey();

  double _stopwatchWidth = 0;
  double _timerWidth = 0;

  @override
  void initState() {
    super.initState();
    // Initial measurement
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSizes());
  }

  void _updateSizes() {
    final stopwatchBox =
        _stopwatchKey.currentContext?.findRenderObject() as RenderBox?;
    final timerBox = _timerKey.currentContext?.findRenderObject() as RenderBox?;

    if (stopwatchBox != null && timerBox != null) {
      final newStopwatchWidth = stopwatchBox.size.width;
      final newTimerWidth = timerBox.size.width;

      if (newStopwatchWidth != _stopwatchWidth ||
          newTimerWidth != _timerWidth) {
        setState(() {
          _stopwatchWidth = newStopwatchWidth;
          _timerWidth = newTimerWidth;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Schedule size update after every build to handle font weight changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSizes());

    final colorScheme = Theme.of(context).colorScheme;
    final isStopwatch = widget.currentMode == 'stopwatch';

    // Define labels and icons
    const labelStopwatch = "ストップウォッチ";
    const labelTimer = "タイマー";
    const iconStopwatch = Icons.timer_outlined;
    const iconTimer = Icons.timer;

    // Calculate slider position and width
    // Default to 0 if not yet measured (will update after first frame)
    final double sliderLeft = isStopwatch ? 0 : _stopwatchWidth;
    final double sliderWidth =
        isStopwatch ? (_stopwatchWidth > 0 ? _stopwatchWidth : 0) : _timerWidth;

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateSizes());
        return true;
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          children: [
            // Sliding Indicator
            if (_stopwatchWidth > 0 && _timerWidth > 0)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubicEmphasized,
                left: sliderLeft,
                top: 0,
                bottom: 0,
                width: sliderWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            // Buttons Row
            SizeChangedLayoutNotifier(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    context,
                    key: _stopwatchKey,
                    label: labelStopwatch,
                    icon: iconStopwatch,
                    isSelected: isStopwatch,
                    onTap: () => widget.onModeChanged('stopwatch'),
                  ),
                  _buildButton(
                    context,
                    key: _timerKey,
                    label: labelTimer,
                    icon: iconTimer,
                    isSelected: !isStopwatch,
                    onTap: () => widget.onModeChanged('timer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required Key key,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BellChip extends StatelessWidget {
  final BellConfig bell;

  const _BellChip({required this.bell});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;
    final bellTime = bell.totalSeconds;
    final isPassed = state.elapsedSeconds >= bellTime;
    // Check if this is the last bell in the SORTED list
    final isLastBell =
        state.sortedBells.isNotEmpty && state.sortedBells.last.id == bell.id;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (c) => BellEditDialog(
              initialBell: bell,
              onSave: (min, sec, count) {
                state.updateBell(bell.id, min: min, sec: sec, count: count);
              },
              onDelete: () {
                state.removeBell(bell.id);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: (isPassed && state.isRunning)
                ? colorScheme.tertiary
                : colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    isLastBell
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    size: 14,
                    color: (isPassed && state.isRunning)
                        ? colorScheme.onTertiary
                        : colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "ベル ${state.bells.indexOf(bell) + 1}",
                    style: PresentationTimerApp._getSmartTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: (isPassed && state.isRunning)
                          ? colorScheme.onTertiary
                          : colorScheme.onTertiaryContainer
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(bellTime).replaceAll('-', ''),
                style: TextStyle(
                  fontFamily: 'Google Sans Flex',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: (isPassed && state.isRunning)
                      ? colorScheme.onTertiary
                      : colorScheme.onTertiaryContainer,
                  fontVariations: const [
                    FontVariation('wght', 500),
                    FontVariation('ROND', 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  PackageInfo? _packageInfo;

  final WidgetStateProperty<Icon?> _thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  });

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _buildThemeButton(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isSelected ? colorScheme.primary : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        child: Container(
          width: 400,
          height: double.infinity,
          color: colorScheme.surfaceContainer,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.2)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("設定",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Appearance
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("外観",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            // Theme Mode Selection
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        state.themeMode == ThemeMode.system
                                            ? Icons.brightness_auto
                                            : state.themeMode == ThemeMode.light
                                                ? Icons.light_mode
                                                : Icons.dark_mode,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text("テーマ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface)),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: colorScheme.outlineVariant),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildThemeButton(
                                            context,
                                            mode: ThemeMode.system,
                                            icon: Icons.brightness_auto,
                                            label: "システム",
                                            isSelected: state.themeMode ==
                                                ThemeMode.system,
                                            onTap: () => state
                                                .setThemeMode(ThemeMode.system),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 32,
                                              color:
                                                  colorScheme.outlineVariant),
                                          _buildThemeButton(
                                            context,
                                            mode: ThemeMode.light,
                                            icon: Icons.light_mode,
                                            label: "ライト",
                                            isSelected: state.themeMode ==
                                                ThemeMode.light,
                                            onTap: () => state
                                                .setThemeMode(ThemeMode.light),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 32,
                                              color:
                                                  colorScheme.outlineVariant),
                                          _buildThemeButton(
                                            context,
                                            mode: ThemeMode.dark,
                                            icon: Icons.dark_mode,
                                            label: "ダーク",
                                            isSelected: state.themeMode ==
                                                ThemeMode.dark,
                                            onTap: () => state
                                                .setThemeMode(ThemeMode.dark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 4,
                              color: colorScheme.surfaceContainerHigh,
                            ),
                            SwitchListTile(
                              title: const Text("ダイナミックカラー(beta)",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              // subtitle: const Text("壁紙の色に合わせてテーマを変更"),
                              subtitle: const Text("OSのアクセントカラーを使用"),
                              value: state.useDynamicColor,
                              onChanged: (v) => state.toggleDynamicColor(v),
                              thumbIcon: _thumbIcon,
                              secondary: const Icon(Icons.palette_outlined),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: state.useDynamicColor
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surfaceBright,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline,
                                                  size: 18,
                                                  color: colorScheme.primary),
                                              const SizedBox(width: 12),
                                              Flexible(
                                                child: Text(
                                                  "OSのアクセントカラーを変更した場合、\n反映するにはアプリの再起動が必要です。",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          colorScheme.primary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Timer Duration
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("タイマー設定",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.2)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("発表時間",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface)),
                                    Text("プレゼンの持ち時間",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _TimeInputBox(
                                  value: state.durationMin,
                                  onChanged: (v) => state.updateDuration(
                                      v, state.durationSec),
                                  label: "分",
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: Text(":",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("",
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                _TimeInputBox(
                                  value: state.durationSec,
                                  onChanged: (v) => state.updateDuration(
                                      state.durationMin, v),
                                  label: "秒",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "メイン画面のベルカードを押すと\nベルの設定を変更できます。",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("概要",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.palette_outlined,
                                  color: colorScheme.primary),
                              title: Text("カラーパレット一覧",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                              subtitle: Text("(デバッグ用)カラーパレットを表示",
                                  style:
                                      TextStyle(color: colorScheme.onSurface)),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ColorSchemePreviewScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: colorScheme.surfaceContainerHigh),
                            ListTile(
                              leading: Icon(Icons.info_outline,
                                  color: colorScheme.primary),
                              title: Text("プレゼンタイマー Prime (仮)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                              subtitle: _packageInfo != null
                                  ? Text(
                                      "バージョン ${_packageInfo!.version} (ビルド ${_packageInfo!.buildNumber})",
                                      style: TextStyle(
                                          color: colorScheme.onSurfaceVariant))
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BellEditDialog extends StatefulWidget {
  final BellConfig? initialBell;
  final Function(int min, int sec, int count) onSave;
  final VoidCallback? onDelete;

  const BellEditDialog({
    super.key,
    this.initialBell,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<BellEditDialog> createState() => _BellEditDialogState();
}

class _BellEditDialogState extends State<BellEditDialog> {
  late int min;
  late int sec;
  late int count;

  @override
  void initState() {
    super.initState();
    if (widget.initialBell != null) {
      min = widget.initialBell!.min;
      sec = widget.initialBell!.sec;
      count = widget.initialBell!.count;
    } else {
      // Default values for new bell (e.g. 5 min)
      min = 5;
      sec = 0;
      count = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.initialBell != null;

    return Dialog(
      backgroundColor: colorScheme.surfaceBright,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? "ベル設定" : "ベル追加",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold)),
                    Text("タイミングと回数を設定",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),

            // Time Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("鳴動タイミング (経過時間)",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeInputBox(
                        value: min,
                        onChanged: (v) => setState(() => min = v),
                        label: "分",
                        fontSize: 32,
                        padding: 12,
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Transform.translate(
                              offset: const Offset(0, -4),
                              child: Text(":",
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      _TimeInputBox(
                        value: sec,
                        onChanged: (v) => setState(() => sec = v),
                        label: "秒",
                        fontSize: 32,
                        padding: 12,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Count Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("鳴動回数",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text("ベルを鳴らす回数を設定",
                            style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => setState(
                              () => count = (count > 1 ? count - 1 : 1)),
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                            width: 32,
                            child: Center(
                                child: Text("$count",
                                    style: TextStyle(
                                        fontFamily: 'Google Sans Flex',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        fontVariations: const [
                                          FontVariation('ROND', 100)
                                        ])))),
                        IconButton.filledTonal(
                          onPressed: () => setState(() => count = count + 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        if (widget.onDelete != null) widget.onDelete!();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("削除"),
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      widget.onSave(min, sec, count);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("OK"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TimeInputBox extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final double fontSize;
  final double padding;

  const _TimeInputBox({
    required this.value,
    required this.onChanged,
    required this.label,
    this.fontSize = 20,
    this.padding = 8,
  });

  @override
  State<_TimeInputBox> createState() => _TimeInputBoxState();
}

class _TimeInputBoxState extends State<_TimeInputBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.value.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _TimeInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != int.tryParse(_controller.text)) {
      _controller.text = widget.value.toString().padLeft(2, '0');
      // Try to keep cursor but it's tricky with formatting. Resetting to end is safer.
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          width: widget.fontSize * 2.5,
          padding: EdgeInsets.all(widget.padding),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Google Sans Flex',
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontVariations: const [FontVariation('ROND', 100)],
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (val) {
              if (val.isEmpty) return;
              widget.onChanged(int.parse(val));
            },
            onTapOutside: (_) {
              // Re-format on blur
              _controller.text = widget.value.toString().padLeft(2, '0');
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(widget.label,
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// Helper
String _formatTime(int totalSeconds) {
  final absSeconds = totalSeconds.abs();
  final m = (absSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (absSeconds % 60).toString().padLeft(2, '0');
  final sign = totalSeconds < 0 ? '-' : '';
  return "$sign$m:$s";
}

class ColorSchemePreviewScreen extends StatelessWidget {
  const ColorSchemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<TimerState>();

    // Helper to build color data tuple
    (String, Color, Color) c(String name, Color color, Color onColor) =>
        (name, color, onColor);

    final coreColors = [
      c("Primary", colorScheme.primary, colorScheme.onPrimary),
      c("On Primary", colorScheme.onPrimary, colorScheme.primary),
      c("Primary Container", colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer),
      c("On Primary Container", colorScheme.onPrimaryContainer,
          colorScheme.primaryContainer),
      c("Secondary", colorScheme.secondary, colorScheme.onSecondary),
      c("On Secondary", colorScheme.onSecondary, colorScheme.secondary),
      c("Secondary Container", colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer),
      c("On Secondary Container", colorScheme.onSecondaryContainer,
          colorScheme.secondaryContainer),
      c("Tertiary", colorScheme.tertiary, colorScheme.onTertiary),
      c("On Tertiary", colorScheme.onTertiary, colorScheme.tertiary),
      c("Tertiary Container", colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer),
      c("On Tertiary Container", colorScheme.onTertiaryContainer,
          colorScheme.tertiaryContainer),
      c("Error", colorScheme.error, colorScheme.onError),
      c("On Error", colorScheme.onError, colorScheme.error),
      c("Error Container", colorScheme.errorContainer,
          colorScheme.onErrorContainer),
      c("On Error Container", colorScheme.onErrorContainer,
          colorScheme.errorContainer),
    ];

    final surfaceColors = [
      c("Surface", colorScheme.surface, colorScheme.onSurface),
      c("On Surface", colorScheme.onSurface, colorScheme.surface),
      c("Surface Variant", colorScheme.surfaceVariant,
          colorScheme.onSurfaceVariant),
      c("On Surface Variant", colorScheme.onSurfaceVariant,
          colorScheme.surfaceVariant),
      c("Inverse Surface", colorScheme.inverseSurface,
          colorScheme.onInverseSurface),
      c("On Inverse Surface", colorScheme.onInverseSurface,
          colorScheme.inverseSurface),
      c("Inverse Primary", colorScheme.inversePrimary, colorScheme.onPrimary),
    ];

    final containerColors = [
      c("Surface Container Lowest", colorScheme.surfaceContainerLowest,
          colorScheme.onSurface),
      c("Surface Container Low", colorScheme.surfaceContainerLow,
          colorScheme.onSurface),
      c("Surface Container", colorScheme.surfaceContainer,
          colorScheme.onSurface),
      c("Surface Container High", colorScheme.surfaceContainerHigh,
          colorScheme.onSurface),
      c("Surface Container Highest", colorScheme.surfaceContainerHighest,
          colorScheme.onSurface),
      c("Surface Bright", colorScheme.surfaceBright, colorScheme.onSurface),
      c("Surface Dim", colorScheme.surfaceDim, colorScheme.onSurface),
    ];

    final utilityColors = [
      c("Outline", colorScheme.outline, colorScheme.surface),
      c("Outline Variant", colorScheme.outlineVariant, colorScheme.onSurface),
      c("Scrim", colorScheme.scrim, Colors.white),
      c("Shadow", colorScheme.shadow, Colors.white),
      c("Surface Tint", colorScheme.surfaceTint, colorScheme.onPrimary),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      appBar: AppBar(
        title: const Text("カラーパレット"),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDynamicColorSection(context, state),
          const SizedBox(height: 24),
          _buildSection(context, "コアカラー", coreColors),
          const SizedBox(height: 24),
          _buildSection(context, "サーフェスカラー", surfaceColors),
          const SizedBox(height: 24),
          _buildSection(context, "コンテナカラー", containerColors),
          const SizedBox(height: 24),
          _buildSection(context, "ユーティリティカラー", utilityColors),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDynamicColorSection(BuildContext context, TimerState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text("設定",
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text("ダイナミックカラー(beta)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface)),
                subtitle: Text("OSのテーマカラーに合わせてアプリのカラーパレットを変更します",
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                value: state.useDynamicColor,
                onChanged: (value) {
                  state.toggleDynamicColor(value);
                },
                secondary: Icon(Icons.palette_outlined,
                    color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<(String, Color, Color)> colors) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title,
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < colors.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: colorScheme.surfaceContainerHigh),
                _buildColorRow(context, colors[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow(
      BuildContext context, (String, Color, Color) colorInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = colorInfo.$1;
    final color = colorInfo.$2;
    final hexCode =
        '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Google Sans Flex',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                    fontVariations: const [FontVariation('ROND', 100)],
                  ),
                ),
                Text(
                  hexCode,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
