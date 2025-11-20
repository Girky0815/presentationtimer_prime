import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

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
  primary: Color(0xFF03513e),
  onPrimary: Color(0xFFf3fff8),
  primaryContainer: Color(0xFFaef0d7),
  onPrimaryContainer: Color(0xFF002117),
  secondary: Color(0xFF344c43),
  onSecondary: Color(0xFFf3fff8),
  secondaryContainer: Color(0xFFcee9dc),
  onSecondaryContainer: Color(0xFF082018),
  tertiary: Color(0xFF0e4e58),
  onTertiary: Color(0xFFf7fdff),
  tertiaryContainer: Color(0xFFb4ecf8),
  onTertiaryContainer: Color(0xFF001f25),
  error: Color(0xFFba1a1a),
  onError: Color(0xFFffffff),
  errorContainer: Color(0xFFffdad6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFe8f3ed),
  onSurface: Color(0xFF181d1a),
  surfaceContainerHighest: Color(0xFFbec9c3),
  outline: Color(0xFF56615c),
  outlineVariant: Color(0xFFbec9c3),
  // Default fallbacks for others
  surfaceContainerLow: Color(0xFFf4fff8),
  surfaceContainer: Color(0xFFe8f3ed),
  inverseSurface: Color(0xFF29332e),
  onInverseSurface: Color(0xFFeff1ef),
  inversePrimary: Color(0xFF53dbc9),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF53dbc9),
  onPrimary: Color(0xFF003731),
  primaryContainer: Color(0xFF005048),
  onPrimaryContainer: Color(0xFF74f8e5),
  secondary: Color(0xFFb1ccb6), // Adjusted slightly for visibility
  onSecondary: Color(0xFF1c3531),
  secondaryContainer: Color(0xFF334b47),
  onSecondaryContainer: Color(0xFFcce8e2),
  tertiary: Color(0xFFadcae6),
  onTertiary: Color(0xFF153349),
  tertiaryContainer: Color(0xFF2d4961),
  onTertiaryContainer: Color(0xFFcce5ff),
  error: Color(0xFFffb4ab),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000a),
  onErrorContainer: Color(0xFFffdad6),
  surface: Color(0xFF101413),
  onSurface: Color(0xFFe0e3e1),
  surfaceContainerHighest: Color(0xFF323534),
  outline: Color(0xFF899390),
  outlineVariant: Color(0xFF3f4947),
  // Fallbacks
  surfaceContainerLow: Color(0xFF191c1b),
  surfaceContainer: Color(0xFF1d201f),
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
  bool isDarkMode = false;

  // Timer State
  Timer? _timer;
  bool isRunning = false;
  int elapsedSeconds = 0;
  String mode = 'stopwatch'; // 'timer' | 'stopwatch'
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  void toggleTheme() {
    isDarkMode = !isDarkMode;
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
    notifyListeners();
  }

  // Bells Logic
  void addBell() {
    int newId = (bells.isNotEmpty
            ? bells.map((b) => b.id).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    bells.add(BellConfig(id: newId, min: durationMin, sec: 0, count: 1));
    notifyListeners();
  }

  void removeBell(int id) {
    bells.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void updateBell(int id, {int? min, int? sec, int? count}) {
    var bell = bells.firstWhere((b) => b.id == id);
    if (min != null) bell.min = min;
    if (sec != null) bell.sec = sec;
    if (count != null) bell.count = count;
    notifyListeners();
  }

  Future<void> _checkBells() async {
    for (var bell in bells) {
      if (bell.totalSeconds == elapsedSeconds) {
        // Play sound 'bell.count' times
        // Note: Simple repetition logic.
        // For real assets, make sure 'assets/sounds/bell.mp3' exists.
        for (int i = 0; i < bell.count; i++) {
          await Future.delayed(Duration(milliseconds: i * 600));
          try {
            // Source must be in pubspec.yaml assets
            await _audioPlayer.play(AssetSource('sounds/bell.mp3'));
            // If no asset, print log
          } catch (e) {
            debugPrint(
                "Error playing sound: $e. Make sure assets/sounds/bell.mp3 exists.");
          }
        }
      }
    }
  }
}

// --- UI Components ---

class PresentationTimerApp extends StatelessWidget {
  const PresentationTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final timerState = context.watch<TimerState>();

    return MaterialApp(
      title: 'Presentation Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.quicksandTextTheme().apply(
          fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.quicksandTextTheme().apply(
          fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
        ),
      ),
      themeMode: timerState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          _ModeButton(
                            icon: Icons.timer_outlined,
                            label: "ストップウォッチ",
                            isSelected: state.mode == 'stopwatch',
                            onTap: () => state.toggleMode('stopwatch'),
                          ),
                          _ModeButton(
                            icon: Icons.timer,
                            label: "タイマー",
                            isSelected: state.mode == 'timer',
                            onTap: () => state.toggleMode('timer'),
                          ),
                        ],
                      ),
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
                              ...state.bells.map((bell) {
                                // Sort logic is better in state, but doing here for simplicity
                                return _BellChip(bell: bell);
                              }),
                              // Add Button
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    state.addBell();
                                    // Open edit immediately for the last added bell
                                    showDialog(
                                        context: context,
                                        builder: (c) => BellEditDialog(
                                            bellId: state.bells.last.id));
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
                      child: Text(
                        _formatTime(state.displayTime),
                        style: GoogleFonts.openSans(
                          fontSize:
                              120, // Responsive sizing requires LayoutBuilder, fixed for now
                          fontWeight: FontWeight.w400,
                          color: state.isOvertime
                              ? colorScheme.error
                              : colorScheme.onSurface,
                          height: 1.0,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    Text(
                      state.mode == 'timer'
                          ? (state.displayTime < 0 ? '超過' : '残り')
                          : (state.isOvertime ? '超過' : '経過'),
                      style: TextStyle(
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
    );
  }
}

// --- Sub Widgets ---

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton(
      {required this.icon,
      required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
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
    final isLastBell = state.bells.last.id == bell.id;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (c) => BellEditDialog(bellId: bell.id));
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
                    style: TextStyle(
                      fontSize: 12,
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
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: (isPassed && state.isRunning)
                      ? colorScheme.onTertiary
                      : colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

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
          color: colorScheme.surface,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.2)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("設定",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: colorScheme.onSurface)),
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
                    InkWell(
                      onTap: state.toggleTheme,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.2)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(state.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ダークモード",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: colorScheme.onSurface)),
                                  Text(state.isDarkMode ? "オン" : "オフ",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Switch(
                              value: state.isDarkMode,
                              onChanged: (v) => state.toggleTheme(),
                            ),
                          ],
                        ),
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
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("発表時間",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface)),
                              Text("プレゼンテーションの持ち時間",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          Row(
                            children: [
                              _TimeInputBox(
                                value: state.durationMin,
                                onChanged: (v) =>
                                    state.updateDuration(v, state.durationSec),
                                label: "分",
                              ),
                              const SizedBox(width: 8),
                              _TimeInputBox(
                                value: state.durationSec,
                                onChanged: (v) =>
                                    state.updateDuration(state.durationMin, v),
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
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "メイン画面のベルアイコンをタップして設定を変更できます。",
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
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
    );
  }
}

class BellEditDialog extends StatelessWidget {
  final int bellId;

  const BellEditDialog({super.key, required this.bellId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final bell = state.bells
        .firstWhere((b) => b.id == bellId, orElse: () => state.bells.first);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 320,
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
                    Text("ベル設定",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: colorScheme.onSurface)),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeInputBox(
                        value: bell.min,
                        onChanged: (v) => state.updateBell(bellId, min: v),
                        label: "分",
                        fontSize: 32,
                        padding: 12,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Text(":",
                            style: TextStyle(
                                fontSize: 24, color: colorScheme.onSurface)),
                      ),
                      _TimeInputBox(
                        value: bell.sec,
                        onChanged: (v) => state.updateBell(bellId, sec: v),
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
                children: [
                  Text("鳴動回数",
                      style: TextStyle(color: colorScheme.onSurface)),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => state.updateBell(bellId,
                            count: (bell.count > 1 ? bell.count - 1 : 1)),
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                          width: 32,
                          child: Center(
                              child: Text("${bell.count}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)))),
                      IconButton.filledTonal(
                        onPressed: () =>
                            state.updateBell(bellId, count: bell.count + 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      state.removeBell(bellId);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("削除"),
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          width: widget.fontSize * 2.5,
          padding: EdgeInsets.all(widget.padding),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
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
