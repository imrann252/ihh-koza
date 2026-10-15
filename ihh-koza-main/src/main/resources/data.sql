-- sectors tablosu için mock veriler
MERGE INTO sectors KEY(sector_id) VALUES ('ENKAZ-A1', 'Enkaz A1 Sektörü', 'Kırmızı', NULL, 'POLYGON((29.0520 40.9850, 29.0560 40.9850, 29.0560 40.9820, 29.0520 40.9820, 29.0520 40.9850))');
MERGE INTO sectors KEY(sector_id) VALUES ('ENKAZ-A2', 'Enkaz A2 Sektörü', 'Sarı', NULL, 'POLYGON((29.0560 40.9850, 29.0600 40.9850, 29.0600 40.9820, 29.0560 40.9820, 29.0560 40.9850))');

-- enkaz_sektorler tablosu için mock veriler (UUID ID'li)
MERGE INTO enkaz_sektorler KEY(id) VALUES ('s1-uuid-1111-2222-333333333333', 'ENKAZ-A1', 'Enkaz A1 Sektörü', 'Kırmızı', 'POLYGON((29.0520 40.9850, 29.0560 40.9850, 29.0560 40.9820, 29.0520 40.9820, 29.0520 40.9850))');
MERGE INTO enkaz_sektorler KEY(id) VALUES ('s2-uuid-1111-2222-333333333333', 'ENKAZ-A2', 'Enkaz A2 Sektörü', 'Sarı', 'POLYGON((29.0560 40.9850, 29.0600 40.9850, 29.0600 40.9820, 29.0560 40.9820, 29.0560 40.9850))');

-- kullanicilar tablosu için mock veriler (UUID ID'li)
-- Nitelikli Gönüllü: Arama Kurtarma Sertifikalı, Sağlıklı, A_POSITIVE Kan Grubu
MERGE INTO kullanicilar KEY(id) VALUES ('u1-uuid-1111-2222-333333333333', 'Ahmet Yılmaz', 'GÖNÜLLÜ', 'A_POSITIVE', TRUE, TRUE);

-- Nitelikli Gönüllü: Arama Kurtarma Sertifikalı, Sağlıklı, O_NEGATIVE Kan Grubu
MERGE INTO kullanicilar KEY(id) VALUES ('u2-uuid-1111-2222-333333333333', 'Mehmet Demir', 'GÖNÜLLÜ', 'O_NEGATIVE', TRUE, TRUE);

-- Sertifikasız Gönüllü
MERGE INTO kullanicilar KEY(id) VALUES ('u3-uuid-1111-2222-333333333333', 'Ayşe Kaya', 'GÖNÜLLÜ', 'A_POSITIVE', FALSE, TRUE);

-- Sağlıksız / Yaralı Gönüllü (Filtreye takılmalı)
MERGE INTO kullanicilar KEY(id) VALUES ('u4-uuid-1111-2222-333333333333', 'Fatma Çelik', 'GÖNÜLLÜ', 'A_POSITIVE', TRUE, FALSE);

-- Ekip Lideri (Filtreye takılmalı, sadece gönüllü aranıyor)
MERGE INTO kullanicilar KEY(id) VALUES ('u5-uuid-1111-2222-333333333333', 'Ali Vural', 'EKİP_LİDERİ', 'A_POSITIVE', TRUE, TRUE);
