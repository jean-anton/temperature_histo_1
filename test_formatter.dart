import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

String formatLocalizedDate(DateTime date, String locale, {bool includeYear = true, bool includeTime = false}) {
    String formatted;
    if (includeYear) {
      if (includeTime) {
        formatted = DateFormat.yMMMMEEEEd(locale).add_Hm().format(date);
      } else {
        formatted = DateFormat.yMMMMEEEEd(locale).format(date);
      }
    } else {
      if (includeTime) {
        formatted = DateFormat.MMMMEEEEd(locale).add_Hm().format(date);
      } else {
        formatted = DateFormat.MMMMEEEEd(locale).format(date);
      }
    }
    
    if (locale.startsWith('fr') && date.day == 1) {
       formatted = formatted.replaceFirst(' 1 ', ' 1er ');
    }
    
    return formatted.isNotEmpty ? formatted[0].toUpperCase() + formatted.substring(1) : formatted;
}

void main() async {
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('de', null);
  await initializeDateFormatting('fr', null);
  await initializeDateFormatting('es', null);

  final d1 = DateTime(2026, 3, 1, 14, 30);
  final d2 = DateTime(2026, 3, 2, 14, 30);

  for (final loc in ['en', 'de', 'fr', 'es']) {
     print("$loc d1 with year: ${formatLocalizedDate(d1, loc)}");
     print("$loc d2 with year: ${formatLocalizedDate(d2, loc)}");
     print("$loc d2 with time: ${formatLocalizedDate(d2, loc, includeTime: true)}");
  }

}
