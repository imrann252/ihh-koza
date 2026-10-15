import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';
import 'egitim_view.dart';

/// 👤 Profil Sayfası — Kullanıcı künyesi, kişisel bilgiler, eğitimler, rozetler
class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final profile = state.volunteerProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'PROFİLİM'),
      endDrawer: const NotificationPanel(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Bilgi Güncelleme Uyarısı ────────────────────────
            _buildUpdateBanner(),
            const SizedBox(height: 20),

            // ─── Kullanıcı Künyesi ───────────────────────────────
            _buildUserHeader(profile),
            const SizedBox(height: 24),

            // ─── Kişisel Bilgiler ────────────────────────────────
            _buildSectionTitle('Kişisel Bilgiler'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _InfoRow(label: 'YAŞ', value: '${profile.age}', icon: Icons.cake_outlined),
              _InfoRow(label: 'KAN GRUBU', value: profile.bloodType, icon: Icons.bloodtype_outlined, valueColor: AppColors.sosRed),
              _InfoRow(label: 'TELEFON', value: profile.phone, icon: Icons.phone_outlined),
              _InfoRow(label: 'ACİL DURUM KİŞİSİ', value: '${profile.emergencyContact} - ${profile.emergencyPhone}', icon: Icons.emergency_outlined, valueColor: AppColors.sosRed),
              _InfoRow(label: 'MESLEK', value: profile.profession, icon: Icons.work_outline),
              _InfoRow(label: 'ADRES', value: '${profile.city}, ${profile.district}\n${profile.address}', icon: Icons.location_on_outlined),
            ]),
            const SizedBox(height: 28),

            // ─── Saha Eğitimleri & Sertifikalar Yönlendirmesi ───
            _buildSectionTitle('Saha Eğitimleri Akademisi'),
            const SizedBox(height: 12),
            _buildEgitimNavCard(context, profile.certificates.length),
            const SizedBox(height: 24),

            _buildSectionTitle('Eğitim ve Sınav Geçmişi'),
            const SizedBox(height: 12),
            profile.examRecords.isEmpty
                ? const Text('Kayıtlı sınav bulunmuyor.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
                    children: profile.examRecords.map((e) {
                      final bool passed = e['status'] == 'Başarılı';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          leading: Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? AppColors.kozaGreen : AppColors.sosRed),
                          title: Text(e['name'] ?? 'Eğitim', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Sınav Puanı: ${e['score']}/100 • Durum: ${e['status']}'),
                          trailing: Text(e['date'] ?? ''),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            _buildSectionTitle('Kazanılan Sertifikalar'),
            const SizedBox(height: 12),
            profile.certificates.isEmpty
                ? const Text('Henüz kazanılmış bir sertifikanız yok.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
                    children: profile.certificates.map((c) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.verified, color: AppColors.kozaGreen),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Sertifika No: ${c.id} • Başarı: ${c.score.toInt()}%'),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildUpdateBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.infoBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.infoBlue.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoBlue, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bilgilerinizi güncel tutun. Saha atamalarında doğru veriler kritik önem taşır.',
              style: TextStyle(fontSize: 12, color: AppColors.infoBlue, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.infoBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Güncelle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(var profile) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kozaGreenLight,
              border: Border.all(color: AppColors.kozaGreen.withAlpha(60), width: 3),
            ),
            child: const Icon(Icons.person, size: 48, color: AppColors.kozaGreen),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Gönüllü ID: ${profile.id}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          // Dinamik Yetkinlik Puanı Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.kozaGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.kozaGreen.withAlpha(50), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Yetkinlik Puanı: ${profile.competencyScoreInt}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 18, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.valueColor ?? AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 66, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEgitimNavCard(BuildContext context, int certCount) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EgitimView())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withAlpha(120)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.school_outlined, color: AppColors.kozaGreen, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saha Eğitimleri Akademisi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('$certCount Sertifika Kazanıldı', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  }
}

// ─── Yardımcı Veri Sınıfları ──────────────────────────────────────────────
class _InfoRow {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, required this.icon, this.valueColor});
}
