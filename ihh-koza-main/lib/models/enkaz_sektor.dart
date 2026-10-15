/// Backend Sector entity'sinin Flutter karşılığı.
/// Backend JSON yanıtı: { sectorId, name, riskLevel, geometryText, subSectors }
class EnkazSektor {
  final String id;
  final String sectorCode;
  final String name;
  final String riskLevel; // Kritik, CalismaVar, Temiz
  final String geometryText; // WKT format: POLYGON((...))
  final List<EnkazSektor> subSectors;

  EnkazSektor({
    required this.id,
    required this.sectorCode,
    required this.name,
    required this.riskLevel,
    required this.geometryText,
    this.subSectors = const [],
  });

  factory EnkazSektor.fromMap(Map<String, dynamic> map) {
    // Backend'deki Sector entity'si "sectorId" kullanıyor
    final sectorId = map['sectorId'] ?? map['sector_id'] ?? map['id'] ?? '';

    List<EnkazSektor> children = [];
    if (map['subSectors'] != null && map['subSectors'] is List) {
      children = (map['subSectors'] as List)
          .map((s) => EnkazSektor.fromMap(s as Map<String, dynamic>))
          .toList();
    }

    return EnkazSektor(
      id: sectorId,
      sectorCode: sectorId,
      name: map['name'] ?? '',
      riskLevel: map['riskLevel'] ?? map['risk_level'] ?? 'Temiz',
      geometryText: map['geometryText'] ?? map['geometry_text'] ?? '',
      subSectors: children,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectorId': id,
      'name': name,
      'riskLevel': riskLevel,
      'geometryText': geometryText,
    };
  }
}
