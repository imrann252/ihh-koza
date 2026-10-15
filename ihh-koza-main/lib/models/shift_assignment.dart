// ─── Vardiya Durumları ────────────────────────────────────────────────────────
enum ShiftStatus { waiting, active, completed, pendingLeaderApproval }

// ─── Vardiya Atama Modeli ──────────────────────────────────────────────────────
class ShiftAssignment {
  final String sectorCode;
  final String sectorName;
  final DateTime startTime;
  final int durationHours; // Toplam vardiya süresi (saat)
  final String leaderName;
  ShiftStatus status;

  ShiftAssignment({
    required this.sectorCode,
    required this.sectorName,
    required this.startTime,
    required this.durationHours,
    required this.leaderName,
    this.status = ShiftStatus.waiting,
  });

  /// Kalan saniye (negatifse sıfır)
  int get remainingSeconds {
    final endTime = startTime.add(Duration(hours: durationHours));
    final diff = endTime.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  /// Toplam saniye
  int get totalSeconds => durationHours * 3600;

  /// İlerleme oranı (0.0 - 1.0)
  double get progress {
    if (totalSeconds == 0) return 0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  bool get isActive => status == ShiftStatus.active;
  bool get isCompleted => status == ShiftStatus.completed;

  void complete() {
    status = ShiftStatus.pendingLeaderApproval;
  }
}
