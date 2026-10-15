package com.koza.model;

import javax.persistence.*;

@Entity
@Table(name = "kullanicilar")
public class Kullanici {

    @Id
    @Column(name = "id", length = 36)
    private String id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "role")
    private String role; // GÖNÜLLÜ, EKİP_LİDERİ, vb.

    @Column(name = "blood_group")
    private String bloodGroup; // A_POSITIVE, B_NEGATIVE, vb.

    @Column(name = "has_search_and_rescue_certificate")
    private boolean hasSearchAndRescueCertificate;

    @Column(name = "is_healthy")
    private boolean isHealthy;

    public Kullanici() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getBloodGroup() {
        return bloodGroup;
    }

    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
    }

    public boolean isHasSearchAndRescueCertificate() {
        return hasSearchAndRescueCertificate;
    }

    public void setHasSearchAndRescueCertificate(boolean hasSearchAndRescueCertificate) {
        this.hasSearchAndRescueCertificate = hasSearchAndRescueCertificate;
    }

    public boolean isHealthy() {
        return isHealthy;
    }

    public void setHealthy(boolean healthy) {
        isHealthy = healthy;
    }
}
