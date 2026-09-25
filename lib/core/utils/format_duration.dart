/// Formats [duration] as `m:ss`, or `h:mm:ss` when it is an hour or longer.
///
/// Uses Western digits, which is the norm for Arabic apps in the Gulf region.
String formatDuration(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  return hours > 0
      ? '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}'
      : '$minutes:${twoDigits(seconds)}';
}
