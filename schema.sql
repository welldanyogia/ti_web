-- Buat database (opsional jika belum)
CREATE DATABASE IF NOT EXISTS ti_web CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE ti_web;


-- Tabel master
CREATE TABLE barang (
                        id_barang INT AUTO_INCREMENT PRIMARY KEY,
                        sku VARCHAR(50) NOT NULL UNIQUE,
                        nama VARCHAR(200) NOT NULL,
                        satuan VARCHAR(20) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE lokasi (
                        id_lokasi INT AUTO_INCREMENT PRIMARY KEY,
                        nama VARCHAR(100) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE supplier (
                          id_supplier INT AUTO_INCREMENT PRIMARY KEY,
                          nama VARCHAR(150) NOT NULL,
                          lead_time_hari INT NOT NULL CHECK (lead_time_hari >= 0)
) ENGINE=InnoDB;


-- Stok saldo per barang per lokasi
CREATE TABLE stok (
                      id_barang INT NOT NULL,
                      id_lokasi INT NOT NULL,
                      qty_saldo DECIMAL(12,2) NOT NULL DEFAULT 0,
                      PRIMARY KEY (id_barang, id_lokasi),
                      CONSTRAINT fk_stok_barang FOREIGN KEY (id_barang) REFERENCES barang(id_barang) ON DELETE CASCADE,
                      CONSTRAINT fk_stok_lokasi FOREIGN KEY (id_lokasi) REFERENCES lokasi(id_lokasi) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Transaksi masuk/keluar
CREATE TABLE transaksi (
                           id_transaksi INT AUTO_INCREMENT PRIMARY KEY,
                           tgl_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           jenis ENUM('MASUK','KELUAR') NOT NULL,
                           qty DECIMAL(12,2) NOT NULL CHECK (qty > 0),
                           id_barang INT NOT NULL,
                           id_lokasi INT NOT NULL,
                           CONSTRAINT fk_trx_barang FOREIGN KEY (id_barang) REFERENCES barang(id_barang),
                           CONSTRAINT fk_trx_lokasi FOREIGN KEY (id_lokasi) REFERENCES lokasi(id_lokasi)
) ENGINE=InnoDB;


-- View saldo per barang (akumulasi transaksi)
CREATE OR REPLACE VIEW v_saldo_per_barang AS
SELECT b.id_barang, b.sku, b.nama,
       COALESCE(SUM(CASE WHEN t.jenis='MASUK' THEN t.qty ELSE -t.qty END),0) AS saldo
FROM barang b
         LEFT JOIN transaksi t ON t.id_barang = b.id_barang
GROUP BY b.id_barang, b.sku, b.nama;


-- Data contoh
INSERT INTO barang (sku, nama, satuan) VALUES
                                           ('BRG-001','Baut M6','pcs'),
                                           ('BRG-002','Mur M6','pcs'),
                                           ('BRG-003','Pelat 2mm','lembar');


INSERT INTO lokasi (nama) VALUES ('Gudang A'),('Gudang B');


INSERT INTO transaksi (jenis, qty, id_barang, id_lokasi) VALUES
                                                             ('MASUK',100,1,1),
                                                             ('KELUAR',30,1,1),
                                                             ('MASUK',50,2,1),
                                                             ('KELUAR',10,2,2),
                                                             ('MASUK',25,3,2);