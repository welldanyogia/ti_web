<?php
require __DIR__.'/db.php';
$method = $_SERVER['REQUEST_METHOD'];


function json_body() {
    $raw = file_get_contents('php://input');
    return $raw ? json_decode($raw, true) : [];
}


try {
    if ($method === 'GET') {
        if (isset($_GET['id'])) {
            $stmt = $pdo->prepare('SELECT * FROM barang WHERE id_barang=?');
            $stmt->execute([ (int)$_GET['id'] ]);
            echo json_encode($stmt->fetch() ?: null); exit;
        }
        $stmt = $pdo->query('SELECT id_barang, sku, nama, satuan FROM barang ORDER BY id_barang DESC');
        echo json_encode($stmt->fetchAll());
    }
    elseif ($method === 'POST') {
        $data = $_POST ?: json_body();
        if (!($data['sku'] ?? null) || !($data['nama'] ?? null) || !($data['satuan'] ?? null)) {
            http_response_code(400); echo json_encode(['error'=>'invalid input']); exit;
        }
        $stmt = $pdo->prepare('INSERT INTO barang (sku, nama, satuan) VALUES (?,?,?)');
        $stmt->execute([$data['sku'],$data['nama'],$data['satuan']]);
        echo json_encode(['id_barang' => (int)$pdo->lastInsertId()]);
    }
    elseif ($method === 'PUT') {
        $id = (int)($_GET['id'] ?? 0);
        $data = json_body();
        if (!$id || !($data['sku'] ?? null) || !($data['nama'] ?? null) || !($data['satuan'] ?? null)){
            http_response_code(400); echo json_encode(['error'=>'invalid input']); exit;
        }
        $stmt = $pdo->prepare('UPDATE barang SET sku=?, nama=?, satuan=? WHERE id_barang=?');
        $stmt->execute([$data['sku'],$data['nama'],$data['satuan'],$id]);
        echo json_encode(['updated'=>true]);
    }
    elseif ($method === 'DELETE') {
        $id = (int)($_GET['id'] ?? 0);
        if (!$id) { http_response_code(400); echo json_encode(['error'=>'invalid id']); exit; }
        $stmt = $pdo->prepare('DELETE FROM barang WHERE id_barang=?');
        $stmt->execute([$id]);
        echo json_encode(['deleted'=>true]);
    }
    else { http_response_code(405); echo json_encode(['error'=>'method not allowed']); }
}
catch (PDOException $e) { http_response_code(500); echo json_encode(['error'=>'db error']); }