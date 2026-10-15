// MANTIK HATASI (DÜZELTİLDİ): Önceki tasarımda her ekranın kendi state'i vardı;
// kullanıcı rolü ve oturum bilgisi ekranlar arası aktarılmıyordu.
// Çözüm: Tek merkezi AppState ile InheritedWidget pattern.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/shift_assignment.dart';
import '../models/notification_item.dart';
import '../models/volunteer_profile.dart';
import '../constants/il_listesi.dart';

// ─── Global Konfigürasyon (Web/Mobil Entegrasyon) ───────────────────────────
class AppConfig {
  static String get backendUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://192.168.1.121:8080';
  }
}

// ─── Kullanıcı Rolleri (global erişim için buraya taşındı) ────────────────────
enum UserRole { gonullu, ekipLideri, genelMerkez }

// ─── SOS Hedef Seçenekleri ────────────────────────────────────────────────────
enum SosTarget { genelMerkez, ekipLideri, gonulluler }

// ─── Yardımcı Modeller (HQ & Lider için) ───────────────────────────────────────
class HqVolunteer {
  final String name;
  final String specialty;
  final String bloodType;
  final List<String> certificates;
  final String healthStatus;
  final List<Map<String, dynamic>> examRecords; // Sınav Kayıtları

  HqVolunteer({
    required this.name,
    required this.specialty,
    required this.bloodType,
    required this.certificates,
    required this.healthStatus,
    this.examRecords = const [
      {'name': 'Temel Afet Müdahale', 'score': 90, 'date': '2025-02-10', 'status': 'Başarılı'},
      {'name': 'İlkyardım Temel', 'score': 85, 'date': '2025-03-12', 'status': 'Başarılı'},
    ],
  });
}

class HqTeamCall {
  final String leaderName;
  final String sector;
  final String location;
  final int workHours;
  final List<HqVolunteer> volunteers;

  HqTeamCall({
    required this.leaderName,
    required this.sector,
    required this.location,
    required this.workHours,
    required this.volunteers,
  });
}

class ActiveDisaster {
  final String id;
  final String name;
  final String category;
  final String location;
  final String severity;
  int savedCount;
  int injuredCount;
  int deceasedCount;
  final List<HqTeamCall> assignedTeams;

  ActiveDisaster({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.severity,
    this.savedCount = 0,
    this.injuredCount = 0,
    this.deceasedCount = 0,
    required this.assignedTeams,
  });
}

class HqTeamInfo {
  final String cityName;
  final String districtName;
  final String teamName;
  final String leaderName;
  final int memberCount;
  final String status;
  final List<HqVolunteer> members;

  HqTeamInfo({
    required this.cityName,
    required this.districtName,
    required this.teamName,
    required this.leaderName,
    required this.memberCount,
    required this.status,
    required this.members,
  });

  HqTeamInfo copyWith({
    String? status,
    List<HqVolunteer>? members,
  }) {
    return HqTeamInfo(
      cityName: cityName,
      districtName: districtName,
      teamName: teamName,
      leaderName: leaderName,
      memberCount: members?.length ?? memberCount,
      status: status ?? this.status,
      members: members ?? this.members,
    );
  }
}

// ─── Uygulama Oturumu Modeli ──────────────────────────────────────────────────
class AppSession {
  final String userId;
  final String displayName;
  final UserRole role;
  final String email;

  const AppSession({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.email,
  });

  bool get isLeader => role == UserRole.ekipLideri;
  bool get isHQ => role == UserRole.genelMerkez;
  bool get isVolunteer => role == UserRole.gonullu;
}

