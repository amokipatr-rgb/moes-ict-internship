<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$DB_HOST = 'localhost';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'moes_inventory_db';

$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Database connection failed: " . $conn->connect_error]);
    exit;
}
$conn->set_charset("utf8mb4");

$method   = $_SERVER['REQUEST_METHOD'];
$pathInfo = $_SERVER['PATH_INFO'] ?? '/';
$pathInfo = '/' . trim($pathInfo, '/');
$parts    = explode('/', ltrim($pathInfo, '/'));

$route    = $parts[0] ?? 'assets';
$id       = $parts[1] ?? null;
$sub      = $parts[2] ?? null;

function logMovement($conn, $itemType, $itemId, $type, $from, $to, $refType = null, $refId = null, $notes = null, $changedBy = null) {
    $s = $conn->prepare(
        "INSERT INTO movements (item_type, item_id, movement_type, from_status, to_status, from_location, to_location, from_department, to_department, from_assigned, to_assigned, reference_type, reference_id, notes, changed_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $s->bind_param("sisssssssssisss",
        $itemType, $itemId, $type,
        $from['status'] ?? '', $to['status'] ?? '',
        $from['location'] ?? '', $to['location'] ?? '',
        $from['department'] ?? '', $to['department'] ?? '',
        $from['assigned_to'] ?? '', $to['assigned_to'] ?? '',
        $refType, $refId, $notes, $changedBy
    );
    $s->execute();
}

function getAssetState($conn, $id) {
    $s = $conn->prepare("SELECT status, location, department, assigned_to FROM assets WHERE id = ?");
    $s->bind_param("i", $id);
    $s->execute();
    return $s->get_result()->fetch_assoc() ?: ['status'=>'','location'=>'','department'=>'','assigned_to'=>''];
}

