-- Zuri Logistics Group - MySQL 8.4 database schema
-- Creates the core CRM, quoting, transport, fleet and enquiry tables.

CREATE DATABASE IF NOT EXISTS zuri_logistics
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE zuri_logistics;

CREATE TABLE IF NOT EXISTS customers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_name VARCHAR(180) NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(40) NULL,
  whatsapp VARCHAR(40) NULL,
  address_line1 VARCHAR(190) NULL,
  city VARCHAR(100) NULL,
  province VARCHAR(100) NULL,
  country VARCHAR(100) NOT NULL DEFAULT 'South Africa',
  customer_type ENUM('individual','business') NOT NULL DEFAULT 'individual',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_customers_email (email),
  INDEX idx_customers_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contact_enquiries (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id BIGINT UNSIGNED NULL,
  name VARCHAR(200) NOT NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(40) NULL,
  subject VARCHAR(200) NULL,
  message TEXT NOT NULL,
  status ENUM('new','contacted','converted','closed','spam') NOT NULL DEFAULT 'new',
  source VARCHAR(80) NOT NULL DEFAULT 'website',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_enquiries_status_created (status, created_at),
  CONSTRAINT fk_enquiry_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS quotes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  quote_number VARCHAR(40) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NULL,
  service_type ENUM('air_freight','ocean_freight','road_freight','rail_freight','customs_clearance','warehousing','removal','towing_truck','container','other') NOT NULL,
  pickup_location VARCHAR(255) NULL,
  delivery_location VARCHAR(255) NULL,
  requested_date DATE NULL,
  cargo_description TEXT NULL,
  estimated_weight_kg DECIMAL(12,2) NULL,
  estimated_value DECIMAL(14,2) NULL,
  currency CHAR(3) NOT NULL DEFAULT 'ZAR',
  quoted_amount DECIMAL(14,2) NULL,
  status ENUM('requested','draft','sent','accepted','rejected','expired','cancelled') NOT NULL DEFAULT 'requested',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_quotes_status (status),
  INDEX idx_quotes_customer (customer_id),
  CONSTRAINT fk_quote_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  registration_number VARCHAR(30) NOT NULL UNIQUE,
  vehicle_type VARCHAR(80) NOT NULL,
  make VARCHAR(80) NULL,
  model VARCHAR(80) NULL,
  year SMALLINT UNSIGNED NULL,
  capacity_kg DECIMAL(12,2) NULL,
  status ENUM('available','assigned','maintenance','inactive') NOT NULL DEFAULT 'available',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS drivers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(40) NULL,
  licence_number VARCHAR(80) NULL,
  licence_expiry DATE NULL,
  status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_drivers_status (status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS shipments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tracking_number VARCHAR(50) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NULL,
  quote_id BIGINT UNSIGNED NULL,
  vehicle_id BIGINT UNSIGNED NULL,
  driver_id BIGINT UNSIGNED NULL,
  service_type VARCHAR(80) NOT NULL,
  pickup_location VARCHAR(255) NOT NULL,
  delivery_location VARCHAR(255) NOT NULL,
  scheduled_pickup DATETIME NULL,
  estimated_delivery DATETIME NULL,
  actual_delivery DATETIME NULL,
  status ENUM('booked','collected','in_transit','delayed','delivered','cancelled') NOT NULL DEFAULT 'booked',
  cargo_description TEXT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_shipments_status (status),
  INDEX idx_shipments_customer (customer_id),
  CONSTRAINT fk_shipment_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipment_quote FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipment_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
  CONSTRAINT fk_shipment_driver FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS shipment_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  shipment_id BIGINT UNSIGNED NOT NULL,
  status VARCHAR(50) NOT NULL,
  location VARCHAR(255) NULL,
  event_note TEXT NULL,
  event_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_events_shipment_time (shipment_id, event_time),
  CONSTRAINT fk_event_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS invoices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NULL,
  shipment_id BIGINT UNSIGNED NULL,
  issue_date DATE NOT NULL,
  due_date DATE NULL,
  subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'ZAR',
  status ENUM('draft','sent','part_paid','paid','overdue','cancelled') NOT NULL DEFAULT 'draft',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_invoices_status_due (status, due_date),
  CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'ZAR',
  payment_method ENUM('eft','card','cash','other') NOT NULL DEFAULT 'eft',
  reference VARCHAR(120) NULL,
  paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes TEXT NULL,
  INDEX idx_payments_invoice (invoice_id),
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS warehouse_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(80) NOT NULL UNIQUE,
  item_name VARCHAR(190) NOT NULL,
  description TEXT NULL,
  quantity DECIMAL(12,2) NOT NULL DEFAULT 0,
  unit VARCHAR(30) NOT NULL DEFAULT 'unit',
  location VARCHAR(120) NULL,
  reorder_level DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','manager','dispatcher','finance','staff') NOT NULL DEFAULT 'staff',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Initial company contact used by the public website.
INSERT INTO customers (company_name, first_name, email, phone, customer_type, city, province)
SELECT 'Zuri Logistics Group PTY LTD', 'Zuri', 'sales@zurilogisticsgroup.co.za', '063 836 6355', 'business', 'Johannesburg', 'Gauteng'
WHERE NOT EXISTS (
  SELECT 1 FROM customers WHERE email = 'sales@zurilogisticsgroup.co.za'
);
