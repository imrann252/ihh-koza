import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../models/notification_item.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';

/// 📣 Çağrılar Sayfası — Raporlama kısmı bulunmayan, sadece aktif afetler ve güncel çağrılar listesi
class CagrilarView extends StatefulWidget {
  const CagrilarView({super.key});

  @override
  State<CagrilarView> createState() => _CagrilarViewState();
}

class _CagrilarViewState extends State<CagrilarView> {
  // Mock acil çağrı verisi
  final List<Map<String, dynamic>> _afetCagrilari = [
    {
      'id': 'C001',
      'afetIsmi': 'Hatay Depremi Arama Kurtarma',
      'lider': 'Ahmet Yılmaz',
      'rol': 'Ekip Lideri • Bölge A-14',
      'mesaj': 'Deprem sonrası arama kurtarma operasyonu için acil gönüllü çağrısı — Sektör 4B, Sahra Hastanesi bölgesi.',
      'zaman': '15 dk önce',
      'tur': 'ACİL',
      'kabul': null,
    },
    {
      'id': 'C002',
      'afetIsmi': 'Kahramanmaraş Sel Afeti',
      'lider': 'Genel Merkez',
      'rol': 'İHH Operasyon Koordinasyon',
      'mesaj': 'Kahramanmaraş bölgesi için ek gönüllü ekibi oluşturuluyor. Müsait gönüllüler lütfen bildirim yapsın.',
      'zaman': '2 saat önce',
      'tur': 'DAVET',
      'kabul': null,
    },
  ];

  final List<Map<String, dynamic>> _gecmisAfetler = [
    {
      'id': 'G001',
      'afetIsmi': 'Antalya Orman Yangını',
      'rol': 'Lojistik Destek',
      'tarih': 'Ağustos 2024',
      'puan': 150,
    },
    {
      'id': 'G002',
      'afetIsmi': 'Kastamonu Sel Felaketi',
      'rol': 'Saha Gönüllüsü',
      'tarih': 'Haziran 2024',
      'puan': 120,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    
    // AppState'den gelen çağrıları da buraya yansıt
    final List<Map<String, dynamic>> combinedCalls = List.from(_afetCagrilari);
    for (var n in state.notifications.where((n) => n.type == NotificationType.alarmCall)) {
      if (!combinedCalls.any((c) => c['id'] == n.id)) {
        combinedCalls.add({
          'id': n.id,
          'afetIsmi': n.title.replaceAll('🚨 ', '').replaceAll('🔔 ', ''),
          'lider': 'Genel Merkez',
          'rol': 'Acil Operasyon Çağrısı',
          'mesaj': n.body,
          'zaman': n.timeLabel,
          'tur': 'ACİL',
          'kabul': null,
        });
      }
    }

    final activeDisasters = state.activeDisasters;
    final bekleyenler = combinedCalls.where((c) => c['kabul'] == null).toList();
    final yanitlananlar = combinedCalls.where((c) => c['kabul'] != null).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: KozaAppBar(
        title: 'ÇAĞRILAR',
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 26, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: const NotificationPanel(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Güncel Aktif Afetler
          if (activeDisasters.isNotEmpty) ...[
            _buildSectionLabel('Güncel Aktif Afetler', count: activeDisasters.length),
            const SizedBox(height: 10),
            ...activeDisasters.map((d) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sosRedLight,
                    child: Icon(Icons.warning_amber_rounded, color: AppColors.sosRed),
                  ),
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Konum: ${d.location} • Kritiklik: ${d.severity}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.sosRedLight, borderRadius: BorderRadius.circular(6)),
                    child: const Text('AKTİF', style: TextStyle(fontSize: 10, color: AppColors.sosRed, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],

          // 2. Bekleyen Çağrılar
          if (bekleyenler.isNotEmpty) ...[
            _buildSectionLabel('Bekleyen Çağrılar', count: bekleyenler.length, isUrgent: true),
            const SizedBox(height: 10),
            ...bekleyenler.map((c) => _buildAfetCallCard(c)),
            const SizedBox(height: 20),
          ],

          // 3. Yanıtlanan Çağrılar
          if (yanitlananlar.isNotEmpty) ...[
            _buildSectionLabel('Yanıtlanan Çağrılar'),
            const SizedBox(height: 10),
            ...yanitlananlar.map((c) => _buildAfetCallCard(c)),
            const SizedBox(height: 20),
          ],
          
          // 4. Eskiden Katıldığım Afetler
          _buildSectionLabel('Eskiden Katıldığım Afetler'),
          const SizedBox(height: 10),
          ..._gecmisAfetler.map((g) => _buildGecmisAfetCard(g)),

          // İstatistik
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('1.2k', 'AKTİF GÖNÜLLÜ', Icons.groups_outlined, AppColors.kozaGreen)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('48', 'BİTEN GÖREV', Icons.check_circle_outline, AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGecmisAfetCard(Map<String, dynamic> g) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.history, color: AppColors.kozaGreen)),
        title: Text(g['afetIsmi'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text("Rol: ${g['rol']} • ${g['tarih']}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.warningOrange.withAlpha(30), borderRadius: BorderRadius.circular(8)),
          child: Text("+${g['puan']} Puan", style: const TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildAfetCallCard(Map<String, dynamic> call) {
    final bool isPending = call['kabul'] == null;
    final bool isAccepted = call['kabul'] == true;
    final bool isUrgent = call['tur'] == 'ACİL';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: (isUrgent ? AppColors.sosRed : AppColors.kozaGreen).withAlpha(15), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Sol şerit
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isUrgent ? AppColors.sosRed : AppColors.infoBlue,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              // İçerik
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.person, color: AppColors.kozaGreen, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(call['afetIsmi'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(call['lider'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text(call['rol'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          // Durum badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPending ? (isUrgent ? AppColors.sosRedLight : AppColors.infoBlueBg) : (isAccepted ? AppColors.kozaGreenLight : AppColors.inputBg),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPending ? call['tur'] : (isAccepted ? 'KABUL EDİLDİ' : 'REDDEDİLDİ'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isPending ? (isUrgent ? AppColors.sosRed : AppColors.infoBlue) : (isAccepted ? AppColors.kozaGreen : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(call['mesaj'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 4),
                      Text(call['zaman'], style: const TextStyle(fontSize: 10, color: AppColors.textHint)),

                      // Butonlar (sadece bekleyenler için)
                      if (isPending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleCallResponse(call['id'], true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.kozaGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Kabul Et', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleCallResponse(call['id'], false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.divider),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Reddet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallResponse(String id, bool accepted) {
    setState(() {
      final idx = _afetCagrilari.indexWhere((c) => c['id'] == id);
      if (idx != -1) _afetCagrilari[idx]['kabul'] = accepted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accepted ? 'Çağrı kabul edildi. Lider bilgilendirildi.' : 'Çağrı reddedildi.'),
        backgroundColor: accepted ? AppColors.kozaGreen : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, {int? count, bool isUrgent = false}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.sosRed : AppColors.kozaGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color == AppColors.kozaGreen ? color : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: color != AppColors.kozaGreen ? Border.all(color: AppColors.divider) : null,
        boxShadow: color == AppColors.kozaGreen ? [BoxShadow(color: color.withAlpha(30), blurRadius: 12, offset: const Offset(0, 4))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color == AppColors.kozaGreen ? Colors.white : color, size: 26),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color == AppColors.kozaGreen ? Colors.white : color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: (color == AppColors.kozaGreen ? Colors.white : color).withAlpha(180))),
        ],
      ),
    );
  }
}
