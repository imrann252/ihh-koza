package com.koza.controller;

import com.koza.model.Sector;
import com.koza.model.Kullanici;
import com.koza.repository.SectorRepository;
import com.koza.repository.KullaniciRepository;
import com.koza.service.DataMuleSyncService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mule")
@CrossOrigin(origins = "*")
public class DataMuleController {

    @Autowired
    private DataMuleSyncService syncService;

    @Autowired
    private SectorRepository sectorRepository;

    @Autowired
    private KullaniciRepository kullaniciRepository;

    @GetMapping("/sectors")
    public ResponseEntity<List<Sector>> getAllSectors() {
        return ResponseEntity.ok(sectorRepository.findAll());
    }

    @GetMapping("/volunteers")
    public ResponseEntity<List<Kullanici>> getVolunteers(@RequestParam String bloodGroup) {
        return ResponseEntity.ok(kullaniciRepository.findQualifiedVolunteers(bloodGroup));
    }

    @PostMapping("/sync")
    public ResponseEntity<String> syncFieldData(@RequestBody List<Map<String, Object>> offlinePackets) {
        try {
            if (offlinePackets == null) {
                return ResponseEntity.badRequest().body("Boş veri paketi.");
            }

            for (Map<String, Object> packet : offlinePackets) {
                if (packet == null) {
                    continue;
                }

                String clientLogId = (String) packet.get("id");
                if (clientLogId == null) {
                    clientLogId = (String) packet.get("client_log_id");
                }

                String sectorId = null;
                Object sectorIdObj = packet.get("sector_id");
                if (sectorIdObj != null) {
                    sectorId = sectorIdObj.toString();
                }

                String status = (String) packet.get("status");
                String rawAudioBase64 = (String) packet.get("audio_bytes");
                String encryptedHealth = (String) packet.get("health_data");

                byte[] audioBytes = null;
                if (rawAudioBase64 != null && !rawAudioBase64.isEmpty()) {
                    try {
                        audioBytes = java.util.Base64.getDecoder().decode(rawAudioBase64);
                    } catch (IllegalArgumentException e) {
                        System.out.println("Base64 çözme hatası (Log ID: " + clientLogId + "): " + e.getMessage());
                    }
                }

                syncService.processIncomingFieldPacket(clientLogId, audioBytes, sectorId, status, encryptedHealth);
            }
            return ResponseEntity.ok("Data Mule senkronizasyonu başarılı! " + offlinePackets.size() + " paket işlendi.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Senkronizasyon hatası: " + e.getMessage());
        }
    }
}