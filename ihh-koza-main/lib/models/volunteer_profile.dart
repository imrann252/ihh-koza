// ─── Sertifika Modeli ─────────────────────────────────────────────────────────
class Certificate {
  final String id;
  final String name;
  final String issueDate;
  final double score; // 0.0 - 100.0

  const Certificate({
    required this.id,
    required this.name,
    required this.issueDate,
    required this.score,
  });
}

// ─── Gönüllü Profil Modeli ────────────────────────────────────────────────────
class VolunteerProfile {
  final String id;
  final String fullName;
  final int age;
  final String bloodType;
  final String phone;
  final String emergencyContact;
  final String emergencyPhone;
  final String city;
  final String district;
  final String address;
  final String profession;
  final String specialty;
  final int institutionYears; // Kurumda geçirilen yıl
  final int totalShiftHours;  // Toplam vardiya saati
  final List<Certificate> certificates;
  final List<Map<String, dynamic>> examRecords; // Sınav kayıtları
  final bool isActive;

  const VolunteerProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.bloodType,
    required this.phone,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.city,
    required this.district,
    required this.address,
    required this.profession,
    required this.specialty,
    required this.institutionYears,
    required this.totalShiftHours,
    required this.certificates,
    required this.examRecords,
    required this.isActive,
  });

  /// Dinamik Gönüllü Yetkinlik Puanı
  /// Formül: (Sertifika sayısı × 20) + (Aktiflik × 10) + (Kurum yılı × 5) + (Vardiya saati × 0.5)
  /// Max: 100 puan (normalize edilmiş)
  double get competencyScore {
    double raw = (certificates.length * 20.0) +
        (isActive ? 10.0 : 0.0) +
        (institutionYears * 5.0) +
        (totalShiftHours * 0.5);
    return raw.clamp(0, 100);
  }

  int get competencyScoreInt => competencyScore.toInt();

  VolunteerProfile copyWith({
    String? city,
    String? district,
    String? address,
    String? profession,
    String? emergencyPhone,
    String? emergencyContact,
    String? phone,
    List<Certificate>? certificates,
    List<Map<String, dynamic>>? examRecords,
    int? totalShiftHours,
  }) {
    return VolunteerProfile(
      id: id,
      fullName: fullName,
      age: age,
      bloodType: bloodType,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      profession: profession ?? this.profession,
      specialty: specialty,
      institutionYears: institutionYears,
      totalShiftHours: totalShiftHours ?? this.totalShiftHours,
      certificates: certificates ?? this.certificates,
      examRecords: examRecords ?? this.examRecords,
      isActive: isActive,
    );
  }

  // Mock veri (offline çalışma için)
  factory VolunteerProfile.mock() {
    return VolunteerProfile(
      id: '#64812',
      fullName: 'Ahmet Yılmaz',
      age: 32,
      bloodType: '0 Rh+',
      phone: '+90 532 *** ** 78',
      emergencyContact: 'Fatma Yılmaz (Eş)',
      emergencyPhone: '+90 533 *** ** 12',
      city: 'İstanbul',
      district: 'Ümraniye',
      address: 'Çamlık Mahallesi, 34. Sokak No:12',
      profession: 'İnşaat Mühendisi',
      specialty: 'Arama Kurtarma',
      institutionYears: 4,
      totalShiftHours: 86,
      certificates: const [
        Certificate(id: 'CERT-001', name: 'Temel Afet Müdahale', issueDate: '2024-03-15', score: 92),
        Certificate(id: 'CERT-002', name: 'İlk Yardım İleri', issueDate: '2023-11-20', score: 88),
        Certificate(id: 'CERT-003', name: 'Arama Kurtarma', issueDate: '2025-01-10', score: 95),
      ],
      examRecords: const [
        {'name': 'Temel Afet Müdahale', 'score': 92, 'date': '2024-03-15', 'status': 'Başarılı'},
        {'name': 'İlk Yardım İleri', 'score': 88, 'date': '2023-11-20', 'status': 'Başarılı'},
        {'name': 'Arama Kurtarma', 'score': 95, 'date': '2025-01-10', 'status': 'Başarılı'},
      ],
      isActive: true,
    );
  }

  // Ekip Lideri mock
  factory VolunteerProfile.leaderMock() {
    return VolunteerProfile(
      id: '#LDR-001',
      fullName: 'Hatay İl Başkanı',
      age: 45,
      bloodType: 'A Rh+',
      phone: '+90 542 *** ** 00',
      emergencyContact: 'Kurum İrtibat',
      emergencyPhone: '+90 542 000 00 00',
      city: 'Hatay',
      district: 'Antakya',
      address: 'Merkez Ofis',
      profession: 'Kamu Yöneticisi',
      specialty: 'Afet Yönetimi',
      institutionYears: 12,
      totalShiftHours: 420,
      certificates: const [],
      examRecords: const [],
      isActive: true,
    );
  }
}
