// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'state/timer_state.dart';
import 'theme/color_schemes.dart';
import 'theme/typography.dart';
import 'utils/time_formatter.dart';
import 'widgets/animated_mode_switcher.dart';
import 'widgets/bell_chip.dart';
import 'widgets/bell_edit_dialog.dart';
import 'widgets/expressive_section.dart';
import 'widgets/time_input_box.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: const PresentationTimerApp(),
    ),
  );
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
          // Use fromSeed to ensure all surface variants are generated correctly
          // harmonized() alone might not fill all surface container roles on some Android versions
          lightScheme = ColorScheme.fromSeed(
            seedColor: lightDynamic.primary,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: darkDynamic.primary,
            brightness: Brightness.dark,
          );
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
      displayLarge: getSmartTextStyle(baseStyle: base.displayLarge),
      displayMedium: getSmartTextStyle(baseStyle: base.displayMedium),
      displaySmall: getSmartTextStyle(baseStyle: base.displaySmall),
      headlineLarge: getSmartTextStyle(baseStyle: base.headlineLarge),
      headlineMedium: getSmartTextStyle(baseStyle: base.headlineMedium),
      headlineSmall: getSmartTextStyle(baseStyle: base.headlineSmall),
      titleLarge: getSmartTextStyle(baseStyle: base.titleLarge),
      titleMedium: getSmartTextStyle(baseStyle: base.titleMedium),
      titleSmall: getSmartTextStyle(baseStyle: base.titleSmall),
      bodyLarge: getSmartTextStyle(baseStyle: base.bodyLarge),
      bodyMedium: getSmartTextStyle(baseStyle: base.bodyMedium),
      bodySmall: getSmartTextStyle(baseStyle: base.bodySmall),
      labelLarge: getSmartTextStyle(baseStyle: base.labelLarge),
      labelMedium: getSmartTextStyle(baseStyle: base.labelMedium),
      labelSmall: getSmartTextStyle(baseStyle: base.labelSmall),
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    // Increase base font size to allow it to scale up in Expanded
    final timerFontSize = screenHeight * 0.40;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: Stack(
        children: [
          Column(
            children: [
              // Header (SafeArea top only)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedModeSwitcher(
                        currentMode: state.mode,
                        onModeChanged: (newMode) => state.toggleMode(newMode),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content (Expands to fill available space)
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
                                return BellChip(bell: bell);
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

                    // Huge Timer Display (Expanded to take max space)
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => state.toggleMode(
                              state.mode == 'timer' ? 'stopwatch' : 'timer'),
                          child: Hero(
                            tag: 'timer_text',
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  formatTime(state.displayTime),
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
                        ),
                      ),
                    ),

                    // Status Text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        state.mode == 'timer'
                            ? (state.displayTime < 0 ? '時間切れ' : '残り')
                            : (state.isOvertime ? '時間切れ' : '経過'),
                        style: TextStyle(
                          fontSize: 24,
                          color: state.isOvertime
                              ? colorScheme.error
                              : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Controls Area (Fixed at bottom)
              Container(
                color: colorScheme.surfaceContainer, // Match background
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          onPressed: state.reset,
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
                  ),
                ),
              ),
            ],
          ),

          // Settings Button (Absolute)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
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
            ),
          ),
        ],
      ),
    );
  }
}

// --- Sub Widgets ---

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

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceDim,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "設定",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                    children: [
                      // Appearance
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text("外観",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      ExpressiveSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
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
                                              onTap: () => state.setThemeMode(
                                                  ThemeMode.system),
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
                                              onTap: () => state.setThemeMode(
                                                  ThemeMode.light),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SwitchListTile(
                                title: const Text("ダイナミックカラー(beta)",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
                                                        color: colorScheme
                                                            .primary),
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
                        ],
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
                      ExpressiveSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("発表時間",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface)),
                                        Text("プレゼンの持ち時間",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: colorScheme
                                                    .onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        TimeInputBox(
                                          value: state.durationMin,
                                          onChanged: (v) =>
                                              state.updateDuration(
                                                  v, state.durationSec),
                                          label: "分",
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              child: Text(":",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorScheme
                                                          .onSurface)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text("",
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        TimeInputBox(
                                          value: state.durationSec,
                                          onChanged: (v) =>
                                              state.updateDuration(
                                                  state.durationMin, v),
                                          label: "秒",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                      ExpressiveSection(
                        children: [
                          ListTile(
                            leading: Icon(Icons.palette_outlined,
                                color: colorScheme.primary),
                            title: Text("カラーパレット一覧",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface)),
                            subtitle: Text("(デバッグ用)カラーパレットを表示",
                                style: TextStyle(color: colorScheme.onSurface)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: colorScheme.onSurfaceVariant),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ColorSchemePreviewScreen(),
                                ),
                              );
                            },
                          ),
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
      c("Surface Variant", colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant),
      c("On Surface Variant", colorScheme.onSurfaceVariant,
          colorScheme.surfaceContainerHighest),
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceDim,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "カラーパレット一覧",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicColorSection(BuildContext context, TimerState state) {
    final colorScheme = Theme.of(context).colorScheme;

    final WidgetStateProperty<Icon?> thumbIcon =
        WidgetStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text("設定",
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        ExpressiveSection(
          children: [
            SwitchListTile(
              title: Text("ダイナミックカラー(beta)",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              subtitle: Text(
                  "OSのテーマカラーに合わせてアプリのカラーパレットを変更します\nOSのテーマカラーを変更した場合は、アプリを再起動すると適用されます。",
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              value: state.useDynamicColor,
              onChanged: (value) {
                state.toggleDynamicColor(value);
              },
              secondary: Icon(Icons.palette_outlined,
                  color: colorScheme.onSurfaceVariant),
              thumbIcon: thumbIcon,
            ),
          ],
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
        ExpressiveSection(
          children: colors.map((c) => _buildColorRow(context, c)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorRow(
      BuildContext context, (String, Color, Color) colorInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = colorInfo.$1;
    final color = colorInfo.$2;
    // Remove alpha (first 2 chars) and keep 6 chars
    final hexCode =
        '#${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';

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
                    fontSize: 18,
                    color: colorScheme.onSurface,
                    fontVariations: const [FontVariation('ROND', 100)],
                  ),
                ),
                Text(
                  hexCode,
                  style: TextStyle(
                    fontFamily: 'Google Sans Flex',
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    fontVariations: const [FontVariation('ROND', 100)],
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
