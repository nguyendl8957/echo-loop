extends Node2D

## Test scene độc lập cho TV3 kiểm tra Level 01 grid và puzzle data bằng F6
## Tuân thủ đúng cấu trúc node và contract trong Issue #13

var passed_tests: int = 0
var failed_tests: int = 0

const ExitPortalClass := preload("res://scripts/puzzle/exit_portal.gd")
var exit_portal_instance: Node2D
var portal_signal_received: bool = false
var portal_signal_pos: Vector2i = Vector2i(-1, -1)

@onready var level_preview: Node2D = $LevelPreview
@onready var walls_node: Node2D = $LevelPreview/Walls
@onready var interactive_objects: Node2D = $LevelPreview/InteractiveObjects
@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
	run_tests()


func check(condition: bool, description: String) -> void:
	if condition:
		passed_tests += 1
		print("PASS: ", description)
	else:
		failed_tests += 1
		push_error("FAIL: " + description)


func run_tests() -> void:
	print("========================================")
	print("===== ECHO LOOP LEVEL 01 TEST (TV3) =====")
	print("========================================")

	var res_path: String = "res://data/levels/level_01.tres"
	check(FileAccess.file_exists(res_path), "File data/levels/level_01.tres ton tai tren dia")

	# 1. Đọc và phân tích file level_01.tres
	var file := FileAccess.open(res_path, FileAccess.READ)
	check(file != null, "Mo file level_01.tres doc thanh cong")

	var content: String = ""
	if file != null:
		content = file.get_as_text()
		file.close()

	# 2. Kiểm tra các trường dữ liệu cốt lõi trong content
	check(content.contains("level_id = 1"), "Dung level_id = 1")
	check(content.contains("level_name = \"First Step\""), "Dung level_name = First Step")
	check(content.contains("grid_width = 7"), "Dung grid_width = 7")
	check(content.contains("grid_height = 5"), "Dung grid_height = 5")
	check(content.contains("player_start = Vector2i(1, 2)"), "Dung player_start = Vector2i(1, 2)")
	check(content.contains("exit_position = Vector2i(5, 2)"), "Dung exit_position = Vector2i(5, 2)")

	# 3. Dữ liệu logic Level 01 theo hợp đồng
	var grid_width: int = 7
	var grid_height: int = 5
	var player_start: Vector2i = Vector2i(1, 2)
	var exit_position: Vector2i = Vector2i(5, 2)

	# Danh sách ô tường chuẩn của Level 01 (viền bao quanh và chướng ngại vật tại 3, 2)
	var wall_cells: Array[Vector2i] = [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0),
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4),
		Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3),
		Vector2i(6, 1), Vector2i(6, 2), Vector2i(6, 3),
		Vector2i(3, 2) # Chướng ngại vật chặn đường thẳng
	]

	# Kiểm tra tính toàn vẹn: Start và Exit không nằm trên ô tường
	check(not wall_cells.has(player_start), "player_start khong bi tuong chan")
	check(not wall_cells.has(exit_position), "exit_position khong bi tuong chan")

	# Kiểm tra Start và Exit nằm trong phạm vi bản đồ
	var is_start_in_bounds: bool = (player_start.x >= 0 and player_start.x < grid_width and player_start.y >= 0 and player_start.y < grid_height)
	var is_exit_in_bounds: bool = (exit_position.x >= 0 and exit_position.x < grid_width and exit_position.y >= 0 and exit_position.y < grid_height)
	check(is_start_in_bounds, "player_start nam trong pham vi map")
	check(is_exit_in_bounds, "exit_position nam trong pham vi map")

	# 4. Khởi tạo ExitPortal và kiểm tra hiển thị / signal
	exit_portal_instance = preload("res://scenes/puzzle/exit_portal.tscn").instantiate()
	exit_portal_instance.grid_position = exit_position
	interactive_objects.add_child(exit_portal_instance)

	exit_portal_instance.player_entered.connect(func(pos: Vector2i):
		portal_signal_received = true
		portal_signal_pos = pos
	)

	var expected_portal_pos := Vector2(exit_position * 48) + Vector2(24, 24)
	check(exit_portal_instance.position == expected_portal_pos, "Toa do pixel ExitPortal can giua o luoi 48px dung chuan (264, 120)")
	check(exit_portal_instance.is_at(exit_position), "ExitPortal.is_at dung tai exit_position")
	check(not exit_portal_instance.is_at(player_start), "ExitPortal.is_at tra ve false tai player_start")

	# 5. Mô phỏng đường giải chuẩn không dùng Echo (Golden Solution: 6 bước di chuyển)
	# Lộ trình: (1, 2) -> (2, 2) -> (2, 1) -> (3, 1) -> (4, 1) -> (4, 2) -> (5, 2)
	var solution_actions: Array[String] = ["RIGHT", "UP", "RIGHT", "RIGHT", "DOWN", "RIGHT"]
	var dir_map: Dictionary = {
		"UP": Vector2i(0, -1),
		"DOWN": Vector2i(0, 1),
		"LEFT": Vector2i(-1, 0),
		"RIGHT": Vector2i(1, 0),
		"WAIT": Vector2i(0, 0)
	}

	var sim_pos: Vector2i = player_start
	var step_count: int = 0
	var hit_wall: bool = false

	for action in solution_actions:
		step_count += 1
		var move_dir: Vector2i = dir_map[action]
		var target_cell: Vector2i = sim_pos + move_dir
		if wall_cells.has(target_cell):
			hit_wall = true
			break
		sim_pos = target_cell

	check(not hit_wall, "Duong giai mau khong dam vao tuong")
	check(sim_pos == exit_position, "Duong giai mau dua Player den dung exit_position (5, 2)")
	check(step_count == 6 and step_count <= 12, "Duong giai hoan tat trong 6 tick (<= 12 tick)")

	# Kiểm tra trigger thắng khi Player bước vào ExitPortal
	portal_signal_received = false
	var reached: bool = exit_portal_instance.check_player_reached(sim_pos)
	check(reached, "ExitPortal xac nhan Player da buoc vao o thoat hiem")
	check(portal_signal_received, "ExitPortal da phat signal player_entered")
	check(portal_signal_pos == exit_position, "Signal mang dung toa do exit_position")

	print("========================================")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("========================================")

	if status_label != null:
		if failed_tests == 0:
			status_label.text = "LEVEL 01 TEST: ALL PASSED (%d/%d)" % [passed_tests, passed_tests]
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "LEVEL 01 TEST: FAILED (%d failed)" % failed_tests
			status_label.modulate = Color.RED

	if failed_tests == 0:
		print("LEVEL 01 TEST RESULT: ALL PASSED")
	else:
		print("LEVEL 01 TEST RESULT: FAILED")
