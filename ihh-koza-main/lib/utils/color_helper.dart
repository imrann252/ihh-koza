import 'package:flutter/material.dart';

class RiskColorHelper {
  /// Returns a Color with customized opacity based on the riskLevel.
  /// KIRMIZI -> Red with 50% opacity
  /// SARI -> Orange with 50% opacity
  /// TEMIZ -> Green with 50% opacity
  static Color getPolygonColor(String riskLevel, {double opacity = 0.5}) {
    final String cleanLevel = riskLevel.trim().toUpperCase();
    final int alpha = (opacity * 255).clamp(0, 255).toInt();

    switch (cleanLevel) {
      case 'KIRMIZI':
      case 'KRITIK':
        return Colors.red.withAlpha(alpha);
      case 'SARI':
      case 'CALISMAVAR':
        return Colors.orange.withAlpha(alpha);
      case 'TEMIZ':
      default:
        return Colors.green.withAlpha(alpha);
    }
  }
}
