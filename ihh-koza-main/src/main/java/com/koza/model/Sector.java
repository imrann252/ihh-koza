package com.koza.model;

import javax.persistence.*;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "sectors")
public class Sector {

    @Id
    @Column(name = "sector_id", length = 50)
    private String sectorId; // Örn: 'ENKAZ-A1'

    @Column(nullable = false)
    private String name;

    @Column(name = "risk_level")
    private String riskLevel = "Temiz"; // Kritik, CalismaVar, Temiz

    // Hat 1 Tree-view hiyerarşisi için Self-Reference (Üst Sektör / Bölge)
    @ManyToOne
    @JoinColumn(name = "parent_id")
    @JsonIgnore // Sonsuz döngü patlamasını engeller
    private Sector parentSector;

    @OneToMany(mappedBy = "parentSector", cascade = CascadeType.ALL)
    private List<Sector> subSectors;

    // CBS koordinatlarını text (WKT Formatı) olarak tutuyoruz ki H2 veritabanı patlamasın!
    // Örn: "POLYGON((29.0520 40.9850, 29.0560 40.9850...))"
    @Column(name = "geometry_text", columnDefinition = "TEXT")
    private String geometryText;

    // --- GETTER & SETTER BLOKLARI ---
    public String getSectorId() { return sectorId; }
    public void setSectorId(String sectorId) { this.sectorId = sectorId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public Sector getParentSector() { return parentSector; }
    public void setParentSector(Sector parentSector) { this.parentSector = parentSector; }

    public List<Sector> getSubSectors() { return subSectors; }
    public void setSubSectors(List<Sector> subSectors) { this.subSectors = subSectors; }

    public String getGeometryText() { return geometryText; }
    public void setGeometryText(String geometryText) { this.geometryText = geometryText; }
}
