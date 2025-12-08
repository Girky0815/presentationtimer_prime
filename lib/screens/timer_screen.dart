import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/timer_state.dart';
import '../utils/time_formatter.dart';
import '../widgets/animated_mode_switcher.dart';
import '../widgets/bell_chip.dart';
import '../widgets/bell_edit_dialog.dart';
import 'settings_panel.dart';

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
