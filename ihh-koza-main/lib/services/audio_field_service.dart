import 'package:hive_flutter/hive_flutter.dart';

class AudioFieldService {
  final String _boxName = "offline_logs";

  // Kurtarmacının enkaz başında eldivenle basacağı o dev buton tetiklendiğinde çalışır
  Future<void> startFieldRecording() async {
    try {
      print("Lokal ses kaydı başladı (MOCKED)");
    } catch (e) {
      print("Kayıt başlatılamadı: $e");
    }
  }

  // Butondan elini çektiği an kaydı bitirir ve binary paket olarak lokal DB'ye mühürler
  Future<void> stopAndSaveFieldRecording(int sectorId, String riskStatus) async {
    try {
      final box = Hive.box(_boxName);

      // "Kim, nerede, ne durumda?" veri kuryesi paketi hazır
      final Map<String, dynamic> offlineLog = {
        'sector_id': sectorId,
        'timestamp': DateTime.now().toIso8601String(),
        'status': riskStatus, // "Kritik", "CalismaVar", "Temiz"
        'audio_bytes': [0, 1, 2, 3], // Mocked audio bytes
        'is_synced': false
      };

      await box.add(offlineLog);
      print("İhbar yerel NoSQL'e (Hive) mühürlendi (MOCKED). Toplam kayıt: ${box.length}");
    } catch (e) {
      print("Kayıt mühürlenirken lokal DB hatası: $e");
    }
  }
}