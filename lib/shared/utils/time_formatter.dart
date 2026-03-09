class TimeFormatter {
  TimeFormatter._();

  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatMinutes(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    return '$minutes min';
  }

  static String formatMinutesShort(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    return '$minutes MIN';
  }

  static String formatMinutesLong(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    return '$minutes Minutes';
  }
}
