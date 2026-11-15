extends Node2D

## Test scene độc lập cho TV3 kiểm tra Door Snapshot và Logic Puzzle theo tick
## Tuân thủ đúng yêu cầu trong Issue #18 và mục 2.5 / 2.6 của AGENTS.md

var passed_tests: int = 0
var failed_tests: int = 0

@onready var switch_a: PressureSwitch = $PuzzleFixture/SwitchA
@onready var switch_b: PressureSwitch = $PuzzleFixture/SwitchB
@onready var door: Door = $PuzzleFixture/Door
@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
	_setup_fixture()
	run_tests()


func _setup_fixture() -> void:
	# Cấu hình tọa độ fixture
	switch_a.grid_position = Vector2i(1, 1)
	switch_b.grid_position = Vector2i(1, 3)
	door.grid_position = Vector2i(3, 2)
	door.linked_switches = [switch_a] # Mặc định liên kết SwitchA


func check(condition: bool, description: String) -> void:
	if condition:
		passed_tests += 1
		print("PASS: ", description)
	else:
		failed_tests += 1
		push_error("FAIL: " + description)


## Mô phỏng xử lý 1 tick chuẩn theo thứ tự 7 bước trong AGENTS.md mục 2.6
## actors: Dictionary dạng { "player": Vector2i(x, y), "echo": Vector2i(x, y) }
## moves: Dictionary dạng { "player": Vector2i(dx, dy), "echo": Vector2i(dx, dy) }
func simulate_tick(actors: Dictionary, moves: Dictionary) -> Dictionary:
	# BƯỚC 1: Chụp trạng thái cửa ở đầu tick (Snapshot)
	var door_snapshot_is_open: bool = door.is_open

	# BƯỚC 2 & 3: Kiểm tra di chuyển dựa trên snapshot cửa đầu tick
	# Ô cửa chỉ cho phép bước vào nếu snapshot đầu tick là MỞ
	var blocked_cells: Array[Vector2i] = []
	if not door_snapshot_is_open:
		blocked_cells.append(door.grid_position)

	var new_positions: Dictionary = {}
	var move_success: Dictionary = {}

	for actor_id in actors.keys():
		var current_pos: Vector2i = actors[actor_id]
		var dir: Vector2i = moves.get(actor_id, Vector2i.ZERO)
		var target_pos: Vector2i = current_pos + dir

		# Kiểm tra va chạm: nếu ô đích bị chặn và actor đang ở ô khác muốn bước vào
		if blocked_cells.has(target_pos) and current_pos != target_pos:
			new_positions[actor_id] = current_pos # Bị chặn, giữ nguyên vị trí
			move_success[actor_id] = false
		else:
			new_positions[actor_id] = target_pos # Di chuyển thành công
			move_success[actor_id] = true

	# BƯỚC 4 & 5: Cập nhật vị trí và tính lại trạng thái công tắc + cửa
	var actor_positions: Array[Vector2i] = []
	for pos in new_positions.values():
		actor_positions.append(pos)

	switch_a.update_state(actor_positions)
	switch_b.update_state(actor_positions)
	door.evaluate_state()

	return {
		"snapshot_is_open": door_snapshot_is_open,
		"positions": new_positions,
		"move_success": move_success,
		"door_end_open": door.is_open
	}


