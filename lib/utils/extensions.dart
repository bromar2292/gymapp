import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toFormattedString() {
    final currentTime = DateTime.now();
    final timeDifference = currentTime.difference(this);

    if (timeDifference.inDays == 0) {
      if (timeDifference.inHours == 0) {
        if (timeDifference.inMinutes == 0) {
          return 'Just now';
        }
        return '${timeDifference.inMinutes} minutes ago';
      }
      return '${timeDifference.inHours} hours ago';
    } else if (timeDifference.inDays == 1) {
      return 'Yesterday';
    } else if (timeDifference.inDays < 7) {
      return '${timeDifference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(this);
    }
  }

  String toDisplayDate() {
    return DateFormat('EEEE, MMMM d').format(this);
  }

  String toDisplayTime() {
    return DateFormat('h:mm a').format(this);
  }
}

extension DoubleX on double {
  String toWeightString() {
    if (this == toInt().toDouble()) {
      return toInt().toString();
    }
    return toStringAsFixed(1);
  }
}

extension StringX on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
