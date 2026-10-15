import 'dart:convert';
import 'dart:typed_data';

class FieldLog {
  final String id;
  final String sectorId;
  final DateTime timestamp;
  final Uint8List? audioBytes;
  final String encryptedHealthData;
  final String status;
  bool isSynced;

  FieldLog({
    required this.id,
    required this.sectorId,
    required this.timestamp,
    this.audioBytes,
    required this.encryptedHealthData,
    required this.status,
    this.isSynced = false,
  });

  factory FieldLog.fromMap(Map<String, dynamic> map) {
    Uint8List? bytes;
    final String? rawAudio = map['audio_bytes'];
    if (rawAudio != null && rawAudio.isNotEmpty) {
      try {
        bytes = base64Decode(rawAudio);
      } catch (e) {
        print("Error decoding Base64 audio: $e");
      }
    }
    return FieldLog(
      id: map['id'] ?? '',
      sectorId: map['sector_id'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      audioBytes: bytes,
      encryptedHealthData: map['health_data'] ?? '',
      status: map['status'] ?? 'Temiz',
      isSynced: map['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sector_id': sectorId,
      'timestamp': timestamp.toIso8601String(),
      'audio_bytes': audioBytes != null ? base64Encode(audioBytes!) : '',
      'health_data': encryptedHealthData,
      'status': status,
      'isSynced': isSynced,
    };
  }
}