// ─── Ana State Yöneticisi ─────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // Oturum
  AppSession? _session;
  AppSession? get session => _session;
  bool get isLoggedIn => _session != null;
  UserRole? get currentRole => _session?.role;

  // 81 ilin varsayılan ekipleri
  late final List<HqTeamInfo> _allTeams;
  List<HqTeamInfo> get allTeams => _allTeams;

  // Aktif afetler listesi
  final List<ActiveDisaster> _activeDisasters = [];
  List<ActiveDisaster> get activeDisasters => _activeDisasters;

  // Gönderilen sesli mesaj outbox'ı
  final List<Map<String, dynamic>> _sentMessages = [];
  List<Map<String, dynamic>> get sentMessages => _sentMessages;

  // Eğitimler Takvimi (gg/aa/yyyy bazlı)
  final List<Map<String, dynamic>> _publishedTrainings = [
    {
      'id': 'E001',
      'baslik': 'Temel Afet Müdahale',
      'egitmen': 'Dr. Mustafa Öztürk',
      'tarih': '20/07/2026',
      'saat': '09:00',
      'bitisSaat': '17:00',
      'sure': '8',
    }
  ];
  List<Map<String, dynamic>> get publishedTrainings => _publishedTrainings;

  // Vardiya atama (lider tarafından gönderilen)
  ShiftAssignment? _shiftAssignment;
  ShiftAssignment? get shiftAssignment => _shiftAssignment;

  // Bildirim listesi
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'N001',
      title: 'Ekip Lideri Çağrısı',
      body: 'Deprem bölgesi — Sektör 4B için acil gönüllü çağrısı!',
      type: NotificationType.alarmCall,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationItem(
      id: 'N002',
      title: 'Eğitim Daveti',
      body: 'Temel Afet Müdahale Eğitimi — 20 Temmuz Pazar 09:00',
      type: NotificationType.training,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: 'N003',
      title: 'Sesli Mesaj',
      body: 'Ekip Lideri Ahmet Bey\'den sesli mesaj var.',
      type: NotificationType.voiceMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationItem(
      id: 'N004',
      title: 'Genel Duyuru',
      body: 'Tüm gönüllülerin görev kartları güncellendi. Lütfen kontrol edin.',
      type: NotificationType.general,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Gönüllü Profili
  VolunteerProfile _volunteerProfile = VolunteerProfile.mock();
  VolunteerProfile get volunteerProfile => _volunteerProfile;

  AppState() {
    // 81 il için default ekipler oluşturuluyor
    _allTeams = TurkeyIlListesi.iller.map((city) {
      return HqTeamInfo(
        cityName: city,
        districtName: 'Merkez',
        teamName: 'Koza-$city',
        leaderName: '$city İl Bşk.',
        memberCount: 5,
        status: 'Dinlenmede',
        members: List.generate(5, (index) => HqVolunteer(
          name: '$city Gönüllü ${index + 1}',
          specialty: index % 2 == 0 ? 'Arama Kurtarma' : 'Lojistik',
          bloodType: 'A Rh+',
          certificates: const ['AFAD Temel', 'İlk Yardım Eğitimi'],
          healthStatus: 'Sağlıklı / Uygun'
        )),
      );
    }).toList();

    // Default aktif bir afet ekleyelim (Hatay Depremi)
    final hatayIdx = _allTeams.indexWhere((t) => t.cityName.toLowerCase() == 'hatay');
    if (hatayIdx != -1) {
      final team = _allTeams[hatayIdx];
      _allTeams[hatayIdx] = team.copyWith(status: 'Afette Görevde');
      
      _activeDisasters.add(ActiveDisaster(
        id: 'DIS_INIT_HATAY',
        name: 'Hatay Defne Deprem Arama Kurtarma Operasyonu',
        category: 'Deprem Arama Kurtarma',
        location: 'Hatay Defne',
        severity: 'Ağır',
        savedCount: 24,
        injuredCount: 15,
        deceasedCount: 2,
        assignedTeams: [
          HqTeamCall(
            leaderName: team.leaderName,
            sector: 'Kırıkhan Göçüğü',
            location: 'Hatay Kırıkhan',
            workHours: 12,
            volunteers: team.members,
          ),
          HqTeamCall(
            leaderName: team.leaderName,
            sector: 'Antakya Depo Çadırı',
            location: 'Hatay Antakya',
            workHours: 8,
            volunteers: team.members,
          ),
          HqTeamCall(
            leaderName: team.leaderName,
            sector: 'Defne Lojistik Üssü',
            location: 'Hatay Defne',
            workHours: 16,
            volunteers: team.members,
          ),
        ],
      ));
    }
  }

  // ─── Oturum Açma ───────────────────────────────────────────────────────────
  void login(String userId, String email, UserRole role) {
    final displayName = _getDisplayName(userId, role);
    _session = AppSession(
      userId: userId,
      displayName: displayName,
      role: role,
      email: email,
    );

    // Rol bazlı mock vardiya ataması
    if (role == UserRole.gonullu) {
      _shiftAssignment = ShiftAssignment(
        sectorCode: 'A-14',
        sectorName: 'A-14 Lojistik Sahası',
        startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        durationHours: 4,
        leaderName: 'Ekip Lideri Ahmet Bey',
        status: ShiftStatus.active,
      );
    }

    notifyListeners();
  }

  String _getDisplayName(String userId, UserRole role) {
    switch (role) {
      case UserRole.gonullu:
        return 'Ahmet Yılmaz';
      case UserRole.ekipLideri:
        return 'Hatay İl Başkanı';
      case UserRole.genelMerkez:
        return 'Genel Merkez Yöneticisi';
    }
  }

  // ─── Oturum Kapatma (Güvenli Çıkış) ───────────────────────────────────────
  void logout() {
    _session = null;
    _shiftAssignment = null;
    notifyListeners();
  }

  // ─── Vardiya Güncelleme (Liderden Gönüllüye) ───────────────────────────────
  void updateShiftAssignment(ShiftAssignment assignment) {
    _shiftAssignment = assignment;
    // Alarm bildirimi ekle
    _addNotification(NotificationItem(
      id: 'SHIFT_${DateTime.now().millisecondsSinceEpoch}',
      title: '🔔 Yeni Vardiya Ataması!',
      body: '${assignment.sectorName} — ${assignment.durationHours} saat. Lider: ${assignment.leaderName}',
      type: NotificationType.alarmCall,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }

  // ─── Bildirim Okundu İşareti ───────────────────────────────────────────────
  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void _addNotification(NotificationItem item) {
    _notifications.insert(0, item);
  }

  void addSosNotification(SosTarget target, String audioPath, {String duration = '00:15'}) {
    final targetName = _sosTargetLabel(target);
    _addNotification(NotificationItem(
      id: 'SOS_${DateTime.now().millisecondsSinceEpoch}',
      title: '🆘 SOS Mesajı Gönderildi',
      body: 'Hedef: $targetName — Ses kaydı kuryeye mühürlendi.',
      type: NotificationType.voiceMessage,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    // Gönderilen ses kutusuna kaydet
    addSentMessage(targetName, audioPath, duration);
    notifyListeners();
  }

  // ─── Gönderilen Mesaj Kayıtları ─────────────────────────────────────────────
  void addSentMessage(String target, String filePath, String duration) {
    _sentMessages.insert(0, {
      'target': target,
      'filePath': filePath,
      'duration': duration,
      'timestamp': DateTime.now(),
      'status': 'Beklemede',
    });
    notifyListeners();
  }

  void markMessagesAsSent() {
    for (var msg in _sentMessages) {
      if (msg['status'] == 'Beklemede') {
        msg['status'] = 'Gönderildi';
      }
    }
    notifyListeners();
  }

  // ─── Afet Başlat ve Çağrı Yap ──────────────────────────────────────────────
  void startDisaster({
    required String category,
    required String location,
    required String severity,
  }) {
    final id = 'DIS_${DateTime.now().millisecondsSinceEpoch}';
    
    // Bölge ve kritikliği belirlendikten sonra otomatik isimlendirme
    final name = '$location $severity Seviyeli ${category.replaceAll('Arama Kurtarma', 'Operasyonu')}';

    // Konumdan ili bulmaya çalış (varsayılan: Hatay)
    String baseIl = 'Hatay';
    for (var il in TurkeyIlListesi.iller) {
      if (location.toLowerCase().contains(il.toLowerCase())) {
        baseIl = il;
        break;
      }
    }

    // Afet boyutuna göre çağrı yapılacak çevre il sayısı belirleniyor
    int radius = 2;
    if (severity == 'Hafif') radius = 1;
    if (severity == 'Orta') radius = 2;
    if (severity == 'Ağır') radius = 4;
    if (severity == 'Katastrofik') radius = 8;

    final nearbyIller = TurkeyIlListesi.getNearbyIller(baseIl, radius: radius);
    final targetIller = [baseIl, ...nearbyIller];

    final List<HqTeamCall> assigned = [];
    for (var il in targetIller) {
      final teamIdx = _allTeams.indexWhere((t) => t.cityName.toLowerCase() == il.toLowerCase());
      if (teamIdx != -1) {
        final team = _allTeams[teamIdx];
        _allTeams[teamIdx] = team.copyWith(status: 'Afet Çağrısı Yapıldı');
        
        assigned.add(HqTeamCall(
          leaderName: team.leaderName,
          sector: 'SEKTÖR-${il.toUpperCase().substring(0, 3)}',
          location: location,
          workHours: 12,
          volunteers: team.members,
        ));

        // Ekip liderine bildirim gönder
        _addNotification(NotificationItem(
          id: 'LID_CALL_${id}_$il',
          title: '🚨 AFET GÖREVLENDİRME ÇAĞRISI',
          body: '$name için ekibiniz göreve çağrılmıştır. Lütfen üyelerinize davet gönderin.',
          type: NotificationType.alarmCall,
          timestamp: DateTime.now(),
          isRead: false,
        ));
      }
    }

    final newDisaster = ActiveDisaster(
      id: id,
      name: name,
      category: category,
      location: location,
      severity: severity,
      injuredCount: 15,
      deceasedCount: 0,
      assignedTeams: assigned,
    );

    _activeDisasters.insert(0, newDisaster);

    // Gönüllülere genel bildirim
    _addNotification(NotificationItem(
      id: 'VOL_CALL_$id',
      title: '🔔 Güncel Afet Çağrısı: $name',
      body: 'Yeni afet operasyonu başlatılmıştır. Liderlerinizden davet bekleyin.',
      type: NotificationType.alarmCall,
      timestamp: DateTime.now(),
      isRead: false,
    ));

    notifyListeners();
  }

  void updateDisasterStats(String id, {int? savedDelta, int? injuredDelta, int? deceasedDelta}) {
    final idx = _activeDisasters.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final old = _activeDisasters[idx];
      int newSaved = old.savedCount;
      if (savedDelta != null) {
        newSaved = (old.savedCount + savedDelta).clamp(0, 99999);
      }
      int newInjured = old.injuredCount;
      if (injuredDelta != null) {
        newInjured = (old.injuredCount + injuredDelta).clamp(0, 99999);
      }
      int newDeceased = old.deceasedCount;
      if (deceasedDelta != null) {
        newDeceased = (old.deceasedCount + deceasedDelta).clamp(0, 99999);
      }
      _activeDisasters[idx] = ActiveDisaster(
        id: old.id,
        name: old.name,
        category: old.category,
        location: old.location,
        severity: old.severity,
        savedCount: newSaved,
        injuredCount: newInjured,
        deceasedCount: newDeceased,
        assignedTeams: old.assignedTeams,
      );
      notifyListeners();
    }
  }

  void addDisasterReportData(String sectorName, {required int saved, required int injured, required int deceased}) {
    int idx = _activeDisasters.indexWhere((d) => 
      d.assignedTeams.any((t) => t.sector.toLowerCase() == sectorName.toLowerCase())
    );
    if (idx == -1 && _activeDisasters.isNotEmpty) {
      idx = 0;
    }
    if (idx != -1) {
      final old = _activeDisasters[idx];
      _activeDisasters[idx] = ActiveDisaster(
        id: old.id,
        name: old.name,
        category: old.category,
        location: old.location,
        severity: old.severity,
        savedCount: old.savedCount + saved,
        injuredCount: old.injuredCount + injured,
        deceasedCount: old.deceasedCount + deceased,
        assignedTeams: old.assignedTeams,
      );
      notifyListeners();
    }
  }

  // ─── Eğitim Bildirimi Ekle ──────────────────────────────────────────────────
  void addTrainingNotification(String category, String date, String time, String instructor, String duration) {
    // Takvim veri yapısına ekle
    final id = 'TR_${DateTime.now().millisecondsSinceEpoch}';
    final parts = time.split(':');
    int startHour = 9;
    if (parts.isNotEmpty) startHour = int.tryParse(parts[0]) ?? 9;
    int durationHours = int.tryParse(duration) ?? 4;
    int endHour = (startHour + durationHours).clamp(0, 24);

    _publishedTrainings.insert(0, {
      'id': id,
      'baslik': '$category Eğitimi',
      'egitmen': instructor,
      'tarih': date,
      'saat': time,
      'bitisSaat': '${endHour.toString().padLeft(2, '0')}:00',
      'sure': duration,
    });

    // Liderlere ve Gönüllülere bildirim
    _addNotification(NotificationItem(
      id: 'TRAINING_$id',
      title: '📚 Yeni Eğitim Yayınlandı: $category',
      body: 'Eğitmen: $instructor\nTarih: $date $time (Süre: $duration Saat)',
      type: NotificationType.training,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }

  String _sosTargetLabel(SosTarget target) {
    switch (target) {
      case SosTarget.genelMerkez:
        return 'Genel Merkez';
      case SosTarget.ekipLideri:
        return 'Ekip Lideri';
      case SosTarget.gonulluler:
        return 'Tüm Gönüllüler';
    }
  }

  // ─── Profil Güncelleme ─────────────────────────────────────────────────────
  void updateVolunteerProfile(VolunteerProfile profile) {
    _volunteerProfile = profile;
    notifyListeners();
  }
}

// ─── InheritedWidget Sarmalayıcı ──────────────────────────────────────────────
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'AppStateProvider bulunamadı. main.dart\'a eklendiğinden emin olun.');
    return provider!.notifier!;
  }

  static AppState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()?.notifier;
  }
}
