import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/volunteer_profile.dart';
import '../state/app_state.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';

/// 📚 Saha Eğitimleri Sayfası — 4 ana başlık, ilerleme, interaktif sınav, sertifika üretimi ve eğitim takvimi
class EgitimView extends StatefulWidget {
  const EgitimView({super.key});

  @override
  State<EgitimView> createState() => _EgitimViewState();
}

class _EgitimViewState extends State<EgitimView> {
  final List<_EgitimKart> _egitimler = [
    _EgitimKart(
      id: 'E001',
      baslik: 'Temel Afet Müdahale',
      egitmen: 'Dr. Mustafa Öztürk',
      sure: '8 Saat',
      ilerleme: 1.0,
      color: AppColors.infoBlue,
      icon: Icons.local_hospital_outlined,
      certNo: 'CERT-TAM-2024-001',
      sinifPuani: 92,
    ),
    _EgitimKart(
      id: 'E002',
      baslik: 'Arama Kurtarma Eğitimi',
      egitmen: 'Uzm. Serkan Aydın',
      sure: '16 Saat',
      ilerleme: 0.65,
      color: AppColors.warningOrange,
      icon: Icons.search_outlined,
    ),
    _EgitimKart(
      id: 'E003',
      baslik: 'İlk Yardım (İleri Seviye)',
      egitmen: 'Hem. Ayşe Korkmaz',
      sure: '12 Saat',
      ilerleme: 0.40,
      color: AppColors.sosRed,
      icon: Icons.favorite_border_rounded,
    ),
    _EgitimKart(
      id: 'E004',
      baslik: 'Lojistik Operasyonlar',
      egitmen: 'Loj. Uzm. Hasan Demir',
      sure: '6 Saat',
      ilerleme: 0.25,
      color: AppColors.kozaGreen,
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.kozaGreen,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  'assets/images/koza_pine_cone_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Text('EĞİTİM AKADEMİSİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Eğitimler & Sertifikalar'),
              Tab(text: 'Eğitim Takvimi'),
            ],
          ),
        ),
        endDrawer: const NotificationPanel(),
        body: TabBarView(
          children: [
            _buildProgramTab(),
            _buildCalendarTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramTab() {
    final state = AppStateProvider.of(context);
    final profile = state.volunteerProfile;
    
    // Filtrelenmiş sertifikalar profile'den okunacak
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Özet İstatistik ─────────────────────────────────
          _buildSummaryRow(),
          const SizedBox(height: 24),

          // ─── Eğitim Başlığı ───────────────────────────────────
          const Text('Eğitim Programları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // ─── Eğitim Kartları ──────────────────────────────────
          ..._egitimler.map((e) => _buildEgitimCard(e)),
          const SizedBox(height: 24),

          // ─── Sertifikalar ─────────────────────────────────────
          const Text('Kazanılan Sertifikalar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          profile.certificates.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Henüz kazanılmış bir sertifika yok.')),
                  ),
                )
              : Column(
                  children: profile.certificates.map((c) {
                    final egitim = _egitimler.firstWhere(
                      (e) => e.baslik == c.name,
                      orElse: () => _EgitimKart(id: 'E999', baslik: c.name, egitmen: 'Sistem', sure: '4 Saat', ilerleme: 1.0, color: AppColors.kozaGreen, icon: Icons.school),
                    );
                    return _buildCertCard(c, egitim.color);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final state = AppStateProvider.of(context);
    final trainings = state.publishedTrainings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Eğitim Başlangıç ve Bitiş Süreleri',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        trainings.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Takvimde planlanmış eğitim bulunmuyor.'),
              ))
            : Column(
                children: trainings.map((tr) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.kozaGreenLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.calendar_today, color: AppColors.kozaGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tr['baslik'] ?? 'Eğitim', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('Eğitmen: ${tr['egitmen']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BAŞLANGIÇ', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('${tr['tarih']} - ${tr['saat']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.textHint, size: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BİTİŞ', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('${tr['tarih']} - ${tr['bitisSaat']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('Toplam Süre: ${tr['sure']} Saat', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final tamamlanan = _egitimler.where((e) => e.ilerleme >= 1.0).length;
    final toplamSure = _egitimler.fold(0.0, (s, e) => s + double.parse(e.sure.split(' ')[0]) * e.ilerleme);
    final state = AppStateProvider.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.kozaGreen, AppColors.kozaGreenMuted]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSummaryItem('$tamamlanan/${_egitimler.length}', 'Tamamlanan', Icons.check_circle_outline)),
          _buildDivider(),
          Expanded(child: _buildSummaryItem('${toplamSure.toStringAsFixed(0)}s', 'Eğitim Süresi', Icons.timer_outlined)),
          _buildDivider(),
          Expanded(child: _buildSummaryItem('${state.volunteerProfile.certificates.length}', 'Sertifika', Icons.card_membership_outlined)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 4));
  }

  Widget _buildEgitimCard(_EgitimKart e) {
    final state = AppStateProvider.of(context);
    final hasCert = state.volunteerProfile.certificates.any((c) => c.name == e.baslik);
    final int percent = hasCert ? 100 : (e.ilerleme * 100).toInt();
    final bool tamamlandi = e.ilerleme >= 1.0 || hasCert;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tamamlandi ? e.color.withAlpha(80) : AppColors.divider.withAlpha(120)),
          boxShadow: tamamlandi ? [BoxShadow(color: e.color.withAlpha(15), blurRadius: 10, offset: const Offset(0, 3))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: e.color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                  child: Icon(e.icon, color: e.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(e.egitmen, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const Spacer(),
                          const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(e.sure, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (tamamlandi)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: e.color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                    child: Text('✓ TAM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: e.color)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('İlerleme', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('$percent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: e.color)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: hasCert ? 1.0 : e.ilerleme,
                minHeight: 7,
                backgroundColor: e.color.withAlpha(25),
                valueColor: AlwaysStoppedAnimation<Color>(e.color),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!tamamlandi) {
                    _handleEgitimKatil(e);
                  } else if (!hasCert) {
                    _handleSinavaGiris(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tamamlandi && hasCert ? AppColors.kozaGreenLight : e.color,
                  foregroundColor: tamamlandi && hasCert ? AppColors.kozaGreen : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  !tamamlandi ? 'Eğitime Katıl' : (!hasCert ? 'Sınava Giriş' : '✓ Sertifika Alındı'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertCard(Certificate c, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.card_membership_outlined, size: 24, color: AppColors.kozaGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('Sertifika No: ${c.id}', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Başarı Puanı: ${c.score.toInt()}/100 • Tarih: ${c.issueDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.verified_rounded, color: AppColors.kozaGreen, size: 26),
          ],
        ),
      ),
    );
  }

  void _handleEgitimKatil(_EgitimKart e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: e.color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
              child: Icon(e.icon, color: e.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(e.baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eğitmen: ${e.egitmen}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('Süre: ${e.sure}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                'Bu eğitime katılmak üzeresiniz. Eğitim tamamlandığında sınava girerek sertifikanızı alabilirsiniz.',
                style: TextStyle(fontSize: 12, color: AppColors.kozaGreen, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateIlerleme(e);
            },
            style: ElevatedButton.styleFrom(backgroundColor: e.color, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Başla', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _simulateIlerleme(_EgitimKart e) {
    setState(() {
      final idx = _egitimler.indexWhere((eg) => eg.id == e.id);
      if (idx != -1) {
        final yeniIlerleme = (_egitimler[idx].ilerleme + 0.25).clamp(0.0, 1.0);
        _egitimler[idx] = _egitimler[idx].copyWith(ilerleme: yeniIlerleme);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eğitim modülü tamamlandı! İlerleme güncellendi.'), backgroundColor: AppColors.kozaGreen),
        );
      }
    });
  }

  void _handleSinavaGiris(_EgitimKart e) {
    int currentQuestion = 0;
    int score = 0;
    final List<Map<String, dynamic>> questions = [
      {
        'q': 'Enkazda çalışırken ilk kural hangisidir?',
        'opts': ['Hızlıca enkaza girmek', 'Kendi can güvenliğini sağlamak', 'Sadece ses dinlemek', 'Enkazı hemen kazmak'],
        'ans': 1,
      },
      {
        'q': 'İlk yardımın ABC\'sinde B neyi ifade eder?',
        'opts': ['Bilinç kontrolü', 'Bak-dinle-hisset (Solunum)', 'Büyük kanamayı durdurmak', 'Boyun sabitlemek'],
        'ans': 1,
      },
      {
        'q': 'Telsiz konuşmasında konuşmanın bittiğini belirten ifade hangisidir?',
        'opts': ['Bitti', 'Anlaşıldı', 'Tamam', 'Kapatıyorum'],
        'ans': 2,
      }
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final q = questions[currentQuestion];
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.school, color: AppColors.kozaGreen),
                  const SizedBox(width: 10),
                  Text('Sınav: ${currentQuestion + 1}/${questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q['q'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q['opts'].length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.inputBg,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (index == q['ans']) {
                            score += 34; // Max ~100
                          }
                          if (currentQuestion < questions.length - 1) {
                            setStateDialog(() {
                              currentQuestion++;
                            });
                          } else {
                            Navigator.pop(ctx);
                            final finalScore = score.clamp(0, 100).toDouble();
                            final passed = finalScore >= 66; // En az 2 doğru
                            _saveExamAndCertToState(e, finalScore, passed);
                            
                            showDialog(
                              context: this.context,
                              builder: (c) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(passed ? '🎉 Tebrikler! Sınavı Geçtiniz' : '❌ Sınavda Başarısız Oldunuz'),
                                content: Text('Sınav puanınız: ${finalScore.toInt()}/100\n\n' + 
                                  (passed ? 'Sertifikanız profilinize eklenmiştir.' : 'Lütfen eğitimi tekrar gözden geçirin.')),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c), child: const Text('Kapat')),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text(q['opts'][index], style: const TextStyle(fontSize: 13)),
                      ),
                    );
                  }),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _saveExamAndCertToState(_EgitimKart e, double score, bool passed) {
    final state = AppStateProvider.of(context);
    final profile = state.volunteerProfile;
    
    // Sınav kaydı ekle
    final List<Map<String, dynamic>> updatedExams = List.from(profile.examRecords);
    updatedExams.add({
      'name': e.baslik,
      'score': score.toInt(),
      'date': '18/07/2026',
      'status': passed ? 'Başarılı' : 'Başarısız',
    });

    List<Certificate> updatedCerts = List.from(profile.certificates);
    if (passed) {
      final certNo = 'CERT-${e.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      updatedCerts.add(Certificate(
        id: certNo,
        name: e.baslik,
        issueDate: '18/07/2026',
        score: score,
      ));
      
      // Local state'i de güncelle
      final idx = _egitimler.indexWhere((eg) => eg.id == e.id);
      if (idx != -1) {
        setState(() {
          _egitimler[idx] = _egitimler[idx].copyWith(certNo: certNo, sinifPuani: score);
        });
      }
    }

    state.updateVolunteerProfile(profile.copyWith(
      certificates: updatedCerts,
      examRecords: updatedExams,
    ));
  }
}

// ─── Yardımcı Veri Sınıfı ─────────────────────────────────────────────────────
class _EgitimKart {
  final String id;
  final String baslik;
  final String egitmen;
  final String sure;
  final double ilerleme;
  final Color color;
  final IconData icon;
  final String? certNo;
  final double? sinifPuani;

  _EgitimKart({
    required this.id,
    required this.baslik,
    required this.egitmen,
    required this.sure,
    required this.ilerleme,
    required this.color,
    required this.icon,
    this.certNo,
    this.sinifPuani,
  });

  _EgitimKart copyWith({double? ilerleme, String? certNo, double? sinifPuani}) {
    return _EgitimKart(
      id: id,
      baslik: baslik,
      egitmen: egitmen,
      sure: sure,
      ilerleme: ilerleme ?? this.ilerleme,
      color: color,
      icon: icon,
      certNo: certNo ?? this.certNo,
      sinifPuani: sinifPuani ?? this.sinifPuani,
    );
  }
}
