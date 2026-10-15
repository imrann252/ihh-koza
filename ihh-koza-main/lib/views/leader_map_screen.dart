import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../constants/il_listesi.dart';
import '../state/app_state.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';
import '../widgets/sos_target_dialog.dart';
import 'cagrilar_view.dart';
import 'leader_report_screen.dart';
import 'egitim_view.dart';

class LeaderMapScreen extends StatefulWidget {
  const LeaderMapScreen({super.key});

  @override
  State<LeaderMapScreen> createState() => _LeaderMapScreenState();
}

class _LeaderMapScreenState extends State<LeaderMapScreen> with TickerProviderStateMixin {
  int _currentNavIndex = 3; 

  // Controllers
  late TabController _ekipTabController;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController(); // Ekip arama için
  
  // State
  String _selectedCity = 'Hatay';
  int _shiftHours = 6;
  String _sortMode = 'Puan'; // Puan veya İsim
  String _mapFilter = 'DevamEdenler';
  
  // MANTIK HATASI DÜZELTMESİ: Checkbox state'ini tutan set
  final Set<String> _selectedVolunteerIds = {};

  final List<Map<String, dynamic>> _allPersonnel = [
    {'id': 'V01', 'name': 'Ahmet Yılmaz', 'score': 95, 'skills': ['AFAD Seviye 3', 'Eğitmen'], 'status': 'Müsait', 'avatar': 'AY'},
    {'id': 'V02', 'name': 'Mehmet Serkan Ö.', 'score': 88, 'skills': ['İlkyardım', 'Lojistik'], 'status': 'Müsait', 'avatar': 'MS'},
    {'id': 'V03', 'name': 'Ayşe Kara', 'score': 92, 'skills': ['Afet Psikolojisi', 'İlkyardım'], 'status': 'Dinlenmede', 'avatar': 'AK'},
    {'id': 'V04', 'name': 'Hasan Demir', 'score': 84, 'skills': ['Lojistik', 'Sürücü'], 'status': 'Müsait', 'avatar': 'HD'},
    {'id': 'V05', 'name': 'Mustafa Yıldız', 'score': 91, 'skills': ['Enkaz Arama', 'K9 Eğitmeni'], 'status': 'Dinlenmede', 'avatar': 'MY'},
    {'id': 'V06', 'name': 'Fatma Çelik', 'score': 89, 'skills': ['Haberleşme', 'Telsiz Op'], 'status': 'Pasif', 'avatar': 'FÇ'},
  ];

  List<Map<String, dynamic>> _filteredPersonnel = [];
  late List<Map<String, dynamic>> _assignedShiftTeam;

