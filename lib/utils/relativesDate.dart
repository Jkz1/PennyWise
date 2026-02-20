import 'package:intl/intl.dart';

String getRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;

  if (difference == 0) return "Today, ${DateFormat('h:mm a').format(date)}";
  if (difference == 1) return "Yesterday";
  if (difference < 7) return DateFormat('EEEE').format(date); // e.g. "Tuesday"
  return DateFormat('MMM d, h:mm a').format(date); // e.g. "Oct 12"
}