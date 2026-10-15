// ─── Türkiye 81 İl Listesi ─────────────────────────────────────────────────────
// Backend ve UI dropdown için standart referans

class TurkeyIlListesi {
  TurkeyIlListesi._();

  static const List<String> iller = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya',
    'Ankara', 'Antalya', 'Artvin', 'Aydın', 'Balıkesir',
    'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur',
    'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli',
    'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum',
    'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari',
    'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
    'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa',
    'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
    'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun',
    'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
    'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van',
    'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
    'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan',
    'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce',
  ];

  /// Afet büyüklüğüne göre çevre iller (mock — gerçekte geometri tabanlı olacak)
  static List<String> getNearbyIller(String baseIl, {int radius = 3}) {
    final idx = iller.indexOf(baseIl);
    if (idx == -1) return iller.take(radius).toList();
    final start = (idx - radius).clamp(0, iller.length - 1);
    final end = (idx + radius).clamp(0, iller.length - 1);
    return iller.sublist(start, end + 1).where((il) => il != baseIl).toList();
  }
}
