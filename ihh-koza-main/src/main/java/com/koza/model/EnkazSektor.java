package com.koza.model;

import javax.persistence.*;

@Entity
@Table(name = "enkaz_sektorler")
public class EnkazSektor {

    @Id
    @Column(name = "id", length = 36)
    private String id;

    @Column(name = "sector_code", nullable = false, length = 50)
    private String sectorCode;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "risk_level")
    private String riskLevel; // Kırmızı, Sarı, Temiz

    @Column(name = "geometry_text", columnDefinition = "TEXT")
    private String geometryText; // WKT format: POLYGON((...))

    public EnkazSektor() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSectorCode() {
        return sectorCode;
    }

    public void setSectorCode(String sectorCode) {
        this.sectorCode = sectorCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getGeometryText() {
        return geometryText;
    }

    public void setGeometryText(String geometryText) {
        this.geometryText = geometryText;
    }
}
