import 'package:intl/intl.dart';

final NumberFormat usd = NumberFormat.currency(locale: 'en_US', symbol: r'$');

String formatCents(int cents) => usd.format(cents / 100);
