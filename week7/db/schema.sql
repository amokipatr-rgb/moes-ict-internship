CREATE DATABASE IF NOT EXISTS moes_inventory_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE moes_inventory_db;

DROP TABLE IF EXISTS movements;
DROP TABLE IF EXISTS goods_issued_items;
DROP TABLE IF EXISTS goods_issued;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS stock_items;
DROP TABLE IF EXISTS goods_received_items;
DROP TABLE IF EXISTS goods_received;

-- ===== GOODS RECEIVED (header) =====
CREATE TABLE goods_received (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name   VARCHAR(150) NOT NULL,
    lpo_number      VARCHAR(50) NOT NULL,
    delivery_date   DATE NOT NULL,
    procurement_dept VARCHAR(100) DEFAULT NULL,
    has_invoice     BOOLEAN DEFAULT FALSE,
    has_lpo         BOOLEAN DEFAULT FALSE,
    has_delivery_note BOOLEAN DEFAULT FALSE,
    notes           TEXT DEFAULT NULL,
    received_by     VARCHAR(100) DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== GOODS RECEIVED ITEMS =====
CREATE TABLE goods_received_items (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    goods_received_id INT NOT NULL,
    description     VARCHAR(200) NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    category        VARCHAR(50) DEFAULT NULL,
    unit_cost       DECIMAL(12,2) DEFAULT NULL,
    serial_numbers  TEXT DEFAULT NULL COMMENT 'Comma-separated S/Ns for the batch',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (goods_received_id) REFERENCES goods_received(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== STOCK ITEMS (items physically in the store) =====
CREATE TABLE stock_items (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    item_code     VARCHAR(50) NOT NULL UNIQUE,
    serial_no     VARCHAR(100) DEFAULT NULL,
    category      VARCHAR(50) NOT NULL,
    make_model    VARCHAR(100) DEFAULT NULL,
    description   VARCHAR(200) DEFAULT NULL,
    source        ENUM('received','manual') NOT NULL DEFAULT 'manual',
    gr_item_id    INT DEFAULT NULL COMMENT 'FK to goods_received_items if received via GR',
    notes         TEXT DEFAULT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (gr_item_id) REFERENCES goods_received_items(id) ON DELETE SET NULL,
    INDEX idx_category (category),
    INDEX idx_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== ASSETS (items deployed to departments) =====
CREATE TABLE assets (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    asset_tag     VARCHAR(50) NOT NULL UNIQUE,
    serial_no     VARCHAR(100) DEFAULT NULL,
    category      VARCHAR(50) NOT NULL,
    make_model    VARCHAR(100) DEFAULT NULL,
    description   VARCHAR(200) DEFAULT NULL,
    location      VARCHAR(50) NOT NULL,
    room_no       VARCHAR(50) DEFAULT NULL,
    assigned_to   VARCHAR(100) DEFAULT NULL,
    department    VARCHAR(100) NOT NULL,
    status        ENUM('Issued','Damaged','Disposed','Under Repair','Returned') NOT NULL DEFAULT 'Issued',
    stock_item_id INT DEFAULT NULL COMMENT 'FK to stock_items — which store item was issued to create this',
    gi_item_id    INT DEFAULT NULL COMMENT 'FK to goods_issued_items',
    source        ENUM('issued','manual') NOT NULL DEFAULT 'manual',
    notes         TEXT DEFAULT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_item_id) REFERENCES stock_items(id) ON DELETE SET NULL,
    INDEX idx_category (category),
    INDEX idx_location (location),
    INDEX idx_status (status),
    INDEX idx_department (department),
    INDEX idx_assigned (assigned_to),
    INDEX idx_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== GOODS ISSUED (header) =====
CREATE TABLE goods_issued (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    department    VARCHAR(100) NOT NULL,
    officer_name  VARCHAR(100) NOT NULL,
    officer_title VARCHAR(100) DEFAULT NULL,
    issue_date    DATE NOT NULL,
    notes         TEXT DEFAULT NULL,
    issued_by     VARCHAR(100) DEFAULT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== GOODS ISSUED ITEMS =====
CREATE TABLE goods_issued_items (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    goods_issued_id INT NOT NULL,
    stock_item_id  INT NOT NULL COMMENT 'FK to stock_items — the store item being issued',
    asset_id       INT NOT NULL COMMENT 'FK to assets — the deployed asset created',
    notes          TEXT DEFAULT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (goods_issued_id) REFERENCES goods_issued(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_item_id) REFERENCES stock_items(id) ON DELETE RESTRICT,
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== MOVEMENTS (immutable audit log for both stock and assets) =====
CREATE TABLE movements (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    item_type       ENUM('stock','asset') NOT NULL,
    item_id         INT NOT NULL,
    movement_type   ENUM('Received','Issued','Returned','Transferred','Damaged','Repaired','Disposed','Adjusted') NOT NULL,
    from_status     VARCHAR(20) DEFAULT NULL,
    to_status       VARCHAR(20) DEFAULT NULL,
    from_location   VARCHAR(50) DEFAULT NULL,
    to_location     VARCHAR(50) DEFAULT NULL,
    from_department VARCHAR(100) DEFAULT NULL,
    to_department   VARCHAR(100) DEFAULT NULL,
    from_assigned   VARCHAR(100) DEFAULT NULL,
    to_assigned     VARCHAR(100) DEFAULT NULL,
    reference_type  VARCHAR(30) DEFAULT NULL COMMENT 'goods_received, goods_issued, etc.',
    reference_id    INT DEFAULT NULL,
    notes           TEXT DEFAULT NULL,
    changed_by      VARCHAR(100) DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_item (item_type, item_id),
    INDEX idx_type (movement_type),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== DEPARTMENTS (reference list) =====
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(100) NOT NULL UNIQUE,
    floor    VARCHAR(20) DEFAULT NULL,
    head     VARCHAR(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
