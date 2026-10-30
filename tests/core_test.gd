extends Node

var loop_manager: TimeLoopManager
var turn_manager: TurnManager
var failed_tests: int = 0
var passed_tests: int = 0

var last_tick: int = 0
var last_player_action: String = ""
var last_echo_actions := PackedStringArray()
var failure_signal_received: bool = false


func _ready() -> void:
	loop_manager = TimeLoopManager.new()
	turn_manager = TurnManager.new()

	add_child(loop_manager)
	add_child(turn_manager)

	turn_manager.setup(loop_manager)

	turn_manager.tick_actions_requested.connect(
		_on_tick_actions_requested
	)
	loop_manager.run_failed.connect(_on_run_failed)

	run_tests()


func check(condition: bool, description: String) -> void:
	if condition:
		passed_tests += 1
		print("PASS: ", description)
	else:
		failed_tests += 1
		push_error("FAIL: " + description)


func _on_tick_actions_requested(
	tick_number: int,
	player_action: String,
	echo_actions: PackedStringArray
) -> void:
	last_tick = tick_number
	last_player_action = player_action
	last_echo_actions = echo_actions.duplicate()


func _on_run_failed() -> void:
	failure_signal_received = true


func run_tests() -> void:
	print("===== ECHO LOOP CORE TEST =====")

	# TEST 1: Bắt đầu lượt chơi mới
	turn_manager.restart_run()

	check(loop_manager.loop_number == 1, "Bat dau o vong 1")
	check(loop_manager.get_echo_count() == 0, "Ban dau khong co Echo")

	# TEST 2: Ghi hành động
	turn_manager.submit_player_action("RIGHT")

	check(loop_manager.get_tick_count() == 1, "RIGHT ton 1 tick")
	check(last_player_action == "RIGHT", "TurnManager nhan RIGHT")
	check(last_tick == 1, "Tick dau tien bang 1")

	# TEST 3: Lệnh không hợp lệ
	turn_manager.submit_player_action("JUMP")

	check(loop_manager.get_tick_count() == 1, "JUMP khong tieu ton tick")

	# TEST 4: Kết thúc vòng 1 sớm
	turn_manager.end_current_loop()

	check(loop_manager.loop_number == 2, "Sang vong 2")
	check(loop_manager.get_echo_count() == 1, "Tao Echo 1")

	var echo1 := loop_manager.echo_histories[0]

	check(echo1.size() == 12, "Echo 1 co du 12 lenh")
	check(echo1[0] == "RIGHT", "Echo 1 ghi nho RIGHT")
	check(echo1[1] == "WAIT", "Tick thieu duoc dien WAIT")

	# TEST 5: Echo 1 phát lại ở vòng 2
	turn_manager.submit_player_action("LEFT")

	check(last_echo_actions.size() == 1, "Vong 2 co 1 Echo")
	check(last_echo_actions[0] == "RIGHT", "Echo 1 replay RIGHT")

	# TEST 6: Kết thúc vòng 2
	turn_manager.end_current_loop()

	check(loop_manager.loop_number == 3, "Sang vong 3")
	check(loop_manager.get_echo_count() == 2, "Co 2 Echo")

	# TEST 7: Hai Echo cùng phát hành động
	turn_manager.submit_player_action("WAIT")

	check(last_echo_actions.size() == 2, "Hai Echo cung hoat dong")
	check(last_echo_actions[0] == "RIGHT", "Echo 1 dung lich su")
	check(last_echo_actions[1] == "LEFT", "Echo 2 dung lich su")

	# TEST 8: Hết 12 tick ở vòng cuối
	for i in range(11):
		turn_manager.submit_player_action("WAIT")

	check(loop_manager.get_tick_count() == 12, "Vong 3 du 12 tick")
	check(loop_manager.is_finished, "Luot choi da ket thuc")
	check(failure_signal_received, "Da phat signal that bai")

	# TEST 9: Không nhận thêm lệnh sau thất bại
	turn_manager.submit_player_action("UP")

	check(loop_manager.get_tick_count() == 12, "Khong cho tick thu 13")

	# TEST 10: Restart đưa về trạng thái ban đầu
	turn_manager.restart_run()

	check(loop_manager.loop_number == 1, "Restart ve vong 1")
	check(loop_manager.get_echo_count() == 0, "Restart xoa Echo")
	check(loop_manager.get_tick_count() == 0, "Restart xoa tick")
	check(not loop_manager.is_finished, "Co the choi lai")

	print("==============================")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)

	if failed_tests == 0:
		print("CORE TEST RESULT: ALL PASSED")
	else:
		print("CORE TEST RESULT: FAILED")
