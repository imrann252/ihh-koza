package com.koza.service;

import com.koza.model.FieldLog;
import com.koza.model.Sector;
import com.koza.repository.FieldLogRepository;
import com.koza.repository.SectorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class DataMuleSyncService {

    @Autowired
    private SectorRepository sectorRepository;

    @Autowired
    private FieldLogRepository fieldLogRepository;

    @Transactional
    public void processIncomingFieldPacket(String clientLogId, byte[] rawAudio, String sectorId, String status, String encryptedHealth) {

        // Duplicate check using clientLogId (which is the primary key id)
        if (clientLogId != null && fieldLogRepository.existsById(clientLogId)) {
            System.out.println("Tekrarlanan paket engellendi. clientLogId: " + clientLogId);
            return;
        }

        // 1. İlgili sektörü veritabanından buluyoruz
        Optional<Sector> sectorOpt = Optional.empty();
        if (sectorId != null) {
            sectorOpt = sectorRepository.findById(sectorId);
        }

        if (sectorOpt.isPresent()) {
            Sector sector = sectorOpt.get();
            // 2. Sektörün anlık durumunu güncelliyoruz (Bu işlem Hat 1 haritasını anında renklendirecek!)
            sector.setRiskLevel(status);
            sectorRepository.save(sector);

            // 3. Çevrimdışı sahadan gelen ses kaydını ve log detaylarını oluşturuyoruz
            FieldLog fieldLog = new FieldLog();
            fieldLog.setId(clientLogId);
            fieldLog.setSectorId(sectorId);
            fieldLog.setTimestamp(LocalDateTime.now());
            fieldLog.setAudioBytes(rawAudio);
            fieldLog.setEncryptedHealthData(encryptedHealth);
            fieldLog.setSyncedToCenter(false);

            // 4. Veritabanına kalıcı olarak insert ediyoruz
            fieldLogRepository.save(fieldLog);

            System.out.println("Lokalizasyon Başarılı: Sektör " + sectorId + " durumu '" + status
                    + "' yapıldı ve ses binary olarak mühürlendi. clientLogId: " + clientLogId);
        } else {
            System.out.println("Hata: Sektör " + sectorId + " veritabanında bulunamadı!");
        }
    }
}