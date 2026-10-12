USE pharmatrack;

CREATE TABLE categories (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE suppliers (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone          VARCHAR(30),
    email          VARCHAR(150),
    address        VARCHAR(255),
    active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku_barcode           VARCHAR(50)  NOT NULL UNIQUE,
    name                  VARCHAR(150) NOT NULL,
    generic_name          VARCHAR(150),
    brand                 VARCHAR(100),
    category_id           BIGINT NOT NULL,
    dosage_form           VARCHAR(50),
    strength              VARCHAR(50),
    unit                  VARCHAR(30),
    nafdac_number         VARCHAR(50),
    selling_price         DECIMAL(12,2) NOT NULL,
    reorder_level         INT NOT NULL DEFAULT 10,
    reorder_quantity      INT,
    requires_prescription BOOLEAN NOT NULL DEFAULT FALSE,
    active                BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_products_name (name),
    INDEX idx_products_generic (generic_name)
);

CREATE TABLE staff (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(150) NOT NULL,
    phone         VARCHAR(30),
    address       VARCHAR(255),
    job_title     VARCHAR(100),
    date_employed DATE,
    base_salary   DECIMAL(12,2) NOT NULL,
    status        ENUM('ACTIVE','LEFT') NOT NULL DEFAULT 'ACTIVE',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    username           VARCHAR(50)  NOT NULL UNIQUE,
    password_hash      VARCHAR(100) NOT NULL,
    full_name          VARCHAR(150) NOT NULL,
    email              VARCHAR(150) UNIQUE,
    phone              VARCHAR(30),
    role               ENUM('ADMIN','PHARMACIST','CASHIER','STORE_KEEPER') NOT NULL,
    active             BOOLEAN NOT NULL DEFAULT TRUE,
    failed_login_count INT NOT NULL DEFAULT 0,
    locked_until       TIMESTAMP NULL,
    last_login_at      TIMESTAMP NULL,
    staff_id           BIGINT UNIQUE,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_staff FOREIGN KEY (staff_id) REFERENCES staff(id)
);

CREATE TABLE price_history (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    old_price  DECIMAL(12,2) NOT NULL,
    new_price  DECIMAL(12,2) NOT NULL,
    changed_by BIGINT NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_price_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_price_user    FOREIGN KEY (changed_by) REFERENCES users(id)
);

CREATE TABLE stock_batches (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id         BIGINT NOT NULL,
    supplier_id        BIGINT,
    batch_number       VARCHAR(50) NOT NULL,
    expiry_date        DATE NOT NULL,
    quantity_received  INT NOT NULL,
    quantity_remaining INT NOT NULL,
    unit_cost          DECIMAL(12,2) NOT NULL,
    received_date      DATE NOT NULL,
    received_by        BIGINT NOT NULL,
    status             ENUM('ACTIVE','DEPLETED','EXPIRED','QUARANTINED') NOT NULL DEFAULT 'ACTIVE',
    version            BIGINT NOT NULL DEFAULT 0,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batch_product  FOREIGN KEY (product_id)  REFERENCES products(id),
    CONSTRAINT fk_batch_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    CONSTRAINT fk_batch_user     FOREIGN KEY (received_by) REFERENCES users(id),
    CONSTRAINT uq_batch UNIQUE (product_id, batch_number, supplier_id),
    CONSTRAINT chk_qty_remaining CHECK (quantity_remaining >= 0),
    INDEX idx_batch_fefo (product_id, expiry_date)
);

CREATE TABLE stock_movements (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id      BIGINT NOT NULL,
    batch_id        BIGINT NOT NULL,
    movement_type   ENUM('PURCHASE','SALE','SALE_VOID','RETURN_IN','ADJUSTMENT_IN',
                         'ADJUSTMENT_OUT','SUPPLIER_RETURN','EXPIRY_WRITEOFF','COUNT_CORRECTION') NOT NULL,
    quantity_change INT NOT NULL,
    quantity_before INT NOT NULL,
    quantity_after  INT NOT NULL,
    reference_type  VARCHAR(30),
    reference_id    BIGINT,
    user_id         BIGINT NOT NULL,
    note            VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mov_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_mov_batch   FOREIGN KEY (batch_id)   REFERENCES stock_batches(id),
    CONSTRAINT fk_mov_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    INDEX idx_mov_product_time (product_id, created_at)
);