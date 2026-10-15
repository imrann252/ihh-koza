import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/enkaz_sektor.dart';
import 'hive_service.dart';
import '../state/app_state.dart';

class DataMuleService {
  final String baseUrl = AppConfig.backendUrl;

  /// POST /api/mule/sync - Pushes local offline logs to the server.
  Future<void> syncOfflineLogs() async {
    try {
      final List<Map<String, dynamic>> unsyncedLogs = HiveService.getUnsyncedLogs();

      if (unsyncedLogs.isEmpty) {
        print("ℹ️ Senkronize edilecek yeni log bulunamadı.");
        return;
      }

      print("📤 ${unsyncedLogs.length} adet log merkeze gönderiliyor...");

      final response = await http.post(
        Uri.parse('$baseUrl/api/mule/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(unsyncedLogs),
      );

      if (response.statusCode == 200) {
        print("✅ Senkronizasyon başarılı. Lokal loglar güncelleniyor...");
        for (var log in unsyncedLogs) {
          final String? id = log['id'];
          if (id != null) {
            await HiveService.markAsSynced(id);
          }
        }
        print("🎉 Tüm lokal loglar senkronize edildi olarak işaretlendi.");
      } else {
        throw HttpException("Sunucu hata döndürdü: ${response.statusCode} - ${response.body}");
      }
    } on SocketException catch (e) {
      print("⚠️ Ağ bağlantısı yok (Çevrimdışı saha modu): ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Senkronizasyon sırasında beklenmeyen hata: $e");
      rethrow;
    }
  }

  /// GET /api/mule/sectors - Fetches sector data from backend.
  Future<List<EnkazSektor>> getSectors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mule/sectors'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EnkazSektor.fromMap(json)).toList();
      } else {
        throw HttpException("Sektör verileri yüklenemedi: ${response.statusCode}");
      }
    } catch (e) {
      print("Sektörler çekilirken hata oluştu: $e");
      rethrow;
    }
  }
}
