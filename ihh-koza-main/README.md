🚀 İHH KOZA - Afet Yönetim ve Gönüllü Koordinasyon Sistemi
Afetin ilk 72 saatinde GSM ve internet altyapısının çökmesiyle oluşan "Dijital Körlüğü" ortadan kaldıran Offline-First hibrit koordinasyon platformu.


📌 Problem ve Vizyon
Büyük ölçekli afetlerde iletişim altyapılarının çökmesi saha ekipleri ile kriz merkezi arasındaki bağı koparır. İHH KOZA, internetin olmadığı sıfır-şebeke koşullarında dahi arama-kurtarma, hasar tespiti ve enkaz durum raporlamasının kesintisiz sürmesini hedefler.

🏗️ Mimari & Çalışma Mantığı (Store-and-Forward / Data Mule)
Sistem sahadaki fiziksel hareketi ve yerel kuyruğu bir veri iletim hattına dönüştürür:

Gönüllü (Offline Katman): Sahadaki personel internet olmasa dahi formları doldurur; veriler yerel hafızada (Hive) saklanır.

Ekip Lideri (Veri Taşıyıcı): Çevrimdışı veriler lider cihazında toplanır, internet algılandığında tek tıkla merkeze senkronize edilir.

Merkezi Yönetim (HQ Paneli): Senkronize olan veriler anlık risk haritaları ve durum tabloları üzerinden takip edilir.

🛠️ Teknoloji Yığını
Frontend / Arayüz: Flutter (Web & Mobil Uyumlu)

Yerel Depolama: Hive (Offline-First)

Backend: Java Spring Boot, Spring Data JPA, REST API

Veritabanı: H2 Database (In-Memory)

Harita & Görselleştirme: Flutter Map / OpenStreetMap

💻 Kurulum ve Çalıştırma
Backend (Java / Spring Boot)
mvn spring-boot:run
(Backend adresi: http://localhost:8080)

Frontend (Flutter Web)
flutter pub get
flutter run -d chrome