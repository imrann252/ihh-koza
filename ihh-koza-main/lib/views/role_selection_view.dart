import 'package:flutter/material.dart';
import 'hq_screen.dart';
import 'leader_map_screen.dart';
import 'main_shell.dart';
import 'login_view.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
            label: const Text("Çıkış Yap", style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/koza_pine_cone_logo.png',
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(Icons.crisis_alert, size: 70, color: Colors.amber),
                ),
                const SizedBox(height: 16),
                const Text(
                  "İHH KOZA",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Afet Yönetim ve Gönüllü Koordinasyon Sistemi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 36),
                
                // 1. ROL: GÖNÜLLÜ
                _buildRoleCard(
                  context,
                  title: "Gönüllü Paneli",
                  subtitle: "Saha veri girişi, enkaz bildirimi (Offline Mod)",
                  icon: Icons.person_pin_circle_outlined,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainShell())),
                ),
                const SizedBox(height: 16),

                // 2. ROL: EKİP LİDERİ
                _buildRoleCard(
                  context,
                  title: "Ekip Lideri Paneli",
                  subtitle: "Saha haritası, ekip takibi & veri senkronizasyonu",
                  icon: Icons.alt_route,
                  color: Colors.amber,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderMapScreen())),
                ),
                const SizedBox(height: 16),

                // 3. ROL: GENEL MERKEZ
                _buildRoleCard(
                  context,
                  title: "Genel Merkez (HQ)",
                  subtitle: "Afet kriz haritası, canlı istatistikler ve yönetim",
                  icon: Icons.dashboard_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HqScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}