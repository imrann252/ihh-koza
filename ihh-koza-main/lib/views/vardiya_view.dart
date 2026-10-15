import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../models/shift_assignment.dart';
import '../widgets/koza_app_bar.dart';
import '../widgets/notification_panel.dart';

/// ⏱️ Vardiya Sayfası — Dairesel geri sayım sayacı, aktif bölge kartı, nöbet arkadaşları, giriş/çıkış ve vakıf mesaisi
class VardiyaView extends StatefulWidget {
  const VardiyaView({super.key});

  @override
  State<VardiyaView> createState() => _VardiyaViewState();
}

class _VardiyaViewState extends State<VardiyaView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;

  // Giriş/Çıkış saatleri
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  // Vakıfta geçirilen süre takibi
  bool _isWorkingAtFoundation = false;
  DateTime? _foundationStartTime;
  double _accumulatedFoundationHours = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) return '00:00';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    
    if (state.session?.isLeader == true) {
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: const KozaAppBar(title: 'VARDİYA KONFİGÜRATÖRÜ'),
        endDrawer: const NotificationPanel(),
        body: _buildLeaderConfigurator(),
      );
    }

    var assignment = state.shiftAssignment;

    // Afete özel oluşturulan ekibi otomatik vardiya kısmına aktar
    if (assignment == null && state.activeDisasters.isNotEmpty) {
      final disaster = state.activeDisasters.first;
      assignment = ShiftAssignment(
        sectorCode: 'SEK-DIS',
        sectorName: '${disaster.location} - Sektör A1',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        durationHours: 6,
        leaderName: 'Ekip Lideri',
        status: ShiftStatus.active,
      );
    }

    if (assignment == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: const KozaAppBar(title: 'VARDİYA'),
        endDrawer: const NotificationPanel(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Aktif vardiyanız bulunmamaktadır.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Ekip liderinden veya güncel afetten atama bekleniyor.', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              const SizedBox(height: 24),
              _buildFoundationWorkCard(state),
            ],
          ),
        ),
      );
    }

    final isCompleted = assignment.status == ShiftStatus.pendingLeaderApproval || assignment.status == ShiftStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const KozaAppBar(title: 'VARDİYA'),
      endDrawer: const NotificationPanel(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // ─── Dairesel Geri Sayım Sayacı ─────────────────────
            _buildCircularTimer(assignment, isCompleted),
            const SizedBox(height: 24),

            // ─── Alana Giriş / Çıkış Paneli ─────────────────────
            _buildCheckInOutPanel(),
            const SizedBox(height: 20),

            // ─── Aktif Bölge Kartı ──────────────────────────────
            _buildActiveZoneCard(assignment),
            const SizedBox(height: 20),

            // ─── Vakıfta Geçirilen Süre Puan Ekleme Paneli ──────
            _buildFoundationWorkCard(state),
            const SizedBox(height: 20),

            // ─── Nöbet Arkadaşları ──────────────────────────────
            _buildSectionTitle('Nöbet Arkadaşları'),
            const SizedBox(height: 12),
            _buildCompanionCard(name: 'Mehmet Serkan Ö.', role: 'Saha Gönüllüsü', isOnline: true),
            const SizedBox(height: 8),
            _buildCompanionCard(name: 'Ayşe Kara', role: 'İlk Yardım Uzmanı', isOnline: true),
            const SizedBox(height: 8),
            _buildCompanionCard(name: 'Hasan Demir', role: 'Lojistik Sorumlusu', isOnline: false),
            const SizedBox(height: 28),

            // ─── Vardiyayı Bitir Butonu ──────────────────────────
            if (!isCompleted)
              _buildEndShiftButton(state, assignment)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.kozaGreen),
                    SizedBox(width: 12),
                    Expanded(child: Text('Vardiya bitirildi. Lider onayı bekleniyor.', style: TextStyle(color: AppColors.kozaGreen, fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Giriş Çıkış Saatleri Paneli ──────────────────────────────────────────
  Widget _buildCheckInOutPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ALANA GİRİŞ SAATİ', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _checkInTime != null 
                        ? '${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}' 
                        : 'Giriş Yapılmadı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _checkInTime != null ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ALANDAN ÇIKIŞ SAATİ', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _checkOutTime != null 
                        ? '${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}' 
                        : 'Çıkış Yapılmadı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _checkOutTime != null ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _checkInTime != null ? null : () {
                    setState(() {
                      _checkInTime = DateTime.now();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alana giriş saati kaydedildi.'), backgroundColor: AppColors.kozaGreen),
                    );
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Giriş Yap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kozaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _checkInTime == null || _checkOutTime != null ? null : () {
                    setState(() {
                      _checkOutTime = DateTime.now();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alandan çıkış saati kaydedildi.'), backgroundColor: AppColors.sosRed),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Çıkış Yap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sosRed,
                    side: const BorderSide(color: AppColors.sosRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ─── Vakıfta Geçirilen Süre Kartı ──────────────────────────────────────────
  Widget _buildFoundationWorkCard(AppState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home_work, color: AppColors.kozaGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Vakıf / Genel Merkez Mesaisi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Vakıf merkezinde veya lojistik depoda geçirdiğiniz süreler puanınıza eklenir.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          if (_isWorkingAtFoundation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Geçen Süre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                      const SizedBox(width: 6),
                      Text(
                        _formatFoundationDuration(),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.kozaGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (!_isWorkingAtFoundation) {
                    _isWorkingAtFoundation = true;
                    _foundationStartTime = DateTime.now();
                  } else {
                    _isWorkingAtFoundation = false;
                    final elapsedMinutes = DateTime.now().difference(_foundationStartTime!).inMinutes;
                    final elapsedHours = elapsedMinutes / 60.0;
                    final roundedHours = (elapsedHours * 10).round() / 10.0;
                    final displayHours = roundedHours > 0 ? roundedHours : 0.1;
                    
                    _accumulatedFoundationHours += displayHours;
                    
                    // AppState'deki totalShiftHours'a puanı yansıt
                    final currentProfile = state.volunteerProfile;
                    final newHours = currentProfile.totalShiftHours + (displayHours * 10).toInt(); // 1 saat = 10 saatlik vardiyaya esdeger puan
                    state.updateVolunteerProfile(currentProfile.copyWith(totalShiftHours: newHours));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vakıf mesaisi bitti: $displayHours saat. Yetkinlik puanınız güncellendi!'),
                        backgroundColor: AppColors.kozaGreen,
                      ),
                    );
                    _foundationStartTime = null;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isWorkingAtFoundation ? AppColors.sosRed : AppColors.kozaGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _isWorkingAtFoundation ? 'Çalışmayı Bitir' : 'Vakıf Mesaisi Başlat',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatFoundationDuration() {
    if (_foundationStartTime == null) return '00:00';
    final diff = DateTime.now().difference(_foundationStartTime!);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── Lider Konfigüratörü ────────────────────────────────────────────────────
  Widget _buildLeaderConfigurator() {
    final state = AppStateProvider.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Afete Özel Ekip Atamaları (Aktif Görev)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildLeaderAssignmentCard(state, 'Ahmet Yılmaz', 'Arama Kurtarma', 'ENKAZ-A1', 4, ShiftStatus.active),
        _buildLeaderAssignmentCard(state, 'Mehmet Serkan Ö.', 'Lojistik', 'A-14 Lojistik Sahası', 4, ShiftStatus.pendingLeaderApproval),
        _buildLeaderAssignmentCard(state, 'Ayşe Korkmaz', 'İlk Yardım', 'SAHRA-1', 6, ShiftStatus.waiting),
      ],
    );
  }

  Widget _buildLeaderAssignmentCard(AppState state, String name, String role, String sector, int hours, ShiftStatus status) {
    String statusStr = '';
    Color statusColor = AppColors.textSecondary;
    if (status == ShiftStatus.active) {
      statusStr = 'Aktif Görevde';
      statusColor = AppColors.kozaGreen;
    } else if (status == ShiftStatus.pendingLeaderApproval) {
      statusStr = 'Onay Bekliyor';
      statusColor = AppColors.warningOrange;
    } else {
      statusStr = 'Bekliyor';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(statusStr, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Rol: $role", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sektör / Bölge", style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                      Text(sector, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Saat", style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                      Text("$hours Saat", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == ShiftStatus.pendingLeaderApproval)
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vardiya bitişi onaylandı.'), backgroundColor: AppColors.kozaGreen));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
                    child: const Text('Bitişi Onayla', style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: () {
                      _showUpdateAssignmentDialog(context, name, sector, hours);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.infoBlue),
                    child: const Text('Güncelle', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showUpdateAssignmentDialog(BuildContext context, String volunteerName, String currentSector, int currentHours) {
    final sectorController = TextEditingController(text: currentSector);
    final hoursController = TextEditingController(text: currentHours.toString());
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('$volunteerName - Vardiya Güncelle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sectorController,
                decoration: const InputDecoration(labelText: 'Sektör / Bölge'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vardiya Süresi (Saat)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                final newSector = sectorController.text;
                final newHours = int.tryParse(hoursController.text) ?? currentHours;
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$volunteerName ataması güncellendi: $newSector, $newHours Saat'), backgroundColor: AppColors.kozaGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCircularTimer(ShiftAssignment assignment, bool isCompleted) {
    final remaining = assignment.remainingSeconds;
    final progress = assignment.progress;
    final isActive = assignment.isActive && remaining > 0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? AppColors.textHint : AppColors.kozaGreen).withAlpha(isActive ? 30 : 10),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _CircularTimerPainter(
                      progress: isCompleted ? 1.0 : progress,
                      activeColor: isCompleted ? AppColors.textSecondary : AppColors.kozaGreen,
                      bgColor: (isCompleted ? AppColors.textHint : AppColors.kozaGreen).withAlpha(25),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(isCompleted ? 0 : remaining),
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${assignment.durationHours.toString().padLeft(2, '0')}:00 SAAT KALAN',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.inputBg : AppColors.kozaGreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isCompleted ? AppColors.textHint : AppColors.kozaGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? 'Tamamlandı' : 'Canlı Vardiya',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isCompleted ? AppColors.textSecondary : AppColors.kozaGreen),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveZoneCard(ShiftAssignment assignment) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.kozaGreenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_on, color: AppColors.kozaGreen, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.sectorName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  'Lider: ${assignment.leaderName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.kozaGreenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'AKTİF',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.kozaGreen, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionCard({required String name, required String role, required bool isOnline}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person, color: AppColors.textSecondary, size: 24),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.kozaGreen : AppColors.textHint,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.settings_input_antenna, size: 18, color: AppColors.kozaGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildEndShiftButton(AppState state, ShiftAssignment assignment) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            assignment.complete();
          });
          
          // Puan Hesaplama: (Süre * 10) puan varsayımı
          final earnedPoints = assignment.durationHours * 10;
          final currentProfile = state.volunteerProfile;
          state.updateVolunteerProfile(currentProfile.copyWith(
            totalShiftHours: currentProfile.totalShiftHours + assignment.durationHours,
          ));
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vardiya sonlandırıldı. $earnedPoints yetkinlik puanı eklendi. Lider paneline bildirim gönderildi.'),
              backgroundColor: AppColors.darkBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBg,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_circle_outlined, size: 22),
            SizedBox(width: 10),
            Text(
              'VARDİYAYI BİTİR',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    );
  }
}

// ─── Circular Timer Custom Painter ────────────────────────────────────────
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color bgColor;

  _CircularTimerPainter({required this.progress, required this.activeColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) => oldDelegate.progress != progress;
}
