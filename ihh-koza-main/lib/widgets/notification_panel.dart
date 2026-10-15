import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/notification_item.dart';
import '../state/app_state.dart';

/// Bildirim Paneli — AppBar bildirim ikonu tıklandığında açılan Drawer
class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final notifications = state.notifications;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Panel Başlığı ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.kozaGreen,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bildirimler',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Çağrılar, duyurular ve sesli mesajlar',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => state.markAllRead(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(30),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tümünü Oku', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // ─── Okunmamış sayısı ──────────────────────────────
            if (state.unreadCount > 0)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.sosRedLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sosRed.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: AppColors.sosRed, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${state.unreadCount} okunmamış bildirim',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.sosRed),
                    ),
                  ],
                ),
              ),

            // ─── Bildirim Listesi ──────────────────────────────
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_outlined, size: 48, color: AppColors.textHint),
                          SizedBox(height: 8),
                          Text('Bildirim yok', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: notifications.length,
                      itemBuilder: (_, i) {
                        final n = notifications[i];
                        return _NotificationTile(
                          item: n,
                          onTap: () => state.markNotificationRead(n.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color, bgColor) = _iconForType(item.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : color.withAlpha(8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? AppColors.divider : color.withAlpha(50),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(item.timeLabel, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.alarmCall:
        return (Icons.crisis_alert_rounded, AppColors.sosRed, AppColors.sosRedLight);
      case NotificationType.voiceMessage:
        return (Icons.mic_rounded, AppColors.infoBlue, AppColors.infoBlueBg);
      case NotificationType.training:
        return (Icons.school_outlined, AppColors.kozaGreen, AppColors.kozaGreenLight);
      case NotificationType.report:
        return (Icons.assignment_outlined, AppColors.warningOrange, const Color(0xFFFFF3E0));
      case NotificationType.general:
        return (Icons.campaign_outlined, AppColors.textSecondary, AppColors.inputBg);
    }
  }
}
