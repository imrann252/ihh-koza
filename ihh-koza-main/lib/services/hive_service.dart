import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = 'field_logs_map_box';

  // Kutuyu güvenle başlat
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  // Sahada internet yokken ses dosyasını Base64'e çevirip diske mühürle
  static Future<void> saveLogOffline({
    required String sectorId,
    required String audioPath,
    required String status, // 'Kritik', 'CalismaVar', 'Temiz'
    int savedCount = 0,
    int injuredCount = 0,
    int deceasedCount = 0,
  }) async {
    final box = Hive.box(boxName);
    final String logId = "LOG_${DateTime.now().millisecondsSinceEpoch}";
    String base64Audio = "V0FWRVNJTVVMQVRJT05fQkFTRTY0X0RBVEE="; // Web için simüle edilmiş ses datası

    if (!kIsWeb) {
      final file = io.File(audioPath);
      if (await file.exists()) {
        List<int> audioBytes = await file.readAsBytes();
        base64Audio = base64Encode(audioBytes);
      }
    }

    final logPayload = {
      "id": logId,
      "sector_id": sectorId,
      "status": status,
      "audio_bytes": base64Audio,
      "health_data": "SECURE_KVKK_BLOOD_A_POSITIVE", // Şifreli paket şablonu
      "saved_count": savedCount,
      "injured_count": injuredCount,
      "deceased_count": deceasedCount,
      "timestamp": DateTime.now().toIso8601String(),
      "isSynced": false // Senkronizasyon durumu takibi
    };

    // ID'yi key yaparak diske çakıyoruz
    await box.put(logId, logPayload);
    print("💾 Veri telefona çakıldı! Sektör: $sectorId, Toplam Önbellek: ${box.length}");
  }

  // Gönderilmeyi bekleyen (isSynced = false) tüm paketleri toparla
  static List<Map<String, dynamic>> getUnsyncedLogs() {
    final box = Hive.box(boxName);
    final List<Map<String, dynamic>> unsyncedList = [];
    
    for (var key in box.keys) {
      final rawData = box.get(key);
      if (rawData != null) {
        final map = Map<String, dynamic>.from(rawData as Map);
        if (map['isSynced'] == false) {
          unsyncedList.add(map);
        }
      }
    }
    return unsyncedList;
  }

  // Backend kuryeyi onaylayınca o paketleri lokalde senkronize edildi olarak işaretle
  static Future<void> markAsSynced(String id) async {
    final box = Hive.box(boxName);
    final rawData = box.get(id);
    if (rawData != null) {
      final map = Map<String, dynamic>.from(rawData as Map);
      map['isSynced'] = true;
      await box.put(id, map); // Güncel halini geri yaz
    }
  }

  // Alternatif Güvenli Yol: Senkronizasyon bitince diski tamamen temizlemek istersen
  static Future<void> clearCache() async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}