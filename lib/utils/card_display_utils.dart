import 'package:intl/intl.dart';

/// Format a date string for display on Fitness/Wellness cards: date only, no time.
/// Accepts ISO strings (e.g. "2025-02-10T14:30:00.000Z") or date-only strings.
/// Returns a readable date like "10 Feb 2025" or the original string if parsing fails.
String formatCardDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '';
  final trimmed = dateStr.trim();
  final dt = DateTime.tryParse(trimmed);
  if (dt != null) {
    return DateFormat('d MMM yyyy').format(dt);
  }
  return trimmed;
}

/// Build a readable location string from a subscription Address object.
/// Prefers "Street, City, Country" from populated fields; falls back to addressLine1 or location.
String formatCardLocation(dynamic address) {
  if (address == null) return 'Location TBD';
  if (address is! Map) return address.toString().trim().isEmpty ? 'Location TBD' : address.toString();

  final Map<dynamic, dynamic> addr = address;
  final street = (addr['streetName'] ?? addr['address'] ?? addr['addressLine1'] ?? '').toString().trim();
  final cityVal = addr['city'];
  final countryVal = addr['country'];

  String city = '';
  if (cityVal is Map) {
    city = (cityVal['name'] ?? cityVal['city_name'] ?? cityVal['cityName'] ?? '').toString().trim();
  } else if (cityVal != null) {
    city = cityVal.toString().trim();
  }

  String country = '';
  if (countryVal is Map) {
    country = (countryVal['name'] ?? countryVal['country_name'] ?? countryVal['countryName'] ?? '').toString().trim();
  } else if (countryVal != null) {
    country = countryVal.toString().trim();
  }

  final parts = [street, city, country].where((s) => s.isNotEmpty).toList();
  if (parts.isNotEmpty) return parts.join(', ');
  final fallback = (addr['addressLine1'] ?? addr['location'] ?? '').toString().trim();
  return fallback.isEmpty ? 'Location TBD' : fallback;
}
