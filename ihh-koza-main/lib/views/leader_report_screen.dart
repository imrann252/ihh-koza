import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/hive_service.dart';
import '../widgets/koza_app_bar.dart';
import '../state/app_state.dart';

/// 📝 Ekip Lideri Rapor Şablonu
/// Tamamlanan (yeşil) sektöre tıklandığında açılır.
/// Doldurulan veriler Hive üzerinden local kuryeye yazılır.
class LeaderReportScreen extends StatefulWidget {
  final String sectorName;

  const LeaderReportScreen({super.key, required this.sectorName});

  @override
  State<LeaderReportScreen> createState() => _LeaderReportScreenState();
}

class _LeaderReportScreenState extends State<LeaderReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _savedController = TextEditingController(text: '0');
  final TextEditingController _injuredController = TextEditingController(text: '0');
  final TextEditingController _deceasedController = TextEditingController(text: '0');

  bool _isNeedsLogistics = false;
  bool _isNeedsMedical = false;
  bool _isAreaSafe = true;

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final int saved = int.tryParse(_savedController.text) ?? 0;
      final int injured = int.tryParse(_injuredController.text) ?? 0;
      final int deceased = int.tryParse(_deceasedController.text) ?? 0;

      // Genel Merkez Afet verilerini güncelle
      AppStateProvider.of(context).addDisasterReportData(
        widget.sectorName,
        saved: saved,
        injured: injured,
        deceased: deceased,
      );

      // Mock save to Hive as FieldLog string payload
      await HiveService.saveLogOffline(
        sectorId: widget.sectorName,
        audioPath: '',
        status: _isAreaSafe ? 'Temiz' : 'Kritik',
        savedCount: saved,
        injuredCount: injured,
        deceasedCount: deceased,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Sektör Raporu Genel Merkez\'e gönderildi ve kuryeye mühürlendi.'),
              ],
            ),
            backgroundColor: AppColors.kozaGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Geri dön
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _savedController.dispose();
    _injuredController.dispose();
    _deceasedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'SEKTÖR RAPORU', showLogout: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Bilgi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.kozaGreenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.kozaGreen.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in, color: AppColors.kozaGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("İlgili Sektör", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(widget.sectorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.kozaGreenDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rapor İçeriği
              const Text("Durum Bildirimi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInput("Sağ Kurtarılan", _savedController, Icons.check_circle_outline, AppColors.kozaGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInput("Yaralı Sayısı", _injuredController, Icons.health_and_safety_outlined, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInput("Vefat Sayısı", _deceasedController, Icons.warning_amber_rounded, Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // İhtiyaçlar (Checkboxes)
              const Text("Acil İhtiyaçlar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("Ekstra Lojistik/Erzak Gerekiyor"),
                      value: _isNeedsLogistics,
                      activeColor: AppColors.kozaGreen,
                      onChanged: (v) => setState(() => _isNeedsLogistics = v ?? false),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    CheckboxListTile(
                      title: const Text("Tıbbi Müdahale Ekibi Gerekiyor"),
                      value: _isNeedsMedical,
                      activeColor: AppColors.sosRed,
                      onChanged: (v) => setState(() => _isNeedsMedical = v ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sektör Durumu
              const Text("Saha Güvenliği", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Sektör Tamamen Güvenli (Tarandı)"),
                subtitle: const Text("Bu alan tehlikeden arındırılmış sayılacaktır."),
                value: _isAreaSafe,
                activeColor: AppColors.kozaGreen,
                onChanged: (v) => setState(() => _isAreaSafe = v),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
                tileColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Notlar
              const Text("Saha Notları (Genel Merkez İçin)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Sektördeki güncel durum, hasar boyutu ve ekiplerin genel gidişatı hakkında notunuzu buraya girin...",
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.kozaGreen)),
                ),
              ),
              const SizedBox(height: 30),

              // Gönder Butonu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text('Raporu Mühürle ve Gönder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kozaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Boş geçilemez';
            return null;
          },
        ),
      ],
    );
  }
}
