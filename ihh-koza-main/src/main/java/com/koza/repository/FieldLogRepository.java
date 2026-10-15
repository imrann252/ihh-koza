package com.koza.repository;

import com.koza.model.FieldLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FieldLogRepository extends JpaRepository<FieldLog, String> {
}
