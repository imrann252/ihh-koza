import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/sync_service.dart';
import '../state/app_state.dart';

class MuleRecordScreen extends StatefulWidget {
  const MuleRecordScreen({Key? key}) : super(key: key);

  @override
  State<MuleRecordScreen> createState() => _MuleRecordScreenState();
}

class _MuleRecordScreenState extends State<MuleRecordScreen> {
  bool _isRecording = false;
  bool _isSyncing = false;
  String _selectedSector = "ENKAZ-A1"; // H2 veritabanından gelen aktif sektör

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Kaydı Durdur ve Yerel DB'ye Yaz (Mock)
      final path = 'mock_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await HiveService.saveLogOffline(
        sectorId: _selectedSector,
        audioPath: path,
        status: "Kritik", // Butona basıldıysa durum kritiktir
      );
      print("Lokal veri paketi mühürlendi, merkeze aktarılmaya hazır");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💾 Lokal veri paketi mühürlendi, merkeze aktarılmaya hazır"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isRecording = false);
    } else {
      // Kaydı Başlat (Mock)
      setState(() => _isRecording = true);
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    try {
      await SyncService().flushLogsToBackend();
      if (mounted) {
        AppStateProvider.of(context).markMessagesAsSent();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Senkronizasyon Başarılı! Tüm veriler merkeze aktarıldı."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Bağlantı hatası: Sunucuya erişilemiyor (Saha çevrimdışı). Hata: $e"),
          backgroundColor: Colors.orange[800],
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Karanlık tema arka planı
      appBar: AppBar(
        title: const Text("İHH KOZA - Saha Log Girişi"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE65100), // Afet Turuncusu
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sektör Seçim Alanı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Aktif Çalışma Sektörü:",
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSector,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "ENKAZ-A1", child: Text("Enkaz A1 Sektörü (Marmara)")),
                      DropdownMenuItem(value: "ENKAZ-A2", child: Text("Enkaz A2 Sektörü")),
                    ],
                    onChanged: (val) => setState(() => _selectedSector = val!),
                  ),
                ),
              ],
            ),

            // ELDİVENLE BASILABİLECEK DEV MİKROFON BUTONU
            Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red[700] : const Color(0xFFE65100),
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording ? Colors.red.withAlpha(128) : const Color(0xFFE65100).withAlpha(77),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecording ? "SES KAYDEDİLİYOR...\nDURDURMAK İÇİN DOKUN" : "SESLİ RAPOR ALMAK İÇİN\nBUTONA BASIN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isRecording ? Colors.red[400] : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // SENKRONİZASYON BUTONU
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _handleSync,
              icon: _isSyncing 
                ? const SizedBox(
                    width: 24, 
                    height: 24, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload, size: 28),
              label: Text(
                _isSyncing ? "Aktarılıyor..." : "Senkronize Et (Merkeze Aktar)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF), // Dikkat çekici mavi renk
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
