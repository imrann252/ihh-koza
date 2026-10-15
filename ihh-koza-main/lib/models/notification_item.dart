// ─── Bildirim Türleri ─────────────────────────────────────────────────────────
enum NotificationType { alarmCall, voiceMessage, training, general, report }

// ─── Bildirim Veri Modeli ─────────────────────────────────────────────────────
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? audioBase64; // Sesli mesajlar için

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.audioBase64,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? audioBase64,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      audioBase64: audioBase64 ?? this.audioBase64,
    );
  }

  /// Ekranda gösterilecek zaman damgası
  String get timeLabel {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }

  bool get isAlarm => type == NotificationType.alarmCall;
  bool get isVoice => type == NotificationType.voiceMessage;
}
