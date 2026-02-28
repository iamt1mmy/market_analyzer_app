import 'package:intl/intl.dart';

class AppFormatter {
  static String formatCurrency(double value, String currency) {
    return "${value.toStringAsFixed(2)} $currency";
  }

  static String formatDateRange(DateTime start, DateTime end) {
    final df = DateFormat('dd MMM yyyy');
    return "${df.format(start)} - ${df.format(end)}";
  }
}