extends Node2D

## Test scene độc lập cho TV3 kiểm tra PressureSwitch và Door bằng F6
## Chạy độc lập không phụ thuộc vào GameManager, TurnManager hay Player

var passed_tests: int = 0
var failed_tests: int = 0

var switch1: PressureSwitch
var switch2: PressureSwitch
var door_single: Door
var door_double: Door

var switch_signal_received: bool = false
var door_signal_received: bool = false

@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
	_setup_test_nodes()
	run_all_tests()


func _setup_test_nodes() -> void:
	# Khởi tạo công tắc 1 tại ô (1, 1)
	switch1 = preload("res://scenes/puzzle/pressure_switch.tscn").instantiate()
	switch1.grid_position = Vector2i(1, 1)
	add_child(switch1)

	# Khởi tạo công tắc 2 tại ô (1, 2)
	switch2 = preload("res://scenes/puzzle/pressure_switch.tscn").instantiate()
	switch2.grid_position = Vector2i(1, 2)
	add_child(switch2)

	# Khởi tạo cửa 1 liên kết với 1 công tắc (switch1) tại ô (2, 1)
	door_single = preload("res://scenes/puzzle/door.tscn").instantiate()
	door_single.grid_position = Vector2i(2, 1)
	door_single.linked_switches = [switch1]
	add_child(door_single)

	# Khởi tạo cửa 2 liên kết với 2 công tắc (switch1 và switch2) tại ô (2, 2)
	door_double = preload("res://scenes/puzzle/door.tscn").instantiate()
	door_double.grid_position = Vector2i(2, 2)
	door_double.linked_switches = [switch1, switch2]
	add_child(door_double)

	# Kết nối signal để kiểm tra
	switch1.state_changed.connect(func(active: bool): switch_signal_received = true)
	door_single.state_changed.connect(func(open: bool): door_signal_received = true)


func check(condition: bool, description: String) -> void:
	if condition:
		passed_tests += 1
		print("PASS: ", description)
	else:
		failed_tests += 1
		push_error("FAIL: " + description)


func run_all_tests() -> void:
	print("========================================")
	print("===== ECHO LOOP PUZZLE TEST (TV3) =====")
	print("========================================")

	# TEST 1: Trạng thái ban đầu
	check(not switch1.is_active, "Switch 1 ban dau chua kich hoat")
	check(not switch2.is_active, "Switch 2 ban dau chua kich hoat")
	check(not door_single.is_open, "Door single ban dau dong")
	check(not door_double.is_open, "Door double ban dau dong")
	check(door_single.is_blocking(), "Door single ban dau chan duong")
	check(not door_single.can_enter(), "Khong the buoc vao Door single ban dau")

	# TEST 2: Chuyển đổi tọa độ luới sang tọa độ thế giới (Vector2 pixel)
	# CELL_SIZE = 48 -> pixel = grid * 48 + 24
	var expected_switch1_pos := Vector2(1 * 48 + 24, 1 * 48 + 24)
	var expected_door_pos := Vector2(2 * 48 + 24, 1 * 48 + 24)
	check(switch1.position == expected_switch1_pos, "Toa do pixel Switch 1 dung chuan AGENTS.md (72, 72)")
	check(door_single.position == expected_door_pos, "Toa do pixel Door single dung chuan (120, 72)")

	# TEST 3: Đứng lên công tắc 1 (Player tại ô 1, 1)
	switch_signal_received = false
	door_signal_received = false

	var actors_on_switch1: Array[Vector2i] = [Vector2i(1, 1)]
	switch1.update_state(actors_on_switch1)
	switch2.update_state(actors_on_switch1)
	door_single.evaluate_state()
	door_double.evaluate_state()

	check(switch1.is_active, "Switch 1 kich hoat khi co nhan vat dung len")
	check(not switch2.is_active, "Switch 2 van chua kich hoat")
	check(switch_signal_received, "Switch 1 phat signal state_changed dung luc")
	check(door_single.is_open, "Door single mo khi Switch 1 duoc kich hoat")
	check(door_single.can_enter(), "Co the buoc vao Door single khi da mo")
	check(not door_single.is_blocking(), "Door single khong con chan duong")
	check(door_signal_received, "Door single phat signal state_changed khi mo")
	check(not door_double.is_open, "Door double van dong vi moi co 1/2 cong tac active")

	# TEST 4: Đứng lên cả 2 công tắc (Player tai 1, 1 va Echo tai 1, 2)
	var actors_on_both: Array[Vector2i] = [Vector2i(1, 1), Vector2i(1, 2)]
	switch1.update_state(actors_on_both)
	switch2.update_state(actors_on_both)
	door_single.evaluate_state()
	door_double.evaluate_state()

	check(switch1.is_active, "Switch 1 van active")
	check(switch2.is_active, "Switch 2 active khi co Echo dung len")
	check(door_double.is_open, "Door double MO khi ca 2 cong tac lien ket deu active")
	check(door_double.can_enter(), "Co the buoc vao Door double khi da mo")

	# TEST 5: Rời khỏi công tắc 1 (Player buoc sang 5, 5; Echo van o 1, 2)
	var actors_leave_switch1: Array[Vector2i] = [Vector2i(5, 5), Vector2i(1, 2)]
	switch1.update_state(actors_leave_switch1)
	switch2.update_state(actors_leave_switch1)
	door_single.evaluate_state()
	door_double.evaluate_state()

	check(not switch1.is_active, "Switch 1 ngat kich hoat khi nhan vat roi khoi")
	check(switch2.is_active, "Switch 2 van active vi con Echo dung tren")
	check(not door_single.is_open, "Door single DONG lai khi Switch 1 ngat")
	check(not door_double.is_open, "Door double DONG lai ngay khi 1 trong 2 cong tac bi ngat")

	# TEST 6: Nhiều nhân vật cùng đứng trên 1 công tắc (Chồng ô - Overlap)
	var multiple_actors_on_switch1: Array[Vector2i] = [Vector2i(1, 1), Vector2i(1, 1), Vector2i(1, 1)]
	switch1.update_state(multiple_actors_on_switch1)
	check(switch1.is_active, "Switch 1 van active khi co nhieu nhan vat dung chong o")

	# TEST 7: Reset trạng thái (World Reset / New Loop)
	switch1.reset_state()
	switch2.reset_state()
	door_single.reset_state()
	door_double.reset_state()

	check(not switch1.is_active, "Switch 1 reset ve false")
	check(not switch2.is_active, "Switch 2 reset ve false")
	check(not door_single.is_open, "Door single reset ve dong")
	check(not door_double.is_open, "Door double reset ve dong")

	# TEST 8: Không ai đứng trên ô nào
	var no_actors: Array[Vector2i] = [Vector2i(0, 0), Vector2i(9, 9)]
	switch1.update_state(no_actors)
	door_single.evaluate_state()
	check(not switch1.is_active, "Khong ai dung tren o Switch thi switch tat")
	check(not door_single.is_open, "Khong co switch active thi door dong")

	print("========================================")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("========================================")

	if status_label != null:
		if failed_tests == 0:
			status_label.text = "PUZZLE TEST: ALL PASSED (%d/%d)" % [passed_tests, passed_tests]
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "PUZZLE TEST: FAILED (%d failed)" % failed_tests
			status_label.modulate = Color.RED

	if failed_tests == 0:
		print("PUZZLE TEST RESULT: ALL PASSED")
	else:
		print("PUZZLE TEST RESULT: FAILED")
