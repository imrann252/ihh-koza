package com.koza.repository;

import com.koza.model.Kullanici;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface KullaniciRepository extends JpaRepository<Kullanici, String> {

    /**
     * Ekip Liderinin sahadaki kritik ihtiyaçlara göre arama kurtarma sertifikalı,
     * belirli kan grubuna sahip ve sağlıklı gönüllüleri listelemesini sağlayan native SQL sorgusu.
     */
    @Query(value = "SELECT * FROM kullanicilar k " +
                   "WHERE k.role = 'GÖNÜLLÜ' " +
                   "AND k.has_search_and_rescue_certificate = true " +
                   "AND k.blood_group = :bloodGroup " +
                   "AND k.is_healthy = true", 
           nativeQuery = true)
    List<Kullanici> findQualifiedVolunteers(@Param("bloodGroup") String bloodGroup);
}
