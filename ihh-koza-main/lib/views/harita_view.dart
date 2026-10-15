import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../models/enkaz_sektor.dart';
import '../utils/wkt_parser.dart';
import '../utils/color_helper.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';
import '../state/app_state.dart';

// MANTIK HATASI (DÜZELTİLDİ): Gönüllü haritasında "Sektöre Git" butonu vardı.
// Bu yetki sadece Ekip Lideri'ne aittir. Gönüllü için sektör detayı sadece
// "bilgi" modunda gösterilecek, navigasyon yetki kısıtlıdır.

// MANTIK HATASI (DÜZELTİLDİ): points.isEmpty kontrolü sonrası reduce() çağrısı
// boş listede RangeError exception fırlatıyordu. İki ayrı güvenli kontrol eklendi.

/// 🗺️ Harita Sayfası — Gönüllü rolü (Sektöre Git butonu YOK)
class HaritaView extends StatefulWidget {
  const HaritaView({super.key});

  @override
  State<HaritaView> createState() => _HaritaViewState();
}

class _HaritaViewState extends State<HaritaView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<EnkazSektor> _sectors = [];
  List<EnkazSektor> _filteredSectors = [];
  bool _isLoading = true;
  String? _error;

  static const LatLng _defaultCenter = LatLng(40.9835, 29.054);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSectors);
    _loadSectors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSectors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSectors = query.isEmpty
          ? List.from(_sectors)
          : _sectors.where((s) => s.name.toLowerCase().contains(query) || s.sectorCode.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _loadSectors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('${AppConfig.backendUrl}/api/mule/sectors'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _sectors = data.map((json) => EnkazSektor.fromMap(json)).toList();
          _filteredSectors = List.from(_sectors);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Çevrimdışı mod — mock sektörlerle devam et
    }

    setState(() {
      _sectors = _getMockSectors();
      _filteredSectors = List.from(_sectors);
      _isLoading = false;
    });
  }

  List<EnkazSektor> _getMockSectors() {
    return [
      EnkazSektor(
        id: 'ENKAZ-A1',
        sectorCode: 'ENKAZ-A1',
        name: 'Enkaz A1 Sektörü',
        riskLevel: 'Kritik',
        geometryText: 'POLYGON((29.0520 40.9850, 29.0560 40.9850, 29.0560 40.9820, 29.0520 40.9820, 29.0520 40.9850))',
      ),
      EnkazSektor(
        id: 'ENKAZ-A2',
        sectorCode: 'ENKAZ-A2',
        name: 'Enkaz A2 Sektörü',
        riskLevel: 'CalismaVar',
        geometryText: 'POLYGON((29.0560 40.9850, 29.0600 40.9850, 29.0600 40.9820, 29.0560 40.9820, 29.0560 40.9850))',
      ),
      EnkazSektor(
        id: 'SEKTOR-4B',
        sectorCode: 'SEKTOR-4B',
        name: 'Sektör 4B - Sahra Hastanesi',
        riskLevel: 'Kritik',
        geometryText: 'POLYGON((29.0480 40.9870, 29.0520 40.9870, 29.0520 40.9850, 29.0480 40.9850, 29.0480 40.9870))',
      ),
      EnkazSektor(
        id: 'SEKTOR-C3',
        sectorCode: 'SEKTOR-C3',
        name: 'Sektör C3 - Lojistik Alanı',
        riskLevel: 'Temiz',
        geometryText: 'POLYGON((29.0600 40.9870, 29.0650 40.9870, 29.0650 40.9840, 29.0600 40.9840, 29.0600 40.9870))',
      ),
    ];
  }

  // MANTIK HATASI (DÜZELTİLDİ): "Sektöre Git" butonu gönüllü haritasından kaldırıldı.
  // Sadece sektör bilgisi gösterilir, navigasyon yetkisi yok.
  void _showSectorDetail(EnkazSektor sector) {
    final riskColor = RiskColorHelper.getPolygonColor(sector.riskLevel, opacity: 1.0);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: riskColor.withAlpha(30), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.location_on, color: riskColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sector.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('Kod: ${sector.sectorCode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: riskColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Text(sector.riskLevel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: riskColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.social_distance, 'Merkeze Uzaklık', '450m'),
            const SizedBox(height: 14),
            _buildDetailRow(Icons.groups, 'Gönüllü Sayısı', '12 Aktif'),
            const SizedBox(height: 14),
            _buildDetailRow(Icons.priority_high_rounded, 'Risk Seviyesi', sector.riskLevel, valueColor: riskColor),
            const SizedBox(height: 24),

            // GÜVENLİ BİLGİ NOTU (Sektöre Git butonu yok — gönüllü yetkisi)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBlueBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoBlue.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.infoBlue, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sektöre yönlendirme yetkisi sadece Ekip Lideri\'nde bulunmaktadır. Liderinizle irtibata geçin.',
                      style: TextStyle(fontSize: 11, color: AppColors.infoBlue, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'SAHA HARİTASI'),
      endDrawer: const NotificationPanel(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 14.0,
              onTap: (_, __) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.koza.ihh',
              ),
              // MANTIK HATASI DÜZELTMESİ: points.isEmpty kontrolü null-safe yapıldı
              PolygonLayer(
                polygons: _filteredSectors.map((sector) {
                  final points = WktParser.parsePolygon(sector.geometryText);
                  if (points.length < 3) return null; // En az 3 nokta gerekli
                  final fillColor = RiskColorHelper.getPolygonColor(sector.riskLevel, opacity: 0.3);
                  final borderColor = RiskColorHelper.getPolygonColor(sector.riskLevel, opacity: 0.8);
                  return Polygon(
                    points: points,
                    color: fillColor,
                    borderColor: borderColor,
                    borderStrokeWidth: 2.5,
                    isFilled: true,
                    label: sector.sectorCode,
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  );
                }).whereType<Polygon>().toList(),
              ),
              MarkerLayer(
                markers: _filteredSectors.map((sector) {
                  final points = WktParser.parsePolygon(sector.geometryText);
                  if (points.isEmpty) return null;
                  // MANTIK HATASI DÜZELTMESİ: Boş liste kontrolü ile null-safe reduce
                  final double avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
                  final double avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
                  final riskColor = RiskColorHelper.getPolygonColor(sector.riskLevel, opacity: 1.0);

                  return Marker(
                    point: LatLng(avgLat, avgLng),
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => _showSectorDetail(sector),
                      child: Container(
                        decoration: BoxDecoration(
                          color: riskColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: riskColor.withAlpha(80), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                      ),
                    ),
                  );
                }).whereType<Marker>().toList(),
              ),
            ],
          ),

          // ─── Arama Barı ──────────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Sektör veya bölge ara...',
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(width: 1, height: 28, color: AppColors.divider),
                  IconButton(
                    icon: const Icon(Icons.my_location_rounded, color: AppColors.kozaGreen, size: 22),
                    onPressed: () => _mapController.move(_defaultCenter, 14),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.kozaGreen)),

          // ─── Risk Lejantı ─────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RİSK SEVİYESİ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendDot(Colors.red, 'Kritik'),
                      const SizedBox(width: 12),
                      _buildLegendDot(Colors.orange, 'Çalışma Var'),
                      const SizedBox(width: 12),
                      _buildLegendDot(Colors.green, 'Temiz'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}
