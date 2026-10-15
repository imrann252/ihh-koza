import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/sos_target_dialog.dart';
import 'cagrilar_view.dart';
import 'profil_view.dart';
import 'harita_view.dart';
import 'vardiya_view.dart';

// MANTIK HATASI (DÜZELTİLDİ): _pages listesi const olduğu için state güncellemeleri
// (özellikle InheritedWidget olan AppState'in notifyListeners ile değişimi)
// sayfalara yansımıyordu. Ayrıca DuyuruView yerine CagrilarView getirildi.

/// Ana navigation iskeleti — Bottom Nav Bar + merkezi SOS butonu
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // const KULLANILMIYOR
  final List<Widget> _pages = [
    const VardiyaView(),
    const CagrilarView(), // Güncellenen sayfa
    const SizedBox(), // SOS ortadaki FAB — placeholder
    const HaritaView(),
    const ProfilView(),
  ];

  Future<void> _handleSOSPress() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS mesajı göndermek için butona basılı tutun ve hedef seçin.'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSOSLongPress() async {
    await showSosTargetDialog(context);
  }

  void _onTabTapped(int index) {
    if (index == 2) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // ─── SOS FAB ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        heroTag: 'gonullu_sos_fab',
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
      // ─── Bottom Navigation Bar ─────────────────────────────
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 12,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.access_time_rounded, 'Vardiya'),
            _buildNavItem(1, Icons.crisis_alert_rounded, 'Çağrılar'), // İkon ve text değişti
            const SizedBox(width: 56), // SOS FAB boşluğu
            _buildNavItem(3, Icons.map_outlined, 'Harita'),
            _buildNavItem(4, Icons.person_outline, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.kozaGreen : AppColors.textHint,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.kozaGreen : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
