extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	var loop := TimeLoopManager.new()
	var turn := TurnManager.new()

	add_child(loop)
	add_child(turn)

	turn.setup(loop)
	turn.auto_advance_loops = false
	turn.restart_run()

	check(loop.loop_number == 1, "Bat dau o vong 1")
	check(loop.get_echo_count() == 0, "Ban dau khong co Echo")

	# END LOOP khong duoc tao Echo trong Sprint 02.
	turn.end_current_loop()
	check(loop.loop_number == 1, "END LOOP khong chuyen vong")

	# WAIT van tieu ton tick.
	turn.submit_player_action("WAIT")
	check(loop.get_tick_count() == 1, "WAIT ton 1 tick")

	# Hoan thanh du 12 tick.
	for i in range(11):
		turn.submit_player_action("WAIT")

	check(loop.get_tick_count() == 12, "Du 12 tick")
	check(turn.input_locked, "Input bi khoa sau tick 12")
	check(loop.get_echo_count() == 0, "Khong tao Echo")
	check(loop.loop_number == 1, "Khong tu chuyen vong 2")

	# Khong chap nhan tick thu 13.
	turn.submit_player_action("RIGHT")
	check(loop.get_tick_count() == 12, "Khong co tick 13")

	# Restart.
	turn.restart_run()
	check(loop.get_tick_count() == 0, "Restart xoa tick")
	check(not turn.input_locked, "Restart mo khoa input")
	check(loop.get_echo_count() == 0, "Restart khong co Echo")

	print("============================")
	print("SPRINT 02 TURN TEST")
	print("PASSED: ", passed)
	print("FAILED: ", failed)


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)
