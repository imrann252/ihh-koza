package com.koza.model;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "field_logs")
public class FieldLog {

    @Id
    @Column(name = "id", length = 50)
    private String id;

    @Column(name = "sector_id", length = 50)
    private String sectorId;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;

    @Lob
    @Column(name = "audio_bytes")
    private byte[] audioBytes;

    @Column(name = "encrypted_health_data", columnDefinition = "TEXT")
    private String encryptedHealthData;

    @Column(name = "is_synced_to_center")
    private boolean isSyncedToCenter = false;

    public FieldLog() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSectorId() {
        return sectorId;
    }

    public void setSectorId(String sectorId) {
        this.sectorId = sectorId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public byte[] getAudioBytes() {
        return audioBytes;
    }

    public void setAudioBytes(byte[] audioBytes) {
        this.audioBytes = audioBytes;
    }

    public String getEncryptedHealthData() {
        return encryptedHealthData;
    }

    public void setEncryptedHealthData(String encryptedHealthData) {
        this.encryptedHealthData = encryptedHealthData;
    }

    public boolean isSyncedToCenter() {
        return isSyncedToCenter;
    }

    public void setSyncedToCenter(boolean syncedToCenter) {
        isSyncedToCenter = syncedToCenter;
    }
}
