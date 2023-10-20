import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  return DateFormat("d/M/y", "en_US").format(dateTime);
}