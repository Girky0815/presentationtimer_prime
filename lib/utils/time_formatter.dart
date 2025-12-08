String formatTime(int totalSeconds) {
  final absSeconds = totalSeconds.abs();
  final m = (absSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (absSeconds % 60).toString().padLeft(2, '0');
  final sign = totalSeconds < 0 ? '-' : '';
  return "$sign$m:$s";
}
