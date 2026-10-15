CREATE TABLE IF NOT EXISTS sectors (
    sector_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    risk_level VARCHAR(20) DEFAULT 'Temiz',
    parent_id VARCHAR(50) REFERENCES sectors(sector_id),
    geometry_text TEXT
);

CREATE TABLE IF NOT EXISTS field_logs (
    id VARCHAR(50) PRIMARY KEY,
    sector_id VARCHAR(50) REFERENCES sectors(sector_id),
    timestamp TIMESTAMP NOT NULL,
    audio_bytes BYTEA,
    encrypted_health_data TEXT,
    is_synced_to_center BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS kullanicilar (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    blood_group VARCHAR(20),
    has_search_and_rescue_certificate BOOLEAN,
    is_healthy BOOLEAN
);

CREATE TABLE IF NOT EXISTS enkaz_sektorler (
    id VARCHAR(36) PRIMARY KEY,
    sector_code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    risk_level VARCHAR(50),
    geometry_text TEXT
);
