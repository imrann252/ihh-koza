import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../views/login_view.dart';

/// Güvenli Çıkış Dialog'u
/// Tüm rollerde AppBar profil alanına basıldığında gösterilir.
/// Session temizleyerek LoginView'a temiz yönlendirme yapar.
class LogoutDialog extends StatelessWidget {
  final String displayName;
  final String role;

  const LogoutDialog({
    super.key,
    required this.displayName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.kozaGreenLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.kozaGreen.withAlpha(80), width: 2),
              ),
              child: const Icon(Icons.person, size: 40, color: AppColors.kozaGreen),
            ),
            const SizedBox(height: 14),
            Text(
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.kozaGreenLight, borderRadius: BorderRadius.circular(8)),
              child: Text(role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.kozaGreen)),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Çıkış uyarısı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warningOrange.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Çıkış yapıldığında tüm yerel oturum verileri temizlenir. Senkronize edilmemiş veriler korunur.',
                      style: TextStyle(fontSize: 11, color: AppColors.warningOrange, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Vazgeç', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Oturumu temizle
                      AppState? state;
                      try {
                        state = AppStateProvider.maybeOf(context);
                      } catch (_) {}
                      state?.logout();

                      // Temiz yönlendirme — tüm route stack temizlenir
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sosRed,
                      foregroundColor: Colors.white,
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
    );
  }
}

/// Kolay açma helper
void showLogoutDialog(BuildContext context, {required String displayName, required String role}) {
  showDialog(
    context: context,
    builder: (_) => LogoutDialog(displayName: displayName, role: role),
  );
}
