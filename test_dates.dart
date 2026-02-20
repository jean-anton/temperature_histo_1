import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('de', null);
  await initializeDateFormatting('fr', null);
  await initializeDateFormatting('es', null);

  final d1 = DateTime(2026, 3, 1);
  final d2 = DateTime(2026, 3, 2);

  print("==== EEEE d MMMM ====");
  for (final loc in ['en', 'de', 'fr', 'es']) {
     print("$loc: 1: ${DateFormat('EEEE d MMMM', loc).format(d1)}");
     print("$loc: 2: ${DateFormat('EEEE d MMMM', loc).format(d2)}");
  }

  print("==== yMMMMEEEEd ====");
  for (final loc in ['en', 'de', 'fr', 'es']) {
     print("$loc: 1: ${DateFormat.yMMMMEEEEd(loc).format(d1)}");
     print("$loc: 2: ${DateFormat.yMMMMEEEEd(loc).format(d2)}");
  }

  print("==== MMMMEEEEd ====");
  for (final loc in ['en', 'de', 'fr', 'es']) {
     print("$loc: 1: ${DateFormat.MMMMEEEEd(loc).format(d1)}");
     print("$loc: 2: ${DateFormat.MMMMEEEEd(loc).format(d2)}");
  }
}
