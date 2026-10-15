import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/koza_app_bar.dart';

/// 📄 Duyuru Sayfası — Acil çağrılar, bildirimler ve saha istatistikleri
class DuyuruView extends StatefulWidget {
  const DuyuruView({super.key});

  @override
  State<DuyuruView> createState() => _DuyuruViewState();
}

class _DuyuruViewState extends State<DuyuruView> {
  bool _showCallCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Acil Afet Çağrısı Kartı ─────────────────────────
            if (_showCallCard) _buildEmergencyCallCard(),
            if (_showCallCard) const SizedBox(height: 20),

            // ─── Geçmiş Duyurular ────────────────────────────────
            _buildSectionHeader('Son Duyurular', onTap: () {}),
            const SizedBox(height: 12),
            _buildAnnouncementCard(
              icon: Icons.school_outlined,
              iconColor: AppColors.infoBlue,
              iconBg: AppColors.infoBlueBg,
              title: 'Eğitim Semineri',
              subtitle: 'Temel afet müdahale eğitimi — 20 Temmuz Pazar',
              time: '2 saat önce',
            ),
            const SizedBox(height: 10),
            _buildAnnouncementCard(
              icon: Icons.badge_outlined,
              iconColor: AppColors.kozaGreen,
              iconBg: AppColors.kozaGreenLight,
              title: 'Yenilenen Görev Kartları',
              subtitle: 'Tüm gönüllülerin saha görev kartları güncellendi.',
              time: '1 gün önce',
            ),
            const SizedBox(height: 10),
            _buildAnnouncementCard(
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.warningOrange,
              iconBg: const Color(0xFFFFF3E0),
              title: 'Lojistik Dağıtım Planı',
              subtitle: 'Yeni malzeme dağıtım noktaları belirlendi.',
              time: '3 gün önce',
            ),
            const SizedBox(height: 24),

            // ─── İstatistik Kartları ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: '1.2k',
                    label: 'AKTİF GÖNÜLLÜ',
                    icon: Icons.groups_outlined,
                    color: AppColors.kozaGreen,
                    bgColor: AppColors.kozaGreenLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    value: '48',
                    label: 'BİTEN GÖREV',
                    icon: Icons.check_circle_outline,
                    color: AppColors.textSecondary,
                    bgColor: Colors.white,
                    hasBorder: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  WIDGET FABRİKALARI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Acil çağrı kartı — sol kenarı kırmızı şeritli
  Widget _buildEmergencyCallCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.sosRed.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Sol kırmızı şerit
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.sosRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // İçerik
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst başlık satırı
                    Row(
                      children: [
                        // Lider fotoğrafı
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.kozaGreenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: AppColors.kozaGreen, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ahmet Yılmaz',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Ekip Lideri • Bölge A-14',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ACİL badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sosRedLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ACİL',
                            style: TextStyle(
                              color: AppColors.sosRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Deprem sonrası arama kurtarma operasyonu için acil gönüllü çağrısı — Sektor 4B, Sahra Hastanesi bölgesi.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Butonlar
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _showCallCard = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Çağrı kabul edildi. Görev ekranına yönlendiriliyorsunuz.'),
                                  backgroundColor: AppColors.kozaGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kozaGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Kabul Et', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showCallCard = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reddet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Duyuru kartı (geçmiş duyurular listesi)
  Widget _buildAnnouncementCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ],
      ),
    );
  }

  /// İstatistik kartı
  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool hasBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: AppColors.divider) : null,
        boxShadow: hasBorder
            ? null
            : [BoxShadow(color: color.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withAlpha(180), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text('Tümünü Gör', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kozaGreen)),
          ),
      ],
    );
  }
}
