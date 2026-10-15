import 'package:latlong2/latlong.dart';

class WktParser {
  /// Parses a WKT POLYGON string into a List of [LatLng] objects.
  /// Example input: "POLYGON((29.0520 40.9850, 29.0560 40.9850, ...))"
  static List<LatLng> parsePolygon(String wkt) {
    final List<LatLng> points = [];
    try {
      final String cleanWkt = wkt.trim().toUpperCase();
      if (!cleanWkt.startsWith("POLYGON")) {
        return points;
      }

      // Extract the content inside double parentheses ((...))
      final int startIdx = cleanWkt.indexOf("((");
      final int endIdx = cleanWkt.lastIndexOf("))");
      if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) {
        return points;
      }

      final String coordinatesString = cleanWkt.substring(startIdx + 2, endIdx);
      final List<String> coordinatePairs = coordinatesString.split(",");

      for (var pair in coordinatePairs) {
        final trimmed = pair.trim();
        // Boşluktan böl — WKT formatı: longitude latitude
        final spaceIdx = trimmed.indexOf(' ');
        if (spaceIdx == -1) continue;

        final double? longitude = double.tryParse(trimmed.substring(0, spaceIdx).trim());
        final double? latitude = double.tryParse(trimmed.substring(spaceIdx + 1).trim());

        if (latitude != null && longitude != null) {
          points.add(LatLng(latitude, longitude));
        }
      }
    } catch (e) {
      print("Error parsing WKT Polygon: $e");
    }
    return points;
  }
}