func run_tests() -> void:
	print("==================================================")
	print("===== ECHO LOOP PUZZLE TICK SNAPSHOT TEST (TV3) =====")
	print("==================================================")

	# --- TEST 1: Kiểm tra các phương thức thuần snapshot trên Door ---
	check(door.can_enter_for_tick(true) == true, "can_enter_for_tick(true) tra ve true")
	check(door.can_enter_for_tick(false) == false, "can_enter_for_tick(false) tra ve false")
	check(door.is_blocking_for_tick(false) == true, "is_blocking_for_tick(false) tra ve true")
	check(door.is_blocking_for_tick(true) == false, "is_blocking_for_tick(true) tra ve false")

	# --- TEST 2: Trạng thái ban đầu & Reset ---
	switch_a.reset_state()
	switch_b.reset_state()
	door.reset_state()
	check(not switch_a.is_active, "Switch A ban dau inactive")
	check(not door.is_open, "Door ban dau closed")

	# --- TEST 3 (QUY TẮC 2): Door CLOSED đầu tick -> Echo nhấn switch trong tick -> Player bị chặn ---
	# Tình huống: Door đang đóng. Echo tại (1, 2) bước lên Switch A tại (1, 1).
	# Player tại (2, 2) muốn bước vào Door tại (3, 2).
	door.linked_switches = [switch_a]
	door.reset_state()

	var actors_t1: Dictionary = {
		"player": Vector2i(2, 2),
		"echo": Vector2i(1, 2)
	}
	var moves_t1: Dictionary = {
		"player": Vector2i(1, 0), # Muốn sang (3, 2) - ô cửa
		"echo": Vector2i(0, -1)   # Bước lên (1, 1) - Switch A
	}

	var res_t1: Dictionary = simulate_tick(actors_t1, moves_t1)
	check(res_t1["snapshot_is_open"] == false, "Tick 1: Snapshot dau tick la CUA DONG")
	check(res_t1["move_success"]["player"] == false, "Tick 1: Player BI CHAN khong vao duoc cua vi dau tick cua dong")
	check(res_t1["positions"]["player"] == Vector2i(2, 2), "Tick 1: Player giu nguyen tai (2, 2)")
	check(res_t1["positions"]["echo"] == Vector2i(1, 1), "Tick 1: Echo da buoc len Switch A tai (1, 1)")
	check(switch_a.is_active == true, "Tick 1: Switch A da active vao cuoi tick")
	check(res_t1["door_end_open"] == true, "Tick 1: Cua MO vao cuoi tick sau khi tinh lai trang thai")

	# --- TEST 4: Tick tiếp theo (T+1) -> Door đã mở từ tick trước -> Player đi qua ---
	var actors_t2: Dictionary = res_t1["positions"]
	var moves_t2: Dictionary = {
		"player": Vector2i(1, 0), # Muốn sang (3, 2)
		"echo": Vector2i(0, 0)    # Đứng yên tại (1, 1) giữ switch
	}

	var res_t2: Dictionary = simulate_tick(actors_t2, moves_t2)
	check(res_t2["snapshot_is_open"] == true, "Tick 2: Snapshot dau tick la CUA MO")
	check(res_t2["move_success"]["player"] == true, "Tick 2: Player BUOC VAO CUA thanh cong")
	check(res_t2["positions"]["player"] == Vector2i(3, 2), "Tick 2: Player da dung tren o Cua (3, 2)")
	check(res_t2["door_end_open"] == true, "Tick 2: Cua van mo")

	# --- TEST 5 (QUY TẮC 1): Door OPEN đầu tick -> Echo rời switch trong tick -> Player khác vẫn được vào ô cửa ---
	# Tình huống: Echo đang ở (1, 1) giữ Switch A, Cửa đang MỞ.
	# Trong tick: Echo rời sang (1, 2). Player 2 tại (2, 2) bước vào ô Door (3, 2).
	var actors_t3: Dictionary = {
		"player2": Vector2i(2, 2),
		"echo": Vector2i(1, 1)
	}
	# Đảm bảo cửa đang mở từ đầu tick
	switch_a.update_state([Vector2i(1, 1)])
	door.evaluate_state()
	check(door.is_open == true, "Tien de Test 5: Cua dang mo")

	var moves_t3: Dictionary = {
		"player2": Vector2i(1, 0), # Bước vào ô cửa (3, 2)
		"echo": Vector2i(0, 1)     # Rời switch sang (1, 2)
	}

	var res_t3: Dictionary = simulate_tick(actors_t3, moves_t3)
	check(res_t3["snapshot_is_open"] == true, "Tick 3: Snapshot dau tick la CUA MO")
	check(res_t3["move_success"]["player2"] == true, "Tick 3: Player 2 DUOC PHEP VAO o cua nho snapshot dau tick mo")
	check(res_t3["positions"]["player2"] == Vector2i(3, 2), "Tick 3: Player 2 da dung tai o cua (3, 2)")
	check(switch_a.is_active == false, "Tick 3: Switch A da tat vi Echo da roi khoi")
	check(res_t3["door_end_open"] == false, "Tick 3: Cua DONG vao cuoi tick vi switch da tat")

	# --- TEST 6 (QUY TẮC 3): Actor đang trên ô Door khi cửa đóng -> Vẫn bước ra ngoài an toàn ---
	# Actor đang ở (3, 2), cửa đã đóng ở cuối tick 3
	var actors_t4: Dictionary = {
		"player": Vector2i(3, 2)
	}
	var moves_t4: Dictionary = {
		"player": Vector2i(1, 0) # Bước sang phải (4, 2)
	}

	var res_t4: Dictionary = simulate_tick(actors_t4, moves_t4)
	check(res_t4["snapshot_is_open"] == false, "Tick 4: Cua dang dong")
	check(res_t4["move_success"]["player"] == true, "Tick 4: Actor tren o cua van BUOC RA NGOAI an toan khong bi ket")
	check(res_t4["positions"]["player"] == Vector2i(4, 2), "Tick 4: Actor da o vi tri moi (4, 2)")

	# --- TEST 7: Logic AND với 2 công tắc liên kết ---
	door.linked_switches = [switch_a, switch_b]
	door.reset_state()
	switch_a.reset_state()
	switch_b.reset_state()

	# Chỉ có 1 actor đứng trên Switch A
	switch_a.update_state([Vector2i(1, 1)])
	switch_b.update_state([Vector2i(1, 1)]) # Không ai trên Switch B
	door.evaluate_state()
	check(switch_a.is_active == true, "Switch A active")
	check(switch_b.is_active == false, "Switch B inactive")
	check(door.is_open == false, "Door DONG khi moi co 1/2 cong tac active")

	# Cả 2 công tắc đều có actor
	switch_a.update_state([Vector2i(1, 1), Vector2i(1, 3)])
	switch_b.update_state([Vector2i(1, 1), Vector2i(1, 3)])
	door.evaluate_state()
	check(switch_a.is_active == true and switch_b.is_active == true, "Ca 2 switch deu active")
	check(door.is_open == true, "Door MO khi ca 2 switch deu active")

	# 1 actor rời đi
	switch_a.update_state([Vector2i(1, 3)]) # Rời switch A, còn switch B
	switch_b.update_state([Vector2i(1, 3)])
	door.evaluate_state()
	check(door.is_open == false, "Door DONG ngay khi 1 trong 2 switch bi ngat")

	# --- TEST 8: Chồng ô (Overlap) trên công tắc ---
	switch_a.update_state([Vector2i(1, 1), Vector2i(1, 1), Vector2i(1, 1)])
	check(switch_a.is_active == true, "Switch A van active khi 3 actors dung chong o")

	# --- TEST 9: Reset state ---
	switch_a.reset_state()
	switch_b.reset_state()
	door.reset_state()
	check(not switch_a.is_active and not switch_b.is_active, "Tat ca switch da reset ve false")
	check(not door.is_open, "Door da reset ve closed")

	print("==================================================")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("==================================================")

	if status_label != null:
		if failed_tests == 0:
			status_label.text = "PUZZLE TICK TEST: ALL PASSED (%d/%d)" % [passed_tests, passed_tests]
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "PUZZLE TICK TEST: FAILED (%d failed)" % failed_tests
			status_label.modulate = Color.RED

	if failed_tests == 0:
		print("PUZZLE TICK TEST RESULT: ALL PASSED")
	else:
		print("PUZZLE TICK TEST RESULT: FAILED")
