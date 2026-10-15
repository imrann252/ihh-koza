import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/il_listesi.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';
import '../widgets/custom_charts.dart';
import '../state/app_state.dart';

class HqScreen extends StatefulWidget {
  const HqScreen({super.key});

  @override
  State<HqScreen> createState() => _HqScreenState();
}

class _HqScreenState extends State<HqScreen> with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0; // Starts on Raporlar tab
  late TabController _reportsTabController;

  // ── State for Afet Tanımlama tab ──────────────────────────────────────────
  String _selectedCategory = 'Enkazda Arama Kurtarma';
  final TextEditingController _locationController = TextEditingController();
  String _selectedSeverity = 'Ağır';

  // ── State for Ekipler tab (Bölgesel Filtreleme) ───────────────────────────
  String _filterCity = 'Tümü';
  String _filterDistrict = 'Tümü';
  final Map<String, List<String>> _cityDistricts = {
    'Tümü': ['Tümü'],
    'Hatay': ['Tümü', 'Antakya', 'Kırıkhan', 'Defne', 'İskenderun'],
    'Kahramanmaraş': ['Tümü', 'Onikişubat', 'Dulkadiroğlu', 'Elbistan'],
    'Adıyaman': ['Tümü', 'Merkez', 'Kahta', 'Besni'],
  };

  // ── State for Eğitim Tanımlama tab ────────────────────────────────────────
  String _selectedTrainingCategory = 'Enkaz';
  final TextEditingController _trainingDateController = TextEditingController();
  final TextEditingController _trainingTimeController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reportsTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _reportsTabController.dispose();
    _locationController.dispose();
    _trainingDateController.dispose();
    _trainingTimeController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showMudahaleEdilenBolgelerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_city, color: AppColors.kozaGreen),
            SizedBox(width: 8),
            Text('Müdahale Edilen Bölgeler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Hatay Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Defne, Antakya, Kırıkhan - 12 Sektör'),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Kahramanmaraş Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Elbistan, Onikişubat - 8 Sektör'),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Adıyaman Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Merkez, Gölbaşı - 6 Sektör'),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Malatya Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Yeşilyurt, Battalgazi - 5 Sektör'),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Antalya Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Manavgat - 4 Sektör'),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.location_on, color: AppColors.kozaGreen)),
                title: Text('Kastamonu Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Bozkurt - 3 Sektör'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))
        ],
      ),
    );
  }

  void _showRegionVolunteersDetail(String regionName, List<Map<String, dynamic>> volunteers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.badge, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('$regionName - Gönüllü Detayları', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final vol = volunteers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text(vol['name'].substring(0, 1), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(vol['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("${vol['specialty']} • Kan: ${vol['bloodType']}", style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.info_outline, size: 18, color: Colors.deepPurple),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text("${vol['name']} Detaylı Profili"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Uzmanlık / Rol: ${vol['specialty']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text("Kan Grubu: ${vol['bloodType']}"),
                            Text("Telefon: ${vol['phone']}"),
                            Text("Eğitim Seviyesi: ${vol['education']}"),
                            const SizedBox(height: 10),
                            const Text("Sertifikalar ve Yetkinlikler:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            ...List<String>.from(vol['certificates']).map((cert) => Text("• $cert")),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Kapat")),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Geri'))
        ],
      ),
    );
  }

  void _showPieChartCategoryDetails(String categoryLabel, double totalValue) {
    List<Map<String, String>> details = [];
    if (categoryLabel == 'Enkaz') {
      details = [
        {'bolge': 'Hatay Defne', 'tarih': '06.02.2023', 'bilanco': '24 Sağ Kurtarılan, 15 Yaralı, 2 Vefat'},
        {'bolge': 'K.Maraş Pazarcık', 'tarih': '06.02.2023', 'bilanco': '18 Sağ Kurtarılan, 32 Yaralı, 5 Vefat'},
        {'bolge': 'Adıyaman Gölbaşı', 'tarih': '08.02.2023', 'bilanco': '12 Sağ Kurtarılan, 8 Yaralı, 1 Vefat'},
        {'bolge': 'İzmir Seferihisar', 'tarih': '30.10.2020', 'bilanco': '9 Sağ Kurtarılan, 4 Yaralı, 0 Vefat'},
      ];
    } else if (categoryLabel == 'Yangın') {
      details = [
        {'bolge': 'Antalya Manavgat', 'tarih': '28.07.2021', 'bilanco': '2500 Hektar Söndürüldü, 0 Can Kaybı'},
        {'bolge': 'Muğla Marmaris', 'tarih': '21.06.2022', 'bilanco': '1200 Hektar Kontrol Altında, 1 Yaralı'},
        {'bolge': 'Çanakkale Gelibolu', 'tarih': '15.08.2024', 'bilanco': '400 Hektar Kontrol Altında'},
      ];
    } else if (categoryLabel == 'Sel') {
      details = [
        {'bolge': 'Kastamonu Bozkurt', 'tarih': '11.08.2021', 'bilanco': '85 Vatandaş Tahliye Edildi, 3 Kurtarma'},
        {'bolge': 'Sinop Ayancık', 'tarih': '11.08.2021', 'bilanco': '45 Vatandaş Tahliye Edildi'},
        {'bolge': 'Giresun Dereli', 'tarih': '22.08.2020', 'bilanco': '30 İş Yeri Temizlendi, 12 Tahliye'},
      ];
    } else { // Doğa
      details = [
        {'bolge': 'Rize Kaçkar Dağları', 'tarih': '14.03.2024', 'bilanco': '2 Kayıp Dağcı Sağ Kurtarıldı'},
        {'bolge': 'Van Bahçesaray', 'tarih': '04.02.2020', 'bilanco': 'Çığ Arama Kurtarma Tamamlandı'},
        {'bolge': 'Kocaeli Kartepe', 'tarih': '10.01.2025', 'bilanco': 'Kayıp 4 Kişilik Öğrenci Ekibi Bulundu'},
      ];
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.pie_chart, color: AppColors.kozaGreen),
            const SizedBox(width: 8),
            Text('$categoryLabel - Müdahale Detayları', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$categoryLabel kategorisinde toplam ${totalValue.toInt()} afete müdahale edilmiştir.', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Müdahale Geçmişi Bilançoları:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final item = details[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(item['bolge']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.kozaGreenDark))),
                                Text(item['tarih']!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Bilanço: ${item['bilanco']!}", style: const TextStyle(fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))
        ],
      ),
    );
  }


  // ─── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'KOZA - GENEL MERKEZ'),
      endDrawer: const NotificationPanel(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppColors.kozaGreen, size: 16),
                SizedBox(width: 8),
                Text(
                  "GİRİŞ YAPAN: GENEL MERKEZ YÖNETİCİSİ",
                  style: TextStyle(color: AppColors.kozaGreen, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.kozaGreen,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Raporlar'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Afet Tanımlama'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Ekipler'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Eğitim Tanımlama'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0: return _buildReportsTab();
      case 1: return _buildDisasterManagementTab();
      case 2: return _buildTeamsTab();
      case 3: return _buildTrainingTab();
      default: return const SizedBox();
    }
  }

  // ─── 1. SEKME: RAPORLAR ──────────────────────────────────────────────────
  Widget _buildReportsTab() {
    return Column(
      children: [
        TabBar(
          controller: _reportsTabController,
          labelColor: AppColors.kozaGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.kozaGreen,
          tabs: const [Tab(text: "Anlık Saha Raporları"), Tab(text: "Dönemsel Analitikler")],
        ),
        Expanded(
          child: TabBarView(
            controller: _reportsTabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLiveReportCard(
                    title: "ENKAZ-A1 Sektör Raporu",
                    location: "Hatay / Kırıkhan",
                    reporter: "Hatay İl Başkanı",
                    time: "10 Dakika Önce",
                    status: "Kritik",
                    content: "Enkaz altından termal görüntü ve ses izleri alındı. Ek donanım talep ediliyor.",
                  ),
                  const SizedBox(height: 12),
                  _buildLiveReportCard(
                    title: "B2 Sektörü Arama Sonu",
                    location: "Hatay / Antakya",
                    reporter: "Hatay İl Başkanı",
                    time: "3 Saat Önce",
                    status: "Taraması Bitenler",
                    content: "Belirtilen enkaz bölgesindeki tarama tamamlanarak risk sonlandırıldı.",
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("STRATEJİK GÖSTERGELER (KPI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showMudahaleEdilenBolgelerDialog,
                          child: _buildKpiCard("Müdahale Bölgesi", "48 Bölge", Icons.work_history, AppColors.kozaGreen),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.map, color: Colors.deepPurple),
                                    SizedBox(width: 8),
                                    Text('Aktif Gönüllü Bölgesel Dağılımı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text('Hatay Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('Tıklayıp Gönüllü Detaylarına Ulaşın', style: TextStyle(fontSize: 10)),
                                      trailing: const Text('450 Gönüllü', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _showRegionVolunteersDetail('Hatay Bölgesi', [
                                          {'name': 'Ahmet Yılmaz', 'specialty': 'Arama Kurtarma', 'bloodType': 'A Rh+', 'phone': '0532 111 22 33', 'education': 'AFAD Temel', 'certificates': ['AFAD Temel', 'Enkaz Arama Kurtarma']},
                                          {'name': 'Ayşe Kaya', 'specialty': 'Lojistik', 'bloodType': 'B Rh+', 'phone': '0543 222 33 44', 'education': 'Lojistik Operasyon', 'certificates': ['Saha Lojistiği', 'Depo Yönetimi']},
                                          {'name': 'Fatma Şahin', 'specialty': 'İlk Yardım', 'bloodType': '0 Rh+', 'phone': '0555 333 44 55', 'education': 'Sağlık Hizmetleri', 'certificates': ['İleri İlk Yardım', 'Travma Müdahale']},
                                        ]);
                                      },
                                    ),
                                    const Divider(),
                                    ListTile(
                                      title: const Text('Kahramanmaraş Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('Tıklayıp Gönüllü Detaylarına Ulaşın', style: TextStyle(fontSize: 10)),
                                      trailing: const Text('320 Gönüllü', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _showRegionVolunteersDetail('Kahramanmaraş Bölgesi', [
                                          {'name': 'Mehmet Demir', 'specialty': 'Haberleşme', 'bloodType': 'AB Rh-', 'phone': '0533 444 55 66', 'education': 'Telsiz Operatörü', 'certificates': ['Amatör Telsizcilik', 'Kriz İletişimi']},
                                          {'name': 'Caner Yıldız', 'specialty': 'Arama Kurtarma', 'bloodType': 'A Rh-', 'phone': '0544 555 66 77', 'education': 'Doğa Arama Kurtarma', 'certificates': ['Dağcılık', 'Kış Şartlarında Arama']},
                                        ]);
                                      },
                                    ),
                                    const Divider(),
                                    ListTile(
                                      title: const Text('Adıyaman Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('Tıklayıp Gönüllü Detaylarına Ulaşın', style: TextStyle(fontSize: 10)),
                                      trailing: const Text('230 Gönüllü', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _showRegionVolunteersDetail('Adıyaman Bölgesi', [
                                          {'name': 'Zeynep Çelik', 'specialty': 'Psikososyal Destek', 'bloodType': 'B Rh-', 'phone': '0505 666 77 88', 'education': 'Psikoloji', 'certificates': ['Çocuk Psikolojisi', 'Afet Psikolojisi']},
                                          {'name': 'Tarık Öztürk', 'specialty': 'Barınma Kurulumu', 'bloodType': '0 Rh-', 'phone': '0553 777 88 99', 'education': 'Çadır Kent Yönetimi', 'certificates': ['Barınma Planlama', 'Çadır Kurulum']},
                                        ]);
                                      },
                                    ),
                                    const Divider(),
                                    ListTile(
                                      title: const Text('Malatya Bölgesi', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('Tıklayıp Gönüllü Detaylarına Ulaşın', style: TextStyle(fontSize: 10)),
                                      trailing: const Text('200 Gönüllü', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _showRegionVolunteersDetail('Malatya Bölgesi', [
                                          {'name': 'Emre Kaya', 'specialty': 'Güvenlik', 'bloodType': 'A Rh+', 'phone': '0536 888 99 00', 'education': 'Güvenlik Protokolü', 'certificates': ['Saha Güvenliği', 'Tahliye Koordinasyonu']},
                                          {'name': 'Sevgi Demir', 'specialty': 'Sosyal Market', 'bloodType': 'AB Rh+', 'phone': '0542 999 00 11', 'education': 'Sosyal Yardım Koordinatörü', 'certificates': ['İnsani Yardım Dağıtımı']},
                                        ]);
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))
                                ],
                              ),
                            );
                          },
                          child: _buildKpiCard("Aktif Gönüllü", "1.2k Kişi", Icons.groups, Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text("Toplam Müdahale Edilen Afet Dağılımı (4 Kategori)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                    child: KozaPieChart(
                      centerLabel: 'Toplam',
                      centerValue: '85',
                      onSliceTap: (d) => _showPieChartCategoryDetails(d.label, d.value),
                      data: const [
                        PieChartData(label: 'Enkaz', value: 45, color: AppColors.kozaGreen),
                        PieChartData(label: 'Yangın', value: 15, color: AppColors.warningOrange),
                        PieChartData(label: 'Sel', value: 12, color: AppColors.infoBlue),
                        PieChartData(label: 'Doğa', value: 13, color: Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveReportCard({required String title, required String location, required String reporter, required String time, required String status, required String content}) {
    final isCritical = status.contains('Kritik');
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.report_problem, color: isCritical ? AppColors.sosRed : AppColors.kozaGreen),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konum: $location', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Raporlayan: $reporter', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('Süre: $time', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                const Divider(height: 20),
                Text(content, style: const TextStyle(height: 1.5, fontSize: 14)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCritical ? AppColors.sosRedLight : AppColors.kozaGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: isCritical ? AppColors.sosRed : AppColors.kozaGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCritical ? 'Kritik durum. Destek ekipleri çağrıldı.' : 'Durum kontrol altında, tarama sürüyor.',
                          style: TextStyle(color: isCritical ? AppColors.sosRed : AppColors.kozaGreen, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
            ],
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCritical ? AppColors.sosRedLight : AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCritical ? AppColors.sosRed : AppColors.kozaGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  Text(time, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              Text(content, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
              const Divider(height: 20),
              Row(
                children: [
                  const CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12)),
                  const SizedBox(width: 8),
                  Text("Raporlayan: $reporter", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── 2. SEKME: AFET TANIMLAMA & GÖREV ÇAĞRISI ────────────────────────────
  Widget _buildDisasterManagementTab() {
    final state = AppStateProvider.of(context);
    final disastersList = state.activeDisasters;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("YENİ AKTİF AFET BÖLGESİ TANIMLA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        const Text("Afet Kategorisi Seçin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Enkazda Arama Kurtarma', 'Doğada Arama Kurtarma', 'Suda Arama Kurtarma', 'Orman Yangını'].map((cat) {
            final isSelected = _selectedCategory == cat;
            return ChoiceChip(
              label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
              selected: isSelected,
              selectedColor: AppColors.kozaGreen,
              onSelected: (selected) { if (selected) setState(() => _selectedCategory = cat); },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        const Text("Afet Gerçekleşen Bölge / Konum (İl)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: TurkeyIlListesi.iller.contains(_locationController.text) ? _locationController.text : TurkeyIlListesi.iller.first,
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          items: TurkeyIlListesi.iller.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
          onChanged: (v) { if (v != null) setState(() => _locationController.text = v); },
        ),
        const SizedBox(height: 16),

        const Text("Afet Boyutu (Kritik Seviye)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSeverity,
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          items: ['Hafif', 'Orta', 'Ağır', 'Katastrofik'].map((sev) => DropdownMenuItem(value: sev, child: Text(sev))).toList(),
          onChanged: (v) { if (v != null) setState(() => _selectedSeverity = v); },
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final loc = _locationController.text.isEmpty ? TurkeyIlListesi.iller.first : _locationController.text;
              state.startDisaster(
                category: _selectedCategory,
                location: loc,
                severity: _selectedSeverity,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$loc bölgesinde $_selectedSeverity seviyeli $_selectedCategory ilan edildi! Çevre illerden ekiplere çağrı yollandı.'),
                  backgroundColor: AppColors.sosRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
            child: const Text("Afet Başlat ve Çağrı Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 28),
        const Text("GÜNCEL AKTİF AFETLER VE DURUM TAKİBİ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        disastersList.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Aktif afet kaydı bulunmamaktadır.'),
              ))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: disastersList.length,
                itemBuilder: (context, index) {
                  final disaster = disastersList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("${disaster.location} - ${disaster.severity} ${disaster.category}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.kozaGreenDark))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.sosRedLight, borderRadius: BorderRadius.circular(6)),
                                child: const Text("Aktif", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.sosRed)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Sağ, yaralı ve vefat durum takibi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.kozaGreen, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, savedDelta: -1),
                                      ),
                                      Text(disaster.savedCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.kozaGreenDark)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.kozaGreen, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, savedDelta: 1),
                                      ),
                                    ],
                                  ),
                                  const Text('Sağ Kurtarılan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, injuredDelta: -1),
                                      ),
                                      Text(disaster.injuredCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, injuredDelta: 1),
                                      ),
                                    ],
                                  ),
                                  const Text('Yaralı', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, deceasedDelta: -1),
                                      ),
                                      Text(disaster.deceasedCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.red, size: 20),
                                        onPressed: () => state.updateDisasterStats(disaster.id, deceasedDelta: 1),
                                      ),
                                    ],
                                  ),
                                  const Text('Vefat', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Text("Görevlendirilen Ekipler", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          disaster.assignedTeams.isEmpty
                              ? const Text('Görevli ekip bulunmamaktadır.', style: TextStyle(fontSize: 12, color: AppColors.textHint))
                              : Column(
                                  children: disaster.assignedTeams.map((team) {
                                    return ExpansionTile(
                                      iconColor: AppColors.kozaGreen,
                                      tilePadding: EdgeInsets.zero,
                                      title: Text("Lider: ${team.leaderName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      subtitle: Text("Sektör: ${team.sector} • Mesai: ${team.workHours} Saat", style: const TextStyle(fontSize: 11)),
                                      children: team.volunteers.map((vol) {
                                        return ListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets.only(left: 16),
                                          title: Text(vol.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          subtitle: Text("Sektör/Rol: ${vol.specialty} • Sağlık: ${vol.healthStatus}", style: const TextStyle(fontSize: 11)),
                                        );
                                      }).toList(),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  // ─── 3. SEKME: EKİPLER VE BÖLGESEL FİLTRELEME ─────────────────────────────
  Widget _buildTeamsTab() {
    final state = AppStateProvider.of(context);
    final List<HqTeamInfo> filteredTeams = state.allTeams.where((team) {
      final cityMatch = _filterCity == 'Tümü' || team.cityName == _filterCity;
      final districtMatch = _filterDistrict == 'Tümü' || team.districtName == _filterDistrict;
      return cityMatch && districtMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("EKİPLER VE BÖLGESEL FİLTRELEME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("İl Seçin", style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterCity,
                          isExpanded: true,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _filterCity = v;
                                _filterDistrict = 'Tümü'; 
                              });
                            }
                          },
                          items: ['Tümü', ...TurkeyIlListesi.iller].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("İlçe Seçin", style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterDistrict,
                          isExpanded: true,
                          onChanged: (v) {
                            if (v != null) setState(() => _filterDistrict = v);
                          },
                          items: (_cityDistricts[_filterCity] ?? ['Tümü']).map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text("Listelenen Ekip Sayısı: ${filteredTeams.length}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),

          Expanded(
            child: filteredTeams.isEmpty
                ? const Center(child: Text("Filtreye uygun kayıt bulunamadı."))
                : ListView.builder(
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          iconColor: AppColors.kozaGreen,
                          leading: const CircleAvatar(backgroundColor: AppColors.kozaGreenLight, child: Icon(Icons.groups, color: AppColors.kozaGreen)),
                          title: Text("${team.teamName} (${team.cityName})", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Lider: ${team.leaderName} • Üye: ${team.members.length}"),
                          children: [
                            const Divider(height: 1),
                            ...team.members.map((vol) {
                              return ListTile(
                                leading: const Icon(Icons.person, color: AppColors.textSecondary),
                                title: Text(vol.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text("${vol.specialty} • ${vol.healthStatus}", style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.chevron_right, size: 16),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text("${vol.name} Profili"),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Rol: ${vol.specialty}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text("Kan Grubu: ${vol.bloodType}"),
                                            Text("Sağlık Durumu: ${vol.healthStatus}"),
                                            const SizedBox(height: 12),
                                            const Text("Sertifikalar ve Eğitimler", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                            const SizedBox(height: 4),
                                            vol.certificates.isEmpty
                                                ? const Text("Kayıtlı sertifika yok.")
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: vol.certificates.map((c) => Text("• $c")).toList(),
                                                  ),
                                            const SizedBox(height: 12),
                                            const Text("Sınav Geçmişi", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                            const SizedBox(height: 4),
                                            vol.examRecords.isEmpty
                                                ? const Text("Kayıtlı sınav bulunmuyor.")
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: vol.examRecords.map((e) => Text("• ${e['name']}: ${e['score']} Puan (${e['status']})")).toList(),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Kapat"))
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── 4. SEKME: EĞİTİM TANIMLAMA ──────────────────────────────────────────
  Widget _buildTrainingTab() {
    final state = AppStateProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("GENEL MERKEZ EĞİTİM TANIMLAMA MODÜLÜ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),

        const Text("Eğitim Kategorisi Seçin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTrainingCategory,
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          items: ['Enkaz', 'Doğa', 'Su', 'Orman Yangını'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (v) { if (v != null) setState(() => _selectedTrainingCategory = v); },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tarih", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(controller: _trainingDateController, decoration: const InputDecoration(hintText: "GG/AA/YYYY", border: OutlineInputBorder())),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saat", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(controller: _trainingTimeController, decoration: const InputDecoration(hintText: "SS:DD", border: OutlineInputBorder())),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Eğitmen", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(controller: _instructorController, decoration: const InputDecoration(hintText: "Eğitmen Adı", border: OutlineInputBorder())),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Süre (Saat)", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Örn: 4", border: OutlineInputBorder())),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (_trainingDateController.text.isEmpty || _instructorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun.'), backgroundColor: AppColors.sosRed));
                return;
              }
              
              state.addTrainingNotification(
                _selectedTrainingCategory,
                _trainingDateController.text,
                _trainingTimeController.text,
                _instructorController.text,
                _durationController.text,
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saha eğitimi gönüllü portalına eklendi ve bildirim gönderildi.'), backgroundColor: AppColors.kozaGreen),
              );
              _trainingDateController.clear();
              _trainingTimeController.clear();
              _instructorController.clear();
              _durationController.clear();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
            child: const Text("Eğitimi Yayınla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
