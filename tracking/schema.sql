-- Zuri Logistics tracking foundation
-- Review and back up the database before importing this schema.
-- Store driver/device tokens as SHA-256 hashes; never store raw tokens.

CREATE TABLE IF NOT EXISTS zuri_vehicles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  registration_number VARCHAR(32) NOT NULL UNIQUE,
  vehicle_type VARCHAR(80) NULL,
  fleet_owner VARCHAR(160) NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS zuri_drivers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vehicle_id BIGINT UNSIGNED NULL,
  driver_name VARCHAR(160) NOT NULL,
  phone VARCHAR(32) NULL,
  token_hash CHAR(64) NULL UNIQUE,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_zuri_driver_vehicle FOREIGN KEY (vehicle_id) REFERENCES zuri_vehicles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS zuri_shipments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  tracking_code VARCHAR(40) NOT NULL UNIQUE,
  customer_name VARCHAR(160) NULL,
  container_number VARCHAR(40) NULL,
  cargo_description VARCHAR(255) NULL,
  origin VARCHAR(180) NOT NULL,
  destination VARCHAR(180) NOT NULL,
  status ENUM('Booked','Assigned','Loading','In Transit','At Border','Offloading','Delivered','Delayed','Cancelled') NOT NULL DEFAULT 'Booked',
  eta DATETIME NULL,
  vehicle_id BIGINT UNSIGNED NULL,
  public_note VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_zuri_shipment_vehicle FOREIGN KEY (vehicle_id) REFERENCES zuri_vehicles(id) ON DELETE SET NULL,
  INDEX idx_zuri_shipment_status (status),
  INDEX idx_zuri_shipment_eta (eta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS zuri_vehicle_positions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vehicle_id BIGINT UNSIGNED NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  accuracy_m DECIMAL(8,2) NULL,
  speed_kmh DECIMAL(8,2) NULL,
  source ENUM('driver_phone','gps_device','traccar') NOT NULL,
  recorded_at DATETIME NOT NULL,
  received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_zuri_position_vehicle FOREIGN KEY (vehicle_id) REFERENCES zuri_vehicles(id) ON DELETE CASCADE,
  INDEX idx_zuri_position_latest (vehicle_id, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS zuri_shipment_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  shipment_id BIGINT UNSIGNED NOT NULL,
  status VARCHAR(40) NOT NULL,
  location_label VARCHAR(180) NULL,
  public_note VARCHAR(500) NULL,
  event_time DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_zuri_event_shipment FOREIGN KEY (shipment_id) REFERENCES zuri_shipments(id) ON DELETE CASCADE,
  INDEX idx_zuri_event_timeline (shipment_id, event_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
