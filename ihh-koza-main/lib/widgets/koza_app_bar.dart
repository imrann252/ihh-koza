import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/notification_panel.dart';

/// Tüm sekmelerde tekrar eden ortak AppBar bileşeni
/// Güncellendi: Logout butonu (profil alanı), aktif bildirim paneli
class KozaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogout;

  const KozaAppBar({
    super.key,
    this.title = 'KOZA - GÖNÜLLÜ',
    this.actions,
    this.showLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.maybeOf(context);
    final unreadCount = state?.unreadCount ?? 0;

    return AppBar(
      backgroundColor: AppColors.kozaGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: showLogout
          ? GestureDetector(
              onTap: () {
                final session = state?.session;
                showLogoutDialog(
                  context,
                  displayName: session?.displayName ?? 'Kullanıcı',
                  role: _roleLabel(session?.role),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_outline, size: 22, color: Colors.white),
                ),
              ),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ],
      ),
      actions: actions ??
          [
            // Mesaj Kutusu (Gönderilen Ses Kayıtları)
            IconButton(
              icon: const Icon(Icons.mail_outline, size: 26),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    final sentList = state?.sentMessages ?? [];
                    return AlertDialog(
                      title: const Text('Gönderilen Ses Kayıtları (Outbox)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: sentList.isEmpty
                            ? const Center(child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('Gönderilmiş sesli mesaj bulunmuyor.', style: TextStyle(color: AppColors.textSecondary)),
                              ))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: sentList.length,
                                itemBuilder: (context, idx) {
                                  final msg = sentList[idx];
                                  final dt = msg['timestamp'] as DateTime;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const CircleAvatar(child: Icon(Icons.mic, color: AppColors.kozaGreen)),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Hedef: ${msg['target']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: msg['status'] == 'Beklemede' ? Colors.orange.shade50 : Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: msg['status'] == 'Beklemede' ? Colors.orange : Colors.green),
                                            ),
                                            child: Text(
                                              msg['status'] == 'Beklemede' ? 'Beklemede' : 'Gönderildi',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: msg['status'] == 'Beklemede' ? Colors.orange.shade900 : Colors.green.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text('Süre: ${msg['duration']} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.play_arrow, color: AppColors.kozaGreen),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ses kaydı çalınıyor (simüle)...')),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
                      ],
                    );
                  },
                );
              },
            ),
            // Bildirim ikonu — tıklanınca Drawer açılır
            Builder(
              builder: (ctx) => IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, size: 26),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.sosRed,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.gonullu:
        return 'Gönüllü';
      case UserRole.ekipLideri:
        return 'Ekip Lideri';
      case UserRole.genelMerkez:
        return 'Genel Merkez';
      case null:
        return 'Kullanıcı';
    }
  }
}