  final List<Map<String, dynamic>> _customSectors = [
    {
      'name': 'Kırıkhan Göçüğü',
      'location': const LatLng(36.208, 36.155),
      'status': 'Çalışıyor', // Başlamadı / Çalışıyor / Bitti
      'risk': 'Kritik',
      'desc': 'Kurtarma Ekibi Kuruluyor',
    },
    {
      'name': 'Antakya Depo Çadırı',
      'location': const LatLng(36.195, 36.172),
      'status': 'Başlamadı',
      'risk': 'Orta / Beklemede',
      'desc': 'Sevkiyat Onayı Bekleniyor',
    },
    {
      'name': 'Defne Lojistik Üssü',
      'location': const LatLng(36.215, 36.165),
      'status': 'Bitti',
      'risk': 'Güvenli / Taranmış',
      'desc': 'Vardiya Düzenli İşliyor',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ekipTabController = TabController(length: 3, vsync: this);
    _filteredPersonnel = List.from(_allPersonnel);
    _searchController.addListener(_applyFilterAndSort);
    
    _assignedShiftTeam = [
      {
        'id': 'V01',
        'name': 'Ahmet Yılmaz',
        'skills': 'AFAD Seviye 3, Eğitmen',
        'sector': 'Defne Sektör A-1',
        'hours': 8,
        'status': 'Görevde',
        'avatar': 'AY',
      },
      {
        'id': 'V02',
        'name': 'Mehmet Serkan Ö.',
        'skills': 'İlkyardım, Lojistik',
        'sector': 'Defne Sektör A-2',
        'hours': 6,
        'status': 'Görevde',
        'avatar': 'MS',
      },
      {
        'id': 'V03',
        'name': 'Ayşe Kara',
        'skills': 'Afet Psikolojisi, İlkyardım',
        'sector': 'Lojistik Üssü',
        'hours': 4,
        'status': 'Dinlenmede',
        'avatar': 'AK',
      },
      {
        'id': 'V04',
        'name': 'Hasan Demir',
        'skills': 'Lojistik, Sürücü',
        'sector': 'Kırıkhan Depo',
        'hours': 6,
        'status': 'Görevde',
        'avatar': 'HD',
      },
      {
        'id': 'V05',
        'name': 'Mustafa Yıldız',
        'skills': 'Enkaz Arama, K9 Eğitmeni',
        'sector': 'Defne Sektör A-1',
        'hours': 8,
        'status': 'Dinlenmede',
        'avatar': 'MY',
      },
    ];
  }

  @override
  void dispose() {
    _ekipTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilterAndSort() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersonnel = _allPersonnel.where((p) {
        return (p['name'] as String).toLowerCase().contains(query) ||
               (p['skills'] as List<String>).any((s) => s.toLowerCase().contains(query));
      }).toList();
      
      if (_sortMode == 'Puan') {
        _filteredPersonnel.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      } else {
        _filteredPersonnel.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      }
    });
  }

  Future<void> _handleSOSPress() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS mesajı göndermek için butona basılı tutun ve hedef seçin.'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSOSLongPress() async {
    await showSosTargetDialog(context);
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'KOZA - EKİP LİDERİ'),
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
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: AppColors.kozaGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  "GİRİŞ YAPAN: ${AppStateProvider.of(context).session?.displayName.toUpperCase() ?? 'LİDER'}",
                  style: const TextStyle(color: AppColors.kozaGreen, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'lider_sos_fab',
        elevation: 8,
        backgroundColor: AppColors.sosRed,
        shape: const CircleBorder(),
        onPressed: _handleSOSPress,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: _handleSOSLongPress,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sos_rounded, size: 24, color: Colors.white),
              Text('SOS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0: return _buildEkipTabBody();
      case 1: return const CagrilarView(); // Duyuru yerine
      case 3: return _buildHaritaTabBody();
      case 4: return _buildProfilTabBody();
      default: return const SizedBox();
    }
  }

  // ─── HARİTA SEKME ────────────────────────────────────────────────────────
  void _handleMapTap(LatLng point) {
    _showAddSectorDialog(point: point);
  }

  void _showAddSectorDialog({LatLng? point}) {
    final nameController = TextEditingController();
    final latController = TextEditingController(text: point != null ? point.latitude.toStringAsFixed(6) : '36.2021');
    final lngController = TextEditingController(text: point != null ? point.longitude.toStringAsFixed(6) : '36.1606');
    final descController = TextEditingController();
    
    String selectedStatus = 'Başlamadı';
    String selectedRisk = 'Orta / Beklemede';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.add_location_alt_rounded, color: AppColors.kozaGreen),
                  SizedBox(width: 10),
                  Text('Yeni Sektör Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Haritadan seçtiğiniz konuma veya koordinat girerek yeni bir çalışma sektörü tanımlayabilirsiniz.",
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    
                    // Sektör Adı
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Sektör / Bölge Adı',
                        prefixIcon: const Icon(Icons.edit_road, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Koordinatlar (Lat/Lng)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Enlem (Lat)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: lngController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Boylam (Lng)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Durum Seçimi (Çalışıyor - Başlamadı - Bitti)
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Çalışma Durumu',
                        prefixIcon: const Icon(Icons.sync, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Başlamadı', child: Text('Başlamadı')),
                        DropdownMenuItem(value: 'Çalışıyor', child: Text('Çalışıyor')),
                        DropdownMenuItem(value: 'Bitti', child: Text('Bitti')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Risk Durumu
                    DropdownButtonFormField<String>(
                      value: selectedRisk,
                      decoration: InputDecoration(
                        labelText: 'Risk Durumu',
                        prefixIcon: const Icon(Icons.report_problem_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Kritik', child: Text('Kritik')),
                        DropdownMenuItem(value: 'Orta / Beklemede', child: Text('Orta / Beklemede')),
                        DropdownMenuItem(value: 'Güvenli / Taranmış', child: Text('Güvenli / Taranmış')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRisk = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Açıklama
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Açıklama / Görev Bilgisi',
                        prefixIcon: const Icon(Icons.description, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final lat = double.tryParse(latController.text) ?? 36.2021;
                    final lng = double.tryParse(lngController.text) ?? 36.1606;
                    
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen sektör adı giriniz.'), backgroundColor: AppColors.sosRed),
                      );
                      return;
                    }
                    
                    setState(() {
                      _customSectors.add({
                        'name': name,
                        'location': LatLng(lat, lng),
                        'status': selectedStatus,
                        'risk': selectedRisk,
                        'desc': descController.text.trim(),
                      });
                    });
                    
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"$name" sektörü haritaya başarıyla eklendi!'), backgroundColor: AppColors.kozaGreen),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kozaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHaritaTabBody() {
    final filteredSectors = _customSectors.where((sector) {
      if (_mapFilter == 'Bitenler') {
        return sector['status'] == 'Bitti';
      } else {
        return sector['status'] == 'Çalışıyor' || sector['status'] == 'Başlamadı';
      }
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(36.2021, 36.1606),
            initialZoom: 13.0,
            onTap: (tapPosition, point) {
              _handleMapTap(point);
            },
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.koza.ihh'),
            MarkerLayer(
              markers: filteredSectors.map((sector) {
                Color pinColor = Colors.blue; // Başlamadı
                if (sector['status'] == 'Bitti') pinColor = AppColors.kozaGreen;
                if (sector['status'] == 'Çalışıyor') pinColor = Colors.orange;
                
                return Marker(
                  point: sector['location'] as LatLng,
                  width: 48,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => _showAreaDetail(sector),
                    child: Icon(Icons.location_on, color: pinColor, size: 40),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        
        // Üst Filtreler
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Row(
                children: [
                  _buildOvalFilterButton("Taraması Bitenler", _mapFilter == 'Bitenler', () => setState(() => _mapFilter = 'Bitenler')),
                  const SizedBox(width: 8),
                  _buildOvalFilterButton("Devam Edenler", _mapFilter == 'DevamEdenler', () => setState(() => _mapFilter = 'DevamEdenler')),
                ],
              ),
            ],
          ),
        ),
        
        // Alt Bilgilendirme ve Hızlı Ekleme
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(240),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6, offset: const Offset(0, 2))],
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_location_alt_outlined, color: AppColors.kozaGreen, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Haritaya dokunarak koordinat seçebilir veya manuel ekleyebilirsiniz.",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showAddSectorDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kozaGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Sektör Ekle", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOvalFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kozaGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.kozaGreen : AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  void _showAreaDetail(Map<String, dynamic> sector) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isBitti = sector['status'] == 'Bitti';
            final isCalisiyor = sector['status'] == 'Çalışıyor';
            
            Color statusColor = Colors.blue;
            if (isBitti) statusColor = AppColors.kozaGreen;
            if (isCalisiyor) statusColor = Colors.orange;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sector['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          sector['status'].toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text("Risk Seviyesi: ${sector['risk']}", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text(
                        "Koordinat: ${(sector['location'] as LatLng).latitude.toStringAsFixed(5)}, ${(sector['location'] as LatLng).longitude.toStringAsFixed(5)}",
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  const Text("SEKTÖR AÇIKLAMASI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                  const SizedBox(height: 4),
                  Text(
                    sector['desc'].isNotEmpty ? sector['desc'] : 'Açıklama girilmedi.',
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const Divider(height: 24),
                  
                  Row(
                    children: [
                      // Durum Değiştir Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("DURUMU GÜNCELLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: sector['status'],
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  onChanged: (newVal) {
                                    if (newVal != null) {
                                      setState(() {
                                        sector['status'] = newVal;
                                      });
                                      setSheetState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"${sector['name']}" durumu "$newVal" olarak güncellendi.'),
                                          backgroundColor: AppColors.kozaGreen,
                                        ),
                                      );
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 'Başlamadı', child: Text('Başlamadı')),
                                    DropdownMenuItem(value: 'Çalışıyor', child: Text('Çalışıyor')),
                                    DropdownMenuItem(value: 'Bitti', child: Text('Bitti')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Silme Butonu
                      IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            _customSectors.remove(sector);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${sector['name']}" Sektörü haritadan silindi.'),
                              backgroundColor: AppColors.sosRed,
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.sosRedLight,
                          foregroundColor: AppColors.sosRed,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Eğer tamamlanmış yeşil alan ise rapor şablonu butonu göster
                  if (isBitti) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderReportScreen(sectorName: sector['name'])));
                        },
                        icon: const Icon(Icons.assignment, size: 18),
                        label: const Text('Rapor Şablonunu Doldur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kozaGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Kapat', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  // ─── EKİP SEKME GÖVDESİ ──────────────────────────────────────────────────
  Widget _buildEkipTabBody() {
    return Column(
      children: [
        TabBar(
          controller: _ekipTabController,
          labelColor: AppColors.kozaGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.kozaGreen,
          tabs: const [Tab(text: "EKİBİM"), Tab(text: "EKİP OLUŞTUR"), Tab(text: "VARDİYA")],
        ),
        Expanded(
          child: TabBarView(
            controller: _ekipTabController,
            children: [
              _buildEkibimSubTab(),
              _buildEkipOlusturSubTab(),
              _buildVardiyaSubTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEkibimSubTab() {
    return Column(
      children: [
        // Arama ve Şehir barı
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(hintText: "İsim veya uzmanlık ara...", border: InputBorder.none, hintStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // MANTIK HATASI DÜZELTMESİ: 81 il entegrasyonu
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCity = v);
                        },
                        items: TurkeyIlListesi.iller.map((city) => DropdownMenuItem(value: city, child: Text(city, style: const TextStyle(fontSize: 13)))).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Sırala: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortMode,
                      isDense: true,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _sortMode = v);
                          _applyFilterAndSort();
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'Puan', child: Text('Yetkinlik Puanı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DropdownMenuItem(value: 'Isim', child: Text('Alfabetik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredPersonnel.length,
            itemBuilder: (context, index) {
              final person = _filteredPersonnel[index];
              return _buildPersonCard(person);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("${person['name']} Profili"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Yetkinlik Puanı: ${person['score']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("Sertifikalar ve Eğitimler", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  const SizedBox(height: 4),
                  const Text("• AFAD Arama Kurtarma Seviye 3"),
                  const Text("• İlk Yardım Temel Sertifikası"),
                  const SizedBox(height: 12),
                  const Text("Sınav Geçmişi", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  const SizedBox(height: 4),
                  const Text("• Arama Kurtarma Sınavı: 85 Puan (Başarılı)"),
                  const Text("• İlk Yardım Sınavı: 92 Puan (Başarılı)"),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Kapat")),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 24, backgroundColor: AppColors.inputBg, child: Text(person['avatar'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: AppColors.kozaGreen, shape: BoxShape.circle),
                    child: Text('${person['score']}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4, runSpacing: 4,
                    children: (person['skills'] as List<String>).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(skill, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // MANTIK HATASI DÜZELTMESİ: Lider personelin durumunu manuel yönetebilir
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: ['Görevde', 'Dinlenmede', 'Pasif'].contains(person['status'])
                    ? person['status']
                    : 'Görevde',
                icon: const SizedBox(),
                alignment: Alignment.centerRight,
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      final idx = _allPersonnel.indexWhere((p) => p['id'] == person['id']);
                      if (idx != -1) {
                        _allPersonnel[idx]['status'] = v;
                        _applyFilterAndSort();
                      }
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'Görevde', child: Text('Görevde', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'Dinlenmede', child: Text('Dinlenmede', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'Pasif', child: Text('Pasif', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEkipOlusturSubTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nitelikli Gönüllü Eşleştirme", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("${_filteredPersonnel.length} aday listeleniyor. Çoklu seçim yapıp ekibi kurabilirsiniz.", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredPersonnel.length,
            itemBuilder: (context, index) {
              final p = _filteredPersonnel[index];
              final isSelected = _selectedVolunteerIds.contains(p['id']);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColors.kozaGreen : Colors.transparent)),
                child: ListTile(
                  leading: CircleAvatar(child: Text(p['avatar'])),
                  title: Text(p['name']),
                  subtitle: Text("Puan: ${p['score']} • ${(p['skills'] as List<String>).join(', ')}", style: const TextStyle(fontSize: 11)),
                  // MANTIK HATASI DÜZELTMESİ: Checkbox state'i düzgün çalışıyor
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: AppColors.kozaGreen,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) _selectedVolunteerIds.add(p['id']);
                        else _selectedVolunteerIds.remove(p['id']);
                      });
                    },
                  ),
                  onTap: () {
                     setState(() {
                        if (!isSelected) _selectedVolunteerIds.add(p['id']);
                        else _selectedVolunteerIds.remove(p['id']);
                      });
                  },
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedVolunteerIds.isEmpty ? null : () {
                // Alarm bildirimi simülasyonu
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_selectedVolunteerIds.length} personele Görevlendirme Alarmı gönderildi.'),
                    backgroundColor: AppColors.kozaGreen,
                  ),
                );
                setState(() => _selectedVolunteerIds.clear());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kozaGreen,
                disabledBackgroundColor: AppColors.inputBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("Seçilen Personellerle Ekibi Kur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVardiyaSubTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Üst Bilgilendirme Kartı
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.infoBlueBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.infoBlue.withAlpha(50)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.infoBlue, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Afete özel oluşturulan ekibin çalışma sektörlerini, saat atamalarını ve anlık aktiflik (Görevde / Dinlenmede) durumlarını aşağıdan konfigüre edebilirsiniz.",
                  style: TextStyle(fontSize: 12, color: AppColors.infoBlue, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Başlık satırı
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Aktif Afet Ekibi Vardiya Listesi",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Icon(Icons.checklist_rtl_rounded, color: AppColors.kozaGreen),
          ],
        ),
        const SizedBox(height: 12),

        // Vardiya Ekibi Kart Listesi
        ..._assignedShiftTeam.map((member) {
          final bool isGov = member['status'] == 'Görevde';
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.divider.withAlpha(150)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim & Profil & Durum
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isGov ? AppColors.kozaGreenLight : Colors.orange.shade50,
                        child: Text(
                          member['avatar'],
                          style: TextStyle(
                            color: isGov ? AppColors.kozaGreen : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            Text(
                              member['skills'],
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      
                      // Durum Seçici (Görevde / Dinlenmede)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isGov ? AppColors.kozaGreenLight : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isGov ? AppColors.kozaGreen.withAlpha(100) : Colors.orange.withAlpha(100)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: member['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGov ? AppColors.kozaGreen : Colors.orange,
                            ),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  member['status'] = newVal;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${member['name']} durumu "${newVal}" olarak güncellendi.'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: newVal == 'Görevde' ? AppColors.kozaGreen : Colors.orange,
                                  ),
                                );
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'Görevde',
                                child: Text('Görevde'),
                              ),
                              DropdownMenuItem(
                                value: 'Dinlenmede',
                                child: Text('Dinlenmede'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // Sektör Ataması ve Saat Ataması
                  Row(
                    children: [
                      // Sektör Seçimi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SEKTÖR / BÖLGE",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: member['sector'],
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  onChanged: (newSector) {
                                    if (newSector != null) {
                                      setState(() {
                                        member['sector'] = newSector;
                                      });
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 'Defne Sektör A-1', child: Text('Defne Sektör A-1')),
                                    DropdownMenuItem(value: 'Defne Sektör A-2', child: Text('Defne Sektör A-2')),
                                    DropdownMenuItem(value: 'Lojistik Üssü', child: Text('Lojistik Üssü')),
                                    DropdownMenuItem(value: 'Kırıkhan Depo', child: Text('Kırıkhan Depo')),
                                    DropdownMenuItem(value: 'Sahra Hastanesi', child: Text('Sahra Hastanesi')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Saat Ataması
                      SizedBox(
                        width: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "VARDİYA SÜRESİ",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: member['hours'],
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  onChanged: (newHours) {
                                    if (newHours != null) {
                                      setState(() {
                                        member['hours'] = newHours;
                                      });
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 4, child: Text('4 Saat')),
                                    DropdownMenuItem(value: 6, child: Text('6 Saat')),
                                    DropdownMenuItem(value: 8, child: Text('8 Saat')),
                                    DropdownMenuItem(value: 12, child: Text('12 Saat')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Hızlı Toplu İşlem Butonları
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    for (var m in _assignedShiftTeam) {
                      m['status'] = 'Görevde';
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm ekip üyeleri aktif göreve atandı.'),
                      backgroundColor: AppColors.kozaGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text("Tümünü Göreve Al", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kozaGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    for (var m in _assignedShiftTeam) {
                      m['status'] = 'Dinlenmede';
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm ekip üyeleri dinlenmeye alındı.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.nightlight_round, size: 18),
                label: const Text("Tümünü Dinlendir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── PROFİL SEKME ────────────────────────────────────────────────────────
  Widget _buildProfilTabBody() {
    final state = AppStateProvider.of(context);
    final profile = state.volunteerProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Bilgi Güncelleme Uyarısı ────────────────────────
          _buildProfileUpdateBanner(),
          const SizedBox(height: 20),

          // ─── Kullanıcı Künyesi ───────────────────────────────
          _buildProfileUserHeader(profile),
          const SizedBox(height: 24),

          // ─── Kişisel Bilgiler ────────────────────────────────
          _buildProfileSectionTitle('Kişisel Bilgiler'),
          const SizedBox(height: 12),
          _buildProfileInfoCard([
            _ProfileInfoRowData(label: 'YAŞ', value: '${profile.age}', icon: Icons.cake_outlined),
            _ProfileInfoRowData(label: 'KAN GRUBU', value: profile.bloodType, icon: Icons.bloodtype_outlined, valueColor: AppColors.sosRed),
            _ProfileInfoRowData(label: 'TELEFON', value: profile.phone, icon: Icons.phone_outlined),
            _ProfileInfoRowData(label: 'ACİL DURUM KİŞİSİ', value: '${profile.emergencyContact} - ${profile.emergencyPhone}', icon: Icons.emergency_outlined, valueColor: AppColors.sosRed),
            _ProfileInfoRowData(label: 'MESLEK', value: profile.profession, icon: Icons.work_outline),
            _ProfileInfoRowData(label: 'ADRES', value: '${profile.city}, ${profile.district}\n${profile.address}', icon: Icons.location_on_outlined),
          ]),
          const SizedBox(height: 28),

          // ─── Saha Eğitimleri & Sertifikalar Yönlendirmesi ───
          _buildProfileSectionTitle('Saha Eğitimleri Akademisi'),
          const SizedBox(height: 12),
          _buildProfileEgitimNavCard(context, profile.certificates.length),
          const SizedBox(height: 24),

          _buildProfileSectionTitle('Eğitim ve Sınav Geçmişi'),
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

          _buildProfileSectionTitle('Kazanılan Sertifikalar'),
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
    );
  }

  Widget _buildProfileUpdateBanner() {
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

  Widget _buildProfileUserHeader(var profile) {
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
          const Text(
            'Rol: Ekip Lideri',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kozaGreen),
          ),
          const SizedBox(height: 10),
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

  Widget _buildProfileInfoCard(List<_ProfileInfoRowData> items) {
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

  Widget _buildProfileEgitimNavCard(BuildContext context, int certCount) {
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

  Widget _buildProfileSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  }

  // ─── BOTTOM NAVIGATION BAR ──────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 12,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.groups_outlined, 'Ekip'),
          _buildNavItem(1, Icons.crisis_alert_outlined, 'Çağrılar'),
          const SizedBox(width: 56), 
          _buildNavItem(3, Icons.map_outlined, 'Harita'),
          _buildNavItem(4, Icons.person_outline, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentNavIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentNavIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isActive ? AppColors.kozaGreen : AppColors.textHint),
            const SizedBox(height: 1),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppColors.kozaGreen : AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRowData {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _ProfileInfoRowData({required this.label, required this.value, required this.icon, this.valueColor});
}
