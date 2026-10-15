# 🌲 KOZA - İHH Afet ve Kriz Yönetimi Portalı

**Yapay Zekâ Odaklı Toplumsal Fayda Hackathonu 2026 (ATOM)** kapsamında **Afet ve Kriz Yönetiminde Dijital Çözümler** teması için geliştirilmiş entegre afet yönetim ve koordinasyon platformudur.

Sistem; saha ekiplerinin internet erişimi olmadığı durumlarda dahi çalışabilen yenilikçi **Data Mule** teknolojisi, yapay zekâ destekli analizler, çevrimdışı ses kaydı/SOS bildirimi, vardiya takibi ve gönüllü eğitim akademisini tek bir çatı altında birleştirir.

---

## 🚀 Proje Özeti & Temel Özellikler

Koza, afet anındaki en kritik 3 probleme odaklanır: **Haberleşme**, **Koordinasyon** ve **Yetkinlik Esaslı Görevlendirme**.

### 1. Internetsiz Sahada Kesintisiz İletişim (Data Mule)
* **Offline Kayıt:** İnternet erişimi olmayan enkaz/müdahale bölgelerindeki gönüllüler ve liderler, mobil uygulama üzerinden Base64 şifrelenmiş sesli SOS kayıtları ve hayati durum raporları oluşturur.
* **Mule Senkronizasyonu:** Bölgeden geçen mobil taşıyıcılar (Data Mule araçları), bu paketleri fiziksel olarak alıp internetin olduğu ilk noktada merkeze (`POST /api/mule/sync`) senkronize eder.
* **Canlı Harita Entegrasyonu:** Merkez komuta ekranında, senkronize edilen bu veriler Leaflet harita üzerinde anlık kırmızı/kritik alarm ve ses oynatma özellikleri ile görüntülenir.

### 2. Gönüllü Vardiya ve Vakıf Çalışma Süreleri
* Gönüllüler mobil veya web portalı üzerinden aktif afet bölgelerine giriş/çıkış (Check-in/out) yapabilir.
* Merkez veya vakıf binasında geçirilen çalışma süreleri canlı bir sayaçla takip edilir ve **Yetkinlik Puanı** olarak hanelerine eklenir.

### 3. Saha Eğitimleri Akademisi & Yetkinlik Testleri
* Mobil ve Web arayüzlerinde yer alan interaktif eğitim modülü ile gönüllüler online testlere girer.
* Sınavı başarıyla ($66\%$ barajı) geçen gönüllüler dinamik olarak **Sertifika** kazanır. Bu sertifikalar Genel Merkez panelindeki hiyerarşik 81 il ekip ağacında anlık olarak görüntülenebilir.

---

## 🛠️ Kullanılan Teknolojiler

* **Ön Yüz (Arayüz):** Flutter & Dart (Web, Android, iOS tek kod tabanı)
* **Arka Yüz (Sunucu):** Java Spring Boot REST API
* **Veri Depolama & Çevrimdışı State:** Hive (NoSQL Local Database) & Spring Data JPA (PostgreSQL / H2)
* **Harita Kütüphaneleri:** Leaflet (Web) & Flutter Map (Mobil)

---

## 💻 Kurulum ve Çalıştırma Adımları

### 1. Spring Boot Backend Sunucusunu Çalıştırma
Proje kök dizininde yer alan önceden derlenmiş Java paketini çalıştırmak için:
```bash
# Android OpenJDK kullanarak arka yüzü başlatın
& "C:\Program Files\Android\openjdk\jdk-21.0.8\bin\java.exe" -jar target/ihh-koza-backend-0.0.1-SNAPSHOT.jar
```
Sunucu varsayılan olarak `http://localhost:8080` portundan hizmet verecektir.

### 2. Flutter Mobil & Web Uygulamasını Çalıştırma
Uygulamayı yerel tarayıcı (Chrome) üzerinde çalıştırmak için:
```bash
# Flutter Web üzerinde yerel geliştirme modunu başlatın
flutter run -d chrome
```

---

## 🔗 Canlı Demo ve Yayın Bilgileri

Uygulamanın dışarıya açılan canlı web arayüzüne ve demo sunumlarına aşağıdaki bağlantılardan erişebilirsiniz:

* **🌐 Canlı Web Uygulaması (Canlı URL):** `[BURAYA_CANLI_WEB_LINKINIZI_EKLEYIN]`
* **📹 2-3 Dk Demo Videosu:** `[BURAYA_DRIVE_VEYA_YOUTUBE_DEMO_LINKINIZI_EKLEYIN]`
* **📊 Proje Sunum Dosyası (ATOM Şablonlu):** `[BURAYA_SUNUM_LINKINIZI_EKLEYIN]`
* **📄 Tek Sayfalık Proje Özeti:** `[BURAYA_TEK_SAYFA_OZET_LINKINIZI_EKLEYIN]`

---

## 👥 Takım Üyeleri

* **Koza Geliştirme Ekibi** (ATOM Hackathon Team)
