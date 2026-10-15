import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../services/hive_service.dart';

/// SOS Hedef Seçim ve Ses Kayıt Dialog'u
/// SOS FAB'a basılı tutulduğunda açılır; kullanıcı kime gönderileceğini seçer ve kaydı burada tamamlar.
class SosTargetDialog extends StatefulWidget {
  const SosTargetDialog({super.key});

  @override
  State<SosTargetDialog> createState() => _SosTargetDialogState();
}

class _SosTargetDialogState extends State<SosTargetDialog>
    with TickerProviderStateMixin {
  SosTarget? _selectedTarget;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  // Recording State
  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _scaleCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_selectedTarget == null) return;
    try {
      _elapsedSeconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isRecording && !_isPaused) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });
      _pulseCtrl.repeat(reverse: true);
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
    } catch (e) {
      print("Kayıt başlatılamadı, simülasyon modu aktif: $e");
    }
  }

  Future<void> _togglePause() async {
    try {
      if (_isPaused) {
        _pulseCtrl.repeat(reverse: true);
        setState(() => _isPaused = false);
      } else {
        _pulseCtrl.stop();
        setState(() => _isPaused = true);
      }
    } catch (e) {
      print("Duraklatma hatası: $e");
      setState(() => _isPaused = !_isPaused);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _finishRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    String path = 'web_simulated_sos_${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    if (mounted) {
      final targetSector = _selectedTarget == SosTarget.genelMerkez ? 'HQ' : 
                           _selectedTarget == SosTarget.ekipLideri ? 'LEADER' : 'TEAM';
      try {
        await HiveService.saveLogOffline(
          sectorId: 'SOS-$targetSector',
          audioPath: path,
          status: 'Kritik',
        );
      } catch (e) {
        print("Hive offline kaydetme hatası: $e");
      }
      
      final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
      final timerText = '$minutes:$seconds';

      try {
        AppStateProvider.of(context).addSosNotification(_selectedTarget!, path, duration: timerText);
      } catch (e) {
        print("Notification ekleme hatası: $e");
      }

      print("Lokal veri paketi mühürlendi, merkeze aktarılmaya hazır");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Lokal veri paketi mühürlendi, merkeze aktarılmaya hazır'),
              ),
            ],
          ),
          backgroundColor: AppColors.kozaGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    final timerText = '$minutes:$seconds';

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Kısım / Pulse
              _isRecording ? _buildPulseIndicator() : _buildHeaderIcon(),
              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? (_isPaused ? 'Ses Kaydı Durduruldu' : 'Ses Kaydediliyor...')
                    : 'SOS Mesajı Gönder',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                _isRecording
                    ? 'Ses kaydınız hazırlanıyor. Kapatmayın.'
                    : 'Sesli mesajınızı kime iletmek istiyorsunuz?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Seçenekler (Eğer kayıt varsa devre dışı bırakılır)
              IgnorePointer(
                ignoring: _isRecording,
                child: Opacity(
                  opacity: _isRecording ? 0.6 : 1.0,
                  child: Column(
                    children: [
                      _buildTargetOption(
                        target: SosTarget.genelMerkez,
                        icon: Icons.hub_outlined,
                        title: 'Genel Merkez',
                        subtitle: 'İHH Operasyon Koordinasyon',
                      ),
                      const SizedBox(height: 10),
                      _buildTargetOption(
                        target: SosTarget.ekipLideri,
                        icon: Icons.supervisor_account_outlined,
                        title: 'Ekip Lideri',
                        subtitle: 'Bağlı bulunduğunuz lider',
                      ),
                      const SizedBox(height: 10),
                      _buildTargetOption(
                        target: SosTarget.gonulluler,
                        icon: Icons.groups_outlined,
                        title: 'Tüm Gönüllüler',
                        subtitle: 'Ekipteki tüm üyeler',
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_isRecording) ...[
                const SizedBox(height: 16),
                Text(
                  timerText,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.sosRed, fontFamily: 'monospace'),
                ),
              ],
              
              const SizedBox(height: 24),

              // Alt Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRecording ? _cancelRecording : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _togglePause,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 16),
                        label: Text(_isPaused ? 'Devam' : 'Durdur', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPaused ? AppColors.kozaGreen : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedTarget == null
                          ? null
                          : (_isRecording ? _finishRecording : _startRecording),
                      icon: Icon(_isRecording ? Icons.check : Icons.mic_rounded, size: 18),
                      label: Text(_isRecording ? 'Kaydı Bitir' : 'Kaydı Başlat', style: const TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sosRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.divider,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.sosRedLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.sos_rounded, color: AppColors.sosRed, size: 32),
    );
  }

  Widget _buildPulseIndicator() {
    if (_isPaused) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pause, color: Colors.grey, size: 28),
      );
    }
    
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final double scale = 1.0 + (_pulseCtrl.value * 0.15);
        return Container(
          width: 60 * scale,
          height: 60 * scale,
          decoration: BoxDecoration(
            color: AppColors.sosRed.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.sosRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetOption({
    required SosTarget target,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedTarget == target;
    return GestureDetector(
      onTap: () => setState(() => _selectedTarget = target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sosRedLight : AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.sosRed : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.sosRed.withAlpha(25) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.sosRed : AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? AppColors.sosRed : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.sosRed, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Kolay kullanım için static helper
Future<void> showSosTargetDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const SosTargetDialog(),
  );
}
