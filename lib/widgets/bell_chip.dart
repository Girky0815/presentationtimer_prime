import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bell_config.dart';
import '../state/timer_state.dart';
import '../utils/time_formatter.dart';
import '../theme/typography.dart';
import 'bell_edit_dialog.dart';

class BellChip extends StatelessWidget {
  final BellConfig bell;

  const BellChip({super.key, required this.bell});

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
                    style: getSmartTextStyle(
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
                formatTime(bellTime).replaceAll('-', ''),
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
