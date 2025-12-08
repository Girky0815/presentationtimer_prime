import 'package:flutter/material.dart';

class AnimatedModeSwitcher extends StatefulWidget {
  final String currentMode;
  final Function(String) onModeChanged;

  const AnimatedModeSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<AnimatedModeSwitcher> createState() => _AnimatedModeSwitcherState();
}

class _AnimatedModeSwitcherState extends State<AnimatedModeSwitcher> {
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