switch ($route) {

    // ========================================================================
    // ASSETS (list + create manual)
    // ========================================================================
    case 'assets':
        if ($method === 'GET') {
            $search    = $_GET['search'] ?? '';
            $category  = $_GET['category'] ?? '';
            $location  = $_GET['location'] ?? '';
            $status    = $_GET['status'] ?? '';
            $department = $_GET['department'] ?? '';
            $source    = $_GET['source'] ?? '';
            $sort      = $_GET['sort'] ?? 'asset_tag';
            $order     = strtoupper($_GET['order'] ?? 'ASC') === 'DESC' ? 'DESC' : 'ASC';
            $allowedSort = ['id','asset_tag','serial_no','category','make_model','location','room_no','assigned_to','department','status','source','created_at'];
            if (!in_array($sort, $allowedSort)) $sort = 'asset_tag';

            $where = [];
            $params = [];
            $types = '';

            if ($search !== '') {
                $where[] = "(asset_tag LIKE ? OR serial_no LIKE ? OR assigned_to LIKE ? OR make_model LIKE ?)";
                $likeSearch = "%$search%";
                $params = array_merge($params, [$likeSearch, $likeSearch, $likeSearch, $likeSearch]);
                $types .= 'ssss';
            }
            if ($category !== '')   { $where[] = "category = ?";   $params[] = $category;   $types .= 's'; }
            if ($location !== '')   { $where[] = "location = ?";   $params[] = $location;   $types .= 's'; }
            if ($status !== '')     { $where[] = "status = ?";     $params[] = $status;     $types .= 's'; }
            if ($department !== '') { $where[] = "department = ?"; $params[] = $department; $types .= 's'; }
            if ($source !== '')     { $where[] = "source = ?";     $params[] = $source;     $types .= 's'; }

            $sql = "SELECT * FROM assets";
            if (count($where)) $sql .= " WHERE " . implode(' AND ', $where);
            $sql .= " ORDER BY $sort $order";

            $stmt = $conn->prepare($sql);
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

            echo json_encode(["count" => count($data), "data" => $data]);
            break;
        }

        if ($method === 'POST') {
            $data = json_decode(file_get_contents("php://input"), true);
            if (!$data) {
                http_response_code(400);
                echo json_encode(["error" => "Invalid JSON"]);
                exit;
            }

            $required = ['asset_tag','category','location'];
            foreach ($required as $r) {
                if (empty($data[$r])) {
                    http_response_code(400);
                    echo json_encode(["error" => "Missing required field: $r"]);
                    exit;
                }
            }

            $stmt = $conn->prepare(
                "INSERT INTO assets (asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, source, notes)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'manual', ?)"
            );
            $statusVal = $data['status'] ?? 'Issued';
            $stmt->bind_param("sssssssssss",
                $data['asset_tag'],
                $data['serial_no'] ?? '',
                $data['category'],
                $data['make_model'] ?? '',
                $data['description'] ?? '',
                $data['location'],
                $data['room_no'] ?? '',
                $data['assigned_to'] ?? '',
                $data['department'] ?? '',
                $statusVal,
                $data['notes'] ?? ''
            );
            $stmt->execute();

            if ($stmt->affected_rows > 0) {
                $newId = $conn->insert_id;
                logMovement($conn, 'asset', $newId, 'Adjusted',
                    ['status'=>'','location'=>'','department'=>'','assigned_to'=>''],
                    ['status'=>$statusVal, 'location'=>$data['location'], 'department'=>$data['department']??'', 'assigned_to'=>$data['assigned_to']??''],
                    null, null, 'Manual entry', $data['assigned_to'] ?? ''
                );
                echo json_encode(["message" => "Asset created", "id" => $newId]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Failed to create asset"]);
            }
            break;
        }

        http_response_code(405);
        echo json_encode(["error" => "Method not allowed"]);
        exit;

    // ========================================================================
    // ASSET (single: GET / PUT / DELETE)
    // ========================================================================
    case 'asset':
        if (!$id || !ctype_digit($id)) {
            http_response_code(400);
            echo json_encode(["error" => "Invalid asset ID"]);
            exit;
        }
        $nid = (int)$id;

        if ($method === 'GET') {
            $stmt = $conn->prepare("SELECT * FROM assets WHERE id = ?");
            $stmt->bind_param("i", $nid);
            $stmt->execute();
            $asset = $stmt->get_result()->fetch_assoc();
            if (!$asset) {
                http_response_code(404);
                echo json_encode(["error" => "Asset not found"]);
                exit;
            }
            echo json_encode($asset);

        } elseif ($method === 'PUT') {
            $data = json_decode(file_get_contents("php://input"), true);
            if (!$data) {
                http_response_code(400);
                echo json_encode(["error" => "Invalid JSON"]);
                exit;
            }

            $before = getAssetState($conn, $nid);

            $fields = ['asset_tag','serial_no','category','make_model','description','location','room_no','assigned_to','department','status','notes'];
            $setParts = []; $params = []; $types = '';
            foreach ($fields as $f) {
                if (isset($data[$f])) {
                    $setParts[] = "$f = ?";
                    $params[] = $data[$f];
                    $types .= 's';
                }
            }
            if (empty($setParts)) {
                http_response_code(400);
                echo json_encode(["error" => "No fields to update"]);
                exit;
            }
            $params[] = $nid;
            $types .= 'i';
            $sql = "UPDATE assets SET " . implode(', ', $setParts) . " WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param($types, ...$params);
            $stmt->execute();

            if ($stmt->affected_rows === 0 && !isset($data['notes'])) {
                http_response_code(404);
                echo json_encode(["error" => "Asset not found or no changes"]);
                exit;
            }

            $after = getAssetState($conn, $nid);
            if ($before['status'] !== $after['status'] || $before['location'] !== $after['location'] ||
                $before['department'] !== $after['department'] || $before['assigned_to'] !== $after['assigned_to']) {
                logMovement($conn, 'asset', $nid, 'Adjusted', $before, $after, null, null, $data['notes'] ?? 'Manual update', $data['assigned_to'] ?? '');
            }

            echo json_encode(["message" => "Asset updated successfully"]);

        } elseif ($method === 'DELETE') {
            $stmt = $conn->prepare("DELETE FROM assets WHERE id = ?");
            $stmt->bind_param("i", $nid);
            $stmt->execute();
            if ($stmt->affected_rows === 0) {
                http_response_code(404);
                echo json_encode(["error" => "Asset not found"]);
                exit;
            }
            echo json_encode(["message" => "Asset deleted successfully"]);

        } else {
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
        }
        break;

    // ========================================================================
    // MOVEMENTS (timeline for ONE asset)
    // ========================================================================
    case 'movements':
        if ($method !== 'GET' || !$id || !ctype_digit($id)) {
            http_response_code(400);
            echo json_encode(["error" => "Asset ID required"]);
            exit;
        }
        $stmt = $conn->prepare(
            "SELECT m.*, a.asset_tag, a.serial_no, a.category, a.make_model
             FROM movements m
             LEFT JOIN assets a ON m.item_type='asset' AND m.item_id = a.id
             WHERE m.item_type='asset' AND m.item_id = ?
             ORDER BY m.created_at DESC"
        );
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        echo json_encode(["count" => count($data), "data" => $data]);
        break;

    // ========================================================================
    // ALL MOVEMENTS (global, filterable)
    // ========================================================================
    case 'all_movements':
        if ($method !== 'GET') {
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
            exit;
        }
        $fromDate = $_GET['from_date'] ?? '';
        $toDate   = $_GET['to_date'] ?? '';
        $type     = $_GET['type'] ?? '';
        $limit    = isset($_GET['limit']) ? min((int)$_GET['limit'], 5000) : 1000;

        $where = ["m.item_type = 'asset'"]; $params = []; $types = '';
        if ($fromDate !== '') { $where[] = "m.created_at >= ?"; $params[] = $fromDate . ' 00:00:00'; $types .= 's'; }
        if ($toDate !== '')   { $where[] = "m.created_at <= ?"; $params[] = $toDate . ' 23:59:59'; $types .= 's'; }
        if ($type !== '')     { $where[] = "m.movement_type = ?"; $params[] = $type; $types .= 's'; }

        $sql = "SELECT m.*, a.asset_tag, a.serial_no, a.category, a.make_model
                FROM movements m
                LEFT JOIN assets a ON m.item_type='asset' AND m.item_id = a.id
                WHERE " . implode(' AND ', $where) . "
                ORDER BY m.created_at DESC LIMIT $limit";

        $stmt = $conn->prepare($sql);
        if ($types !== '') $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        echo json_encode(["count" => count($data), "data" => $data]);
        break;

    // ========================================================================
    // STOCK ITEMS
    // ========================================================================
    case 'stock':
        // /stock/available — stock NOT yet issued (for GI dropdown)
        if ($id === 'available') {
            if ($method !== 'GET') {
                http_response_code(405);
                echo json_encode(["error" => "Method not allowed"]);
                exit;
            }
            $sql = "SELECT si.*, gri.description AS gr_description, gr.supplier_name, gr.lpo_number, gr.delivery_date
                    FROM stock_items si
                    LEFT JOIN goods_received_items gri ON si.gr_item_id = gri.id
                    LEFT JOIN goods_received gr ON gri.goods_received_id = gr.id
                    LEFT JOIN goods_issued_items gii ON si.id = gii.stock_item_id
                    WHERE gii.id IS NULL
                    ORDER BY si.item_code";
            $result = $conn->query($sql);
            $data = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["count" => count($data), "data" => $data]);
            break;
        }

        // /stock (list) or /stock (create)
        if ($id === null) {
            if ($method === 'GET') {
                $search   = $_GET['search'] ?? '';
                $category = $_GET['category'] ?? '';
                $source   = $_GET['source'] ?? '';
                $sort     = $_GET['sort'] ?? 'item_code';
                $order    = strtoupper($_GET['order'] ?? 'ASC') === 'DESC' ? 'DESC' : 'ASC';
                $allowedSort = ['id','item_code','serial_no','category','make_model','source','created_at'];
                if (!in_array($sort, $allowedSort)) $sort = 'item_code';

                $where = ["si.id NOT IN (SELECT COALESCE(stock_item_id,0) FROM goods_issued_items)"];
                $params = []; $types = '';

                if ($search !== '') {
                    $where[] = "(si.item_code LIKE ? OR si.serial_no LIKE ? OR si.category LIKE ? OR si.make_model LIKE ?)";
                    $t = "%$search%";
                    $params = array_merge($params, [$t, $t, $t, $t]);
                    $types .= 'ssss';
                }
                if ($category !== '') { $where[] = "si.category = ?"; $params[] = $category; $types .= 's'; }
                if ($source !== '')   { $where[] = "si.source = ?";   $params[] = $source;   $types .= 's'; }

                $sql = "SELECT si.* FROM stock_items si WHERE " . implode(' AND ', $where) . " ORDER BY si.$sort $order";
                $stmt = $conn->prepare($sql);
                if ($types !== '') $stmt->bind_param($types, ...$params);
                $stmt->execute();
                $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
                echo json_encode(["count" => count($data), "data" => $data]);
                break;
            }

            if ($method === 'POST') {
                $input = json_decode(file_get_contents("php://input"), true);
                if (!$input || empty($input['item_code']) || empty($input['category'])) {
                    http_response_code(400);
                    echo json_encode(["error" => "item_code and category are required"]);
                    exit;
                }

                $stmt = $conn->prepare(
                    "INSERT INTO stock_items (item_code, serial_no, category, make_model, description, source, gr_item_id, notes)
                     VALUES (?, ?, ?, ?, ?, 'manual', NULL, ?)"
                );
                $stmt->bind_param("ssssss",
                    $input['item_code'],
                    $input['serial_no'] ?? '',
                    $input['category'],
                    $input['make_model'] ?? '',
                    $input['description'] ?? '',
                    $input['notes'] ?? ''
                );
                $stmt->execute();

                if ($stmt->affected_rows > 0) {
                    $newId = $conn->insert_id;
                    logMovement($conn, 'stock', $newId, 'Adjusted',
                        ['status'=>'','location'=>'','department'=>'','assigned_to'=>''],
                        ['status'=>'In Store','location'=>'Store','department'=>'','assigned_to'=>''],
                        null, null, 'Manual stock entry', $input['notes'] ?? ''
                    );
                    echo json_encode(["message" => "Stock item created", "id" => $newId]);
                } else {
                    http_response_code(500);
                    echo json_encode(["error" => "Failed to create stock item"]);
                }
                break;
            }

            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
            exit;
        }

        // /stock/{id} (GET single / DELETE)
        if (ctype_digit($id)) {
            $nid = (int)$id;

            if ($method === 'GET') {
                $stmt = $conn->prepare("SELECT si.*, gri.description AS gr_description, gr.supplier_name, gr.lpo_number, gr.delivery_date
                    FROM stock_items si
                    LEFT JOIN goods_received_items gri ON si.gr_item_id = gri.id
                    LEFT JOIN goods_received gr ON gri.goods_received_id = gr.id
                    WHERE si.id = ?");
                $stmt->bind_param("i", $nid);
                $stmt->execute();
                $item = $stmt->get_result()->fetch_assoc();
                if (!$item) {
                    http_response_code(404);
                    echo json_encode(["error" => "Stock item not found"]);
                    exit;
                }
                echo json_encode($item);
                break;
            }

            if ($method === 'DELETE') {
                $check = $conn->prepare("SELECT COUNT(*) AS cnt FROM goods_issued_items WHERE stock_item_id = ?");
                $check->bind_param("i", $nid);
                $check->execute();
                $used = (int)$check->get_result()->fetch_assoc()['cnt'];
                if ($used > 0) {
                    http_response_code(400);
                    echo json_encode(["error" => "Cannot delete stock item that has been issued"]);
                    exit;
                }
                $stmt = $conn->prepare("DELETE FROM stock_items WHERE id = ?");
                $stmt->bind_param("i", $nid);
                $stmt->execute();
                if ($stmt->affected_rows === 0) {
                    http_response_code(404);
                    echo json_encode(["error" => "Stock item not found"]);
                    exit;
                }
                echo json_encode(["message" => "Stock item deleted successfully"]);
                break;
            }

            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
            exit;
        }

        http_response_code(400);
        echo json_encode(["error" => "Invalid stock ID"]);
        exit;

    // ========================================================================
    // GOODS RECEIVED
    // ========================================================================
    case 'goods_received':
        if ($method === 'GET') {
            $search = $_GET['search'] ?? '';
            $from   = $_GET['from_date'] ?? '';
            $to     = $_GET['to_date'] ?? '';

            $where = []; $params = []; $types = '';
            if ($search !== '') {
                $where[] = "(lpo_number LIKE ? OR supplier_name LIKE ? OR received_by LIKE ?)";
                $t = "%$search%";
                $params = array_merge($params, [$t, $t, $t]);
                $types .= 'sss';
            }
            if ($from !== '') { $where[] = "delivery_date >= ?"; $params[] = $from; $types .= 's'; }
            if ($to !== '')   { $where[] = "delivery_date <= ?"; $params[] = $to; $types .= 's'; }

            $sql = "SELECT gr.*, (SELECT COUNT(*) FROM goods_received_items WHERE goods_received_id = gr.id) AS items_count FROM goods_received gr";
            if (count($where)) $sql .= " WHERE " . implode(' AND ', $where);
            $sql .= " ORDER BY gr.created_at DESC";

            $stmt = $conn->prepare($sql);
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["count" => count($data), "data" => $data]);
            break;
        }

        if ($method === 'POST') {
            $input = json_decode(file_get_contents("php://input"), true);
            if (!$input || empty($input['supplier_name']) || empty($input['lpo_number']) || empty($input['delivery_date']) || empty($input['items'])) {
                http_response_code(400);
                echo json_encode(["error" => "supplier_name, lpo_number, delivery_date, and items[] are required"]);
                exit;
            }

            $conn->begin_transaction();
            try {
                $stmt = $conn->prepare(
                    "INSERT INTO goods_received (supplier_name, lpo_number, delivery_date, procurement_dept, has_invoice, has_lpo, has_delivery_note, notes, received_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                );
                $stmt->bind_param("sssssssss",
                    $input['supplier_name'], $input['lpo_number'], $input['delivery_date'],
                    $input['procurement_dept'] ?? '',
                    isset($input['has_invoice']) ? ($input['has_invoice'] ? '1' : '0') : '0',
                    isset($input['has_lpo']) ? ($input['has_lpo'] ? '1' : '0') : '0',
                    isset($input['has_delivery_note']) ? ($input['has_delivery_note'] ? '1' : '0') : '0',
                    $input['notes'] ?? '', $input['received_by'] ?? ''
                );
                $stmt->execute();
                $grId = $conn->insert_id;

                $stmtItem = $conn->prepare(
                    "INSERT INTO goods_received_items (goods_received_id, description, quantity, category, unit_cost, serial_numbers)
                     VALUES (?, ?, ?, ?, ?, ?)"
                );
                $stmtStock = $conn->prepare(
                    "INSERT INTO stock_items (item_code, serial_no, category, make_model, description, source, gr_item_id, notes)
                     VALUES (?, ?, ?, ?, ?, 'received', ?, ?)"
                );

                $r = $conn->query("SELECT item_code FROM stock_items ORDER BY id DESC LIMIT 1");
                $nextSeq = 1;
                if ($r && $r->num_rows) {
                    $lastCode = $r->fetch_assoc()['item_code'];
                    if (preg_match('/(\d+)$/', $lastCode, $m)) $nextSeq = (int)$m[1] + 1;
                }

                foreach ($input['items'] as $item) {
                    $description = $item['description'] ?? '';
                    $qty = (int)($item['quantity'] ?? 1);
                    $cat = $item['category'] ?? '';
                    $cost = !empty($item['unit_cost']) ? (float)$item['unit_cost'] : 0.00;
                    $serials = $item['serial_numbers'] ?? '';
                    $makeModel = $item['make_model'] ?? '';

                    $stmtItem->bind_param("isisds", $grId, $description, $qty, $cat, $cost, $serials);
                    $stmtItem->execute();
                    $grItemId = $conn->insert_id;

                    $serialList = array_map('trim', explode(',', $serials));
                    for ($i = 0; $i < $qty; $i++) {
                        $code = sprintf("STK%05d", $nextSeq++);
                        $sn = isset($serialList[$i]) ? trim($serialList[$i]) : '';
                        $stmtStock->bind_param("sssssis",
                            $code, $sn, $cat, $makeModel, $description, $grItemId, $input['notes'] ?? ''
                        );
                        $stmtStock->execute();
                        $stockId = $conn->insert_id;

                        logMovement($conn, 'stock', $stockId, 'Received',
                            ['status'=>'','location'=>'','department'=>'','assigned_to'=>''],
                            ['status'=>'In Store','location'=>'Store','department'=>'','assigned_to'=>''],
                            'goods_received', $grId, "From: {$input['supplier_name']}, LPO: {$input['lpo_number']}", $input['received_by'] ?? ''
                        );
                    }
                }

                $conn->commit();
                echo json_encode(["message" => "Goods received recorded", "id" => $grId]);
            } catch (Exception $e) {
                $conn->rollback();
                http_response_code(500);
                echo json_encode(["error" => "Transaction failed: " . $e->getMessage()]);
            }
            break;
        }

        http_response_code(405);
        echo json_encode(["error" => "Method not allowed"]);
        exit;

    // ========================================================================
    // GOODS RECEIVED ITEM (single GR detail / delete)
    // ========================================================================
    case 'goods_received_item':
        if (!$id || !ctype_digit($id)) { http_response_code(400); echo json_encode(["error" => "Invalid ID"]); exit; }
        $nid = (int)$id;

        if ($method === 'GET') {
            $stmt = $conn->prepare("SELECT * FROM goods_received WHERE id = ?");
            $stmt->bind_param("i", $nid);
            $stmt->execute();
            $header = $stmt->get_result()->fetch_assoc();
            if (!$header) { http_response_code(404); echo json_encode(["error" => "Not found"]); exit; }

            $stmt2 = $conn->prepare("SELECT * FROM goods_received_items WHERE goods_received_id = ?");
            $stmt2->bind_param("i", $nid);
            $stmt2->execute();
            $header['items'] = $stmt2->get_result()->fetch_all(MYSQLI_ASSOC);

            $stmt3 = $conn->prepare(
                "SELECT a.* FROM assets a
                 JOIN stock_items si ON a.stock_item_id = si.id
                 WHERE si.gr_item_id IN (SELECT id FROM goods_received_items WHERE goods_received_id = ?)"
            );
            $stmt3->bind_param("i", $nid);
            $stmt3->execute();
            $header['assets_created'] = $stmt3->get_result()->fetch_all(MYSQLI_ASSOC);

            echo json_encode($header);

        } elseif ($method === 'DELETE') {
            $conn->begin_transaction();
            try {
                $stmt = $conn->prepare("SELECT si.id AS stock_id FROM stock_items si JOIN goods_received_items gri ON si.gr_item_id = gri.id WHERE gri.goods_received_id = ?");
                $stmt->bind_param("i", $nid);
                $stmt->execute();
                $stockRows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
                $stockIds = array_column($stockRows, 'stock_id');

                $assetIds = [];
                if (!empty($stockIds)) {
                    $placeholders = implode(',', array_fill(0, count($stockIds), '?'));
                    $types = str_repeat('i', count($stockIds));
                    $stmt = $conn->prepare("SELECT id FROM assets WHERE stock_item_id IN ($placeholders)");
                    $stmt->bind_param($types, ...$stockIds);
                    $stmt->execute();
                    $assetRows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
                    $assetIds = array_column($assetRows, 'id');
                }

                foreach ($assetIds as $aid) {
                    $stmt = $conn->prepare("DELETE FROM movements WHERE item_type='asset' AND item_id = ?");
                    $stmt->bind_param("i", $aid); $stmt->execute();
                }
                foreach ($stockIds as $sid) {
                    $stmt = $conn->prepare("DELETE FROM movements WHERE item_type='stock' AND item_id = ?");
                    $stmt->bind_param("i", $sid); $stmt->execute();
                }
                foreach ($assetIds as $aid) {
                    $stmt = $conn->prepare("DELETE FROM assets WHERE id = ?");
                    $stmt->bind_param("i", $aid); $stmt->execute();
                }
                foreach ($stockIds as $sid) {
                    $stmt = $conn->prepare("DELETE FROM stock_items WHERE id = ?");
                    $stmt->bind_param("i", $sid); $stmt->execute();
                }

                $stmt = $conn->prepare("DELETE FROM goods_received_items WHERE goods_received_id = ?");
                $stmt->bind_param("i", $nid); $stmt->execute();

                $stmt = $conn->prepare("DELETE FROM goods_received WHERE id = ?");
                $stmt->bind_param("i", $nid); $stmt->execute();

                $conn->commit();
                echo json_encode(["message" => "Deleted"]);
            } catch (Exception $e) {
                $conn->rollback();
                http_response_code(500);
                echo json_encode(["error" => $e->getMessage()]);
            }
        } else {
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
        }
        break;

    // ========================================================================
    // GOODS ISSUED
    // ========================================================================
    case 'goods_issued':
        if ($method === 'GET') {
            $search = $_GET['search'] ?? '';
            $from   = $_GET['from_date'] ?? '';
            $to     = $_GET['to_date'] ?? '';
            $dept   = $_GET['department'] ?? '';

            $where = []; $params = []; $types = '';
            if ($search !== '') { $where[] = "(department LIKE ? OR officer_name LIKE ? OR issued_by LIKE ?)"; $t = "%$search%"; $params[] = $t; $params[] = $t; $params[] = $t; $types .= 'sss'; }
            if ($from !== '') { $where[] = "issue_date >= ?"; $params[] = $from; $types .= 's'; }
            if ($to !== '')   { $where[] = "issue_date <= ?"; $params[] = $to; $types .= 's'; }
            if ($dept !== '') { $where[] = "department = ?"; $params[] = $dept; $types .= 's'; }

            $sql = "SELECT gi.*, (SELECT COUNT(*) FROM goods_issued_items WHERE goods_issued_id = gi.id) AS items_count FROM goods_issued gi";
            if (count($where)) $sql .= " WHERE " . implode(' AND ', $where);
            $sql .= " ORDER BY gi.created_at DESC";

            $stmt = $conn->prepare($sql);
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["count" => count($data), "data" => $data]);
            break;
        }

        if ($method === 'POST') {
            $input = json_decode(file_get_contents("php://input"), true);
            if (!$input || empty($input['department']) || empty($input['officer_name']) || empty($input['issue_date']) || empty($input['stock_item_ids'])) {
                http_response_code(400);
                echo json_encode(["error" => "department, officer_name, issue_date, and stock_item_ids[] are required"]);
                exit;
            }

            $conn->begin_transaction();
            try {
                $stmt = $conn->prepare("INSERT INTO goods_issued (department, officer_name, officer_title, issue_date, notes, issued_by) VALUES (?, ?, ?, ?, ?, ?)");
                $stmt->bind_param("ssssss", $input['department'], $input['officer_name'], $input['officer_title'] ?? '', $input['issue_date'], $input['notes'] ?? '', $input['issued_by'] ?? '');
                $stmt->execute();
                $giId = $conn->insert_id;

                $r = $conn->query("SELECT asset_tag FROM assets ORDER BY id DESC LIMIT 1");
                $nextSeq = 1;
                if ($r && $r->num_rows) {
                    $lastTag = $r->fetch_assoc()['asset_tag'];
                    if (preg_match('/(\d+)$/', $lastTag, $m)) $nextSeq = (int)$m[1] + 1;
                }

                $stmtGetStock = $conn->prepare("SELECT * FROM stock_items WHERE id = ?");
                $stmtCreateAsset = $conn->prepare(
                    "INSERT INTO assets (asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, stock_item_id, source, notes)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Issued', ?, 'issued', ?)"
                );
                $stmtGiItem = $conn->prepare("INSERT INTO goods_issued_items (goods_issued_id, stock_item_id, asset_id, notes) VALUES (?, ?, ?, ?)");
                $stmtUpdateGiId = $conn->prepare("UPDATE assets SET gi_item_id = ? WHERE id = ?");

                $issued = 0;
                $skipped = 0;

                foreach ($input['stock_item_ids'] as $sid) {
                    $stmtGetStock->bind_param("i", $sid);
                    $stmtGetStock->execute();
                    $stockItem = $stmtGetStock->get_result()->fetch_assoc();
                    if (!$stockItem) { $skipped++; continue; }

                    $tag = sprintf("AST%05d", $nextSeq++);
                    $loc = $input['location'] ?? $input['department'];

                    $stmtCreateAsset->bind_param("sssssssssis",
                        $tag,
                        $stockItem['serial_no'] ?? '',
                        $stockItem['category'],
                        $stockItem['make_model'] ?? '',
                        $stockItem['description'] ?? '',
                        $loc,
                        $input['room_no'] ?? '',
                        $input['officer_name'],
                        $input['department'],
                        $sid,
                        $input['notes'] ?? ''
                    );
                    $stmtCreateAsset->execute();
                    $assetId = $conn->insert_id;

                    $stmtGiItem->bind_param("iiis", $giId, $sid, $assetId, $input['notes'] ?? '');
                    $stmtGiItem->execute();
                    $giItemId = $conn->insert_id;

                    $stmtUpdateGiId->bind_param("ii", $giItemId, $assetId);
                    $stmtUpdateGiId->execute();

                    $before = ['status'=>'In Store','location'=>'Store','department'=>'','assigned_to'=>''];
                    $after = ['status'=>'Issued','location'=>$loc,'department'=>$input['department'],'assigned_to'=>$input['officer_name']];
                    logMovement($conn, 'asset', $assetId, 'Issued', $before, $after,
                        'goods_issued', $giId, "Issued to: {$input['officer_name']}, {$input['department']}", $input['issued_by'] ?? ''
                    );
                    $issued++;
                }

                $conn->commit();
                echo json_encode(["message" => "Goods issued", "id" => $giId, "issued" => $issued, "skipped" => $skipped]);
            } catch (Exception $e) {
                $conn->rollback();
                http_response_code(500);
                echo json_encode(["error" => "Transaction failed: " . $e->getMessage()]);
            }
            break;
        }

        http_response_code(405);
        echo json_encode(["error" => "Method not allowed"]);
        exit;

    // ========================================================================
    // GOODS ISSUED ITEM (single GI detail)
    // ========================================================================
    case 'goods_issued_item':
        if (!$id || !ctype_digit($id)) { http_response_code(400); echo json_encode(["error" => "Invalid ID"]); exit; }
        $nid = (int)$id;
        if ($method === 'GET') {
            $stmt = $conn->prepare("SELECT * FROM goods_issued WHERE id = ?");
            $stmt->bind_param("i", $nid);
            $stmt->execute();
            $header = $stmt->get_result()->fetch_assoc();
            if (!$header) { http_response_code(404); echo json_encode(["error" => "Not found"]); exit; }

            $stmt2 = $conn->prepare(
                "SELECT gii.*,
                        si.item_code, si.serial_no AS stock_serial_no, si.category AS stock_category,
                        si.make_model AS stock_make_model, si.description AS stock_description,
                        a.asset_tag, a.serial_no AS asset_serial_no, a.category AS asset_category,
                        a.make_model AS asset_make_model, a.description AS asset_description,
                        a.location, a.room_no, a.assigned_to, a.department, a.status
                 FROM goods_issued_items gii
                 LEFT JOIN stock_items si ON gii.stock_item_id = si.id
                 LEFT JOIN assets a ON gii.asset_id = a.id
                 WHERE gii.goods_issued_id = ?"
            );
            $stmt2->bind_param("i", $nid);
            $stmt2->execute();
            $header['items'] = $stmt2->get_result()->fetch_all(MYSQLI_ASSOC);
            echo json_encode($header);
        } else {
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
        }
        break;

    // ========================================================================
    // GOODS ISSUED DELETE (cascade)
    // ========================================================================
    case 'goods_issued_del':
        if ($method !== 'DELETE' || !$id || !ctype_digit($id)) { http_response_code(400); echo json_encode(["error" => "Invalid ID"]); exit; }
        $nid = (int)$id;

        $conn->begin_transaction();
        try {
            $stmt = $conn->prepare("SELECT asset_id, stock_item_id FROM goods_issued_items WHERE goods_issued_id = ?");
            $stmt->bind_param("i", $nid);
            $stmt->execute();
            $giItems = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

            foreach ($giItems as $item) {
                if (!empty($item['asset_id'])) {
                    $stmt = $conn->prepare("DELETE FROM movements WHERE item_type='asset' AND item_id = ?");
                    $stmt->bind_param("i", $item['asset_id']); $stmt->execute();
                    $stmt = $conn->prepare("DELETE FROM assets WHERE id = ?");
                    $stmt->bind_param("i", $item['asset_id']); $stmt->execute();
                }
            }

            $stmt = $conn->prepare("DELETE FROM goods_issued_items WHERE goods_issued_id = ?");
            $stmt->bind_param("i", $nid); $stmt->execute();

            $stmt = $conn->prepare("DELETE FROM goods_issued WHERE id = ?");
            $stmt->bind_param("i", $nid); $stmt->execute();

            $conn->commit();
            echo json_encode(["message" => "Deleted"]);
        } catch (Exception $e) {
            $conn->rollback();
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    // ========================================================================
    // RETURN ASSETS TO STORE
    // ========================================================================
    case 'return_assets':
        if ($method !== 'POST') {
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
            exit;
        }
        $input = json_decode(file_get_contents("php://input"), true);
        if (!$input || empty($input['asset_ids'])) {
            http_response_code(400);
            echo json_encode(["error" => "asset_ids[] required"]);
            exit;
        }

        $conn->begin_transaction();
        try {
            $stmtUpd = $conn->prepare("UPDATE assets SET status = 'Returned' WHERE id = ? AND status != 'Returned'");
            $returned = 0;
            foreach ($input['asset_ids'] as $aid) {
                $before = getAssetState($conn, $aid);
                if ($before['status'] === 'Returned') continue;
                $stmtUpd->bind_param("i", $aid);
                $stmtUpd->execute();
                if ($stmtUpd->affected_rows > 0) {
                    $after = getAssetState($conn, $aid);
                    logMovement($conn, 'asset', $aid, 'Returned', $before, $after, 'return', null, $input['notes'] ?? '', $input['changed_by'] ?? '');
                    $returned++;
                }
            }
            $conn->commit();
            echo json_encode(["message" => "$returned asset(s) returned to store", "returned" => $returned]);
        } catch (Exception $e) {
            $conn->rollback();
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    // ========================================================================
    // DEPARTMENTS
    // ========================================================================
    case 'departments':
        if ($method === 'GET') {
            $result = $conn->query("SELECT * FROM departments ORDER BY name");
            $data = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["count" => count($data), "data" => $data]);
            break;
        }
        if ($method === 'POST') {
            $input = json_decode(file_get_contents("php://input"), true);
            if (!$input || empty($input['name'])) { http_response_code(400); echo json_encode(["error" => "Department name required"]); exit; }
            $stmt = $conn->prepare("INSERT INTO departments (name, floor, head) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $input['name'], $input['floor'] ?? '', $input['head'] ?? '');
            $stmt->execute();
            echo json_encode(["message" => "Department created", "id" => $conn->insert_id]);
            break;
        }
        http_response_code(405);
        echo json_encode(["error" => "Method not allowed"]);
        exit;

    // ========================================================================
    // STATS
    // ========================================================================
    case 'stats':
        if ($method !== 'GET') { http_response_code(405); echo json_encode(["error" => "Method not allowed"]); exit; }
        $stats = [];

        $r = $conn->query("SELECT COUNT(*) AS total FROM stock_items"); $stats['total_stock'] = (int)$r->fetch_assoc()['total'];
        $r = $conn->query("SELECT COUNT(*) AS total FROM assets"); $stats['total_assets'] = (int)$r->fetch_assoc()['total'];
        $stats['total_items'] = $stats['total_stock'] + $stats['total_assets'];

        $r = $conn->query("SELECT COUNT(*) AS cnt FROM stock_items WHERE id NOT IN (SELECT COALESCE(stock_item_id,0) FROM goods_issued_items)"); $stats['in_store'] = (int)$r->fetch_assoc()['cnt'];

        $r = $conn->query("SELECT status, COUNT(*) AS cnt FROM assets GROUP BY status ORDER BY cnt DESC"); $stats['by_status'] = $r->fetch_all(MYSQLI_ASSOC);
        $r = $conn->query("SELECT category, COUNT(*) AS cnt FROM assets GROUP BY category ORDER BY cnt DESC"); $stats['by_category'] = $r->fetch_all(MYSQLI_ASSOC);
        $r = $conn->query("SELECT location, COUNT(*) AS cnt FROM assets GROUP BY location ORDER BY cnt DESC"); $stats['by_location'] = $r->fetch_all(MYSQLI_ASSOC);
        $r = $conn->query("SELECT department, COUNT(*) AS cnt FROM assets GROUP BY department ORDER BY cnt DESC"); $stats['by_department'] = $r->fetch_all(MYSQLI_ASSOC);

        $r = $conn->query("SELECT COUNT(*) AS cnt FROM assets WHERE status IN ('Damaged','Under Repair')"); $stats['needs_attention'] = (int)$r->fetch_assoc()['cnt'];

        $r = $conn->query("SELECT COUNT(*) AS cnt FROM movements"); $stats['total_movements'] = (int)$r->fetch_assoc()['cnt'];
        $r = $conn->query("SELECT movement_type, COUNT(*) AS cnt FROM movements WHERE DATE(created_at) = CURDATE() GROUP BY movement_type");
        $todayMov = []; while ($row = $r->fetch_assoc()) { $todayMov[$row['movement_type']] = (int)$row['cnt']; }
        $stats['today'] = $todayMov;
        $r = $conn->query("SELECT COUNT(*) AS cnt FROM goods_received"); $stats['total_gr'] = (int)$r->fetch_assoc()['cnt'];
        $r = $conn->query("SELECT COUNT(*) AS cnt FROM goods_issued"); $stats['total_gi'] = (int)$r->fetch_assoc()['cnt'];
        $r = $conn->query("SELECT COUNT(*) AS cnt FROM goods_issued_items gii JOIN goods_issued gi ON gii.goods_issued_id = gi.id WHERE gi.issue_date = CURDATE()"); $stats['today_issued'] = (int)$r->fetch_assoc()['cnt'];

        echo json_encode($stats);
        break;

    // ========================================================================
    // CSV EXPORT (all assets)
    // ========================================================================
    case 'export':
        if ($method !== 'GET') { http_response_code(405); echo json_encode(["error" => "Method not allowed"]); exit; }
        $result = $conn->query("SELECT * FROM assets ORDER BY asset_tag");
        $list = $result->fetch_all(MYSQLI_ASSOC);
        header("Content-Type: text/csv; charset=utf-8");
        header("Content-Disposition: attachment; filename=moes_inventory_export.csv");
        $output = fopen("php://output", "w");
        fputcsv($output, ['Asset Tag','Serial No','Category','Make/Model','Location','Room No','Assigned To','Department','Status','Source','Notes']);
        foreach ($list as $a) { fputcsv($output, [$a['asset_tag'],$a['serial_no'],$a['category'],$a['make_model'],$a['location'],$a['room_no'],$a['assigned_to'],$a['department'],$a['status'],$a['source'],$a['notes']]); }
        fclose($output);
        exit;

    // ========================================================================
    // CSV IMPORT
    // ========================================================================
    case 'import':
        if ($method !== 'POST') { http_response_code(405); echo json_encode(["error" => "Method not allowed"]); exit; }
        if (!isset($_FILES['csv']) || $_FILES['csv']['error'] !== UPLOAD_ERR_OK) { http_response_code(400); echo json_encode(["error" => "CSV file upload required"]); exit; }
        $handle = fopen($_FILES['csv']['tmp_name'], "r");
        $header = fgetcsv($handle);
        if (!$header) { http_response_code(400); echo json_encode(["error" => "Empty CSV file"]); exit; }
        $expected = ['asset_tag','serial_no','category','make_model','location','room_no','assigned_to','department','status','notes'];
        $colMap = [];
        foreach ($expected as $e) { $idx = array_search($e, $header); if ($idx === false && $e !== 'notes') { http_response_code(400); echo json_encode(["error" => "Missing column: $e"]); exit; } $colMap[$e] = $idx; }
        $stmt = $conn->prepare("INSERT INTO assets (asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, source, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'manual', ?) ON DUPLICATE KEY UPDATE serial_no=VALUES(serial_no), make_model=VALUES(make_model), description=VALUES(description), location=VALUES(location), room_no=VALUES(room_no), assigned_to=VALUES(assigned_to), department=VALUES(department), status=VALUES(status), notes=VALUES(notes)");
        $imported = 0; $errors = 0;
        while (($row = fgetcsv($handle)) !== false) {
            if (count($row) < count($expected) - 1) { $errors++; continue; }
            $asset_tag  = $row[$colMap['asset_tag']] ?? '';
            $serial_no  = $row[$colMap['serial_no']] ?? '';
            $category   = $row[$colMap['category']] ?? '';
            $make_model = $row[$colMap['make_model']] ?? '';
            $location   = $row[$colMap['location']] ?? '';
            $room_no    = $row[$colMap['room_no']] ?? '';
            $assigned   = $row[$colMap['assigned_to']] ?? '';
            $dept       = $row[$colMap['department']] ?? '';
            $status     = $row[$colMap['status']] ?? 'Issued';
            $notes      = $colMap['notes'] !== false ? ($row[$colMap['notes']] ?? '') : '';
            if (empty($asset_tag) || empty($category) || empty($location)) { $errors++; continue; }
            $desc = '';
            $stmt->bind_param("ssssssssssss", $asset_tag, $serial_no, $category, $make_model, $desc, $location, $room_no, $assigned, $dept, $status, $notes, $status);
            $stmt->execute();
            $imported++;
        }
        fclose($handle);
        echo json_encode(["message" => "Import complete", "imported" => $imported, "skipped" => $errors]);
        break;

    // ========================================================================
    // REPORT / CSV EXPORT — generic handler
    // ========================================================================
    case 'report':
    case 'csv_export':
        $isPdf = ($route === 'report');
        $type  = $_GET['type'] ?? 'assets';
        $from  = $_GET['from_date'] ?? '';
        $to    = $_GET['to_date'] ?? '';

        if ($type === 'assets') {
            $category   = $_GET['category'] ?? '';
            $location   = $_GET['location'] ?? '';
            $status     = $_GET['status'] ?? '';
            $department = $_GET['department'] ?? '';
            $where = []; $params = []; $types = '';
            if ($from !== '') { $where[] = "a.created_at >= ?"; $params[] = $from . ' 00:00:00'; $types .= 's'; }
            if ($to !== '')   { $where[] = "a.created_at <= ?"; $params[] = $to . ' 23:59:59'; $types .= 's'; }
            if ($category !== '')   { $where[] = "a.category = ?";   $params[] = $category;   $types .= 's'; }
            if ($location !== '')   { $where[] = "a.location = ?";   $params[] = $location;   $types .= 's'; }
            if ($status !== '')     { $where[] = "a.status = ?";     $params[] = $status;     $types .= 's'; }
            if ($department !== '') { $where[] = "a.department = ?"; $params[] = $department; $types .= 's'; }
            $wc = count($where) ? ' WHERE ' . implode(' AND ', $where) : '';
            $stmt = $conn->prepare("SELECT a.* FROM assets a$wc ORDER BY a.location, a.category, a.asset_tag");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'ICT ASSET INVENTORY REPORT';

        } elseif ($type === 'gr') {
            $grId = $_GET['id'] ?? '';
            $where = []; $params = []; $types = '';
            if ($grId !== '' && ctype_digit($grId)) { $where[] = "gr.id = ?"; $params[] = (int)$grId; $types .= 'i'; }
            if ($from !== '') { $where[] = "gr.delivery_date >= ?"; $params[] = $from; $types .= 's'; }
            if ($to !== '')   { $where[] = "gr.delivery_date <= ?"; $params[] = $to; $types .= 's'; }
            $wc = count($where) ? ' WHERE ' . implode(' AND ', $where) : '';
            $stmt = $conn->prepare("SELECT gr.* FROM goods_received gr$wc ORDER BY gr.delivery_date DESC");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'GOODS RECEIVED REPORT';

        } elseif ($type === 'gi') {
            $dept = $_GET['department'] ?? '';
            $where = []; $params = []; $types = '';
            if ($from !== '') { $where[] = "issue_date >= ?"; $params[] = $from; $types .= 's'; }
            if ($to !== '')   { $where[] = "issue_date <= ?"; $params[] = $to; $types .= 's'; }
            if ($dept !== '') { $where[] = "department = ?"; $params[] = $dept; $types .= 's'; }
            $wc = count($where) ? ' WHERE ' . implode(' AND ', $where) : '';
            $stmt = $conn->prepare("SELECT * FROM goods_issued$wc ORDER BY issue_date DESC");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'GOODS ISSUED REPORT';

        } elseif ($type === 'movements') {
            $movType = $_GET['movement_type'] ?? '';
            $where = ["m.item_type = 'asset'"]; $params = []; $types = '';
            if ($from !== '') { $where[] = "m.created_at >= ?"; $params[] = $from . ' 00:00:00'; $types .= 's'; }
            if ($to !== '')   { $where[] = "m.created_at <= ?"; $params[] = $to . ' 23:59:59'; $types .= 's'; }
            if ($movType !== '') { $where[] = "m.movement_type = ?"; $params[] = $movType; $types .= 's'; }
            $stmt = $conn->prepare("SELECT m.*, a.asset_tag, a.serial_no, a.category, a.make_model FROM movements m LEFT JOIN assets a ON m.item_type='asset' AND m.item_id = a.id WHERE " . implode(' AND ', $where) . " ORDER BY m.created_at DESC LIMIT 2000");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'STOCK MOVEMENT REPORT';

        } elseif ($type === 'damaged') {
            $where = []; $params = []; $types = '';
            if ($from !== '') { $where[] = "updated_at >= ?"; $params[] = $from . ' 00:00:00'; $types .= 's'; }
            if ($to !== '')   { $where[] = "updated_at <= ?"; $params[] = $to . ' 23:59:59'; $types .= 's'; }
            $wc = count($where) ? ' AND ' . implode(' AND ', $where) : '';
            $stmt = $conn->prepare("SELECT * FROM assets WHERE status IN ('Damaged','Disposed','Under Repair')$wc ORDER BY updated_at DESC");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'DAMAGED / DISPOSED REPORT';

        } elseif ($type === 'stock') {
            $category = $_GET['category'] ?? '';
            $source   = $_GET['source'] ?? '';
            $where = []; $params = []; $types = '';
            if ($from !== '') { $where[] = "created_at >= ?"; $params[] = $from . ' 00:00:00'; $types .= 's'; }
            if ($to !== '')   { $where[] = "created_at <= ?"; $params[] = $to . ' 23:59:59'; $types .= 's'; }
            if ($category !== '') { $where[] = "category = ?"; $params[] = $category; $types .= 's'; }
            if ($source !== '')   { $where[] = "source = ?";   $params[] = $source;   $types .= 's'; }
            $where[] = "id NOT IN (SELECT COALESCE(stock_item_id,0) FROM goods_issued_items)";
            $wc = ' WHERE ' . implode(' AND ', $where);
            $stmt = $conn->prepare("SELECT * FROM stock_items$wc ORDER BY item_code");
            if ($types !== '') $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            $title = 'STOCK ITEMS REPORT';

        } else {
            http_response_code(400);
            echo json_encode(["error" => "Invalid report type: $type"]);
            exit;
        }

        if (!$isPdf) {
            header("Content-Type: text/csv; charset=utf-8");
            header("Content-Disposition: attachment; filename=moes_{$type}_report.csv");
            $output = fopen("php://output", "w");
            if (count($rows)) fputcsv($output, array_keys($rows[0]));
            foreach ($rows as $r) fputcsv($output, $r);
            fclose($output);
            exit;
        }

        require_once __DIR__ . '/fpdf/fpdf.php';
        $pdf = new FPDF();
        $pdf->AddPage();
        $pdf->SetFont('Times', 'B', 18);
        $pdf->Cell(0, 12, 'MINISTRY OF EDUCATION AND SPORTS', 0, 1, 'C');
        $pdf->SetFont('Times', 'B', 14);
        $pdf->Cell(0, 10, $title, 0, 1, 'C');
        $pdf->Ln(4);
        $pdf->SetFont('Times', '', 11);
        $pdf->Cell(0, 7, 'Total Records: ' . count($rows), 0, 1);
        $pdf->Cell(0, 7, 'Generated: ' . date('d F Y, H:i'), 0, 1);
        if ($from && $to) $pdf->Cell(0, 7, "Period: $from  to  $to", 0, 1);
        $pdf->Ln(6);

        if ($type === 'assets') {
            $headers = ['#','Asset Tag','Category','Location','Assigned To','Status'];
            $widths  = [8,48,28,22,48,28];
        } elseif ($type === 'gr') {
            $headers = ['#','LPO No.','Supplier','Delivery Date','Received By'];
            $widths  = [8,48,50,30,40];
        } elseif ($type === 'gi') {
            $headers = ['#','Department','Officer','Issue Date','Issued By'];
            $widths  = [8,48,44,30,40];
        } elseif ($type === 'movements') {
            $headers = ['#','Asset Tag','Type','From','To','Date'];
            $widths  = [8,36,28,42,42,20];
        } elseif ($type === 'damaged') {
            $headers = ['#','Asset Tag','Category','Location','Status','Notes'];
            $widths  = [8,48,28,22,28,36];
        } elseif ($type === 'stock') {
            $headers = ['#','Item Code','Serial No','Category','Make/Model','Source'];
            $widths  = [8,36,36,28,36,20];
        }

        $pdf->SetFont('Times', 'B', 9);
        $pdf->SetFillColor(28, 58, 92);
        $pdf->SetTextColor(255, 255, 255);
        foreach ($headers as $i => $h) $pdf->Cell($widths[$i], 8, $h, 1, 0, 'C', true);
        $pdf->Ln();
        $pdf->SetFont('Times', '', 8);
        $pdf->SetTextColor(0, 0, 0);
        $fill = false; $num = 1;
        foreach ($rows as $row) {
            if ($pdf->GetY() > 260) {
                $pdf->AddPage();
                $pdf->SetFont('Times', 'B', 9);
                $pdf->SetFillColor(28, 58, 92);
                $pdf->SetTextColor(255, 255, 255);
                foreach ($headers as $i => $h) $pdf->Cell($widths[$i], 8, $h, 1, 0, 'C', true);
                $pdf->Ln();
                $pdf->SetFont('Times', '', 8);
                $pdf->SetTextColor(0, 0, 0);
            }
            if ($fill) $pdf->SetFillColor(240, 244, 248);
            else $pdf->SetFillColor(255, 255, 255);

            $vals = [];
            if ($type === 'assets') {
                $tag = strlen($row['asset_tag']??'') > 20 ? substr($row['asset_tag'],0,19).'..' : ($row['asset_tag']??'-');
                $name = strlen($row['assigned_to']??'') > 24 ? substr($row['assigned_to'],0,23).'..' : ($row['assigned_to']??'-');
                $vals = [$num, $tag, $row['category']??'', $row['location']??'', $name, $row['status']??''];
            } elseif ($type === 'gr') {
                $vals = [$num, $row['lpo_number']??'', $row['supplier_name']??'', $row['delivery_date']??'', $row['received_by']??'-'];
            } elseif ($type === 'gi') {
                $vals = [$num, $row['department']??'', $row['officer_name']??'', $row['issue_date']??'', $row['issued_by']??'-'];
            } elseif ($type === 'movements') {
                $tag = strlen($row['asset_tag']??'') > 16 ? substr($row['asset_tag'],0,15).'..' : ($row['asset_tag']??'-');
                $from = $row['from_status'] ?: ($row['from_location'] ?: '-');
                $to = $row['to_status'] ?: ($row['to_location'] ?: '-');
                $dt = substr($row['created_at']??'',0,10);
                $vals = [$num, $tag, $row['movement_type']??'', $from, $to, $dt];
            } elseif ($type === 'damaged') {
                $tag = strlen($row['asset_tag']??'') > 20 ? substr($row['asset_tag'],0,19).'..' : ($row['asset_tag']??'-');
                $notes = strlen($row['notes']??'') > 20 ? substr($row['notes'],0,19).'..' : ($row['notes']??'-');
                $vals = [$num, $tag, $row['category']??'', $row['location']??'', $row['status']??'', $notes];
            } elseif ($type === 'stock') {
                $code = strlen($row['item_code']??'') > 18 ? substr($row['item_code'],0,17).'..' : ($row['item_code']??'-');
                $sn = strlen($row['serial_no']??'') > 18 ? substr($row['serial_no'],0,17).'..' : ($row['serial_no']??'-');
                $mm = strlen($row['make_model']??'') > 18 ? substr($row['make_model'],0,17).'..' : ($row['make_model']??'-');
                $vals = [$num, $code, $sn, $row['category']??'', $mm, $row['source']??''];
            }

            foreach ($vals as $i => $v) $pdf->Cell($widths[$i], 6, $v, 1, 0, 'C', true);
            $pdf->Ln();
            $fill = !$fill; $num++;
        }
        $pdf->Ln(8);
        $pdf->SetFont('Times', 'I', 9);
        $pdf->Cell(0, 6, 'MoES Store & ICT Department  |  Confidential', 0, 1, 'C');
        $fn = "moes_{$type}_report.pdf";
        header('Content-Type: application/pdf');
        header("Content-Disposition: attachment; filename=\"$fn\"");
        $pdf->Output('D', $fn);
        exit;

    default:
        http_response_code(404);
        echo json_encode(["error" => "Endpoint not found"]);
}

$conn->close();
