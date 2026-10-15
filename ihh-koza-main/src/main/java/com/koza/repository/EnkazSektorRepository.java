package com.koza.repository;

import com.koza.model.EnkazSektor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EnkazSektorRepository extends JpaRepository<EnkazSektor, String> {
}
