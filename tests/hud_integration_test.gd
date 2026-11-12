extends Node

@onready var hud = $HUD

var received_actions: Array[String] = []
var end_loop_count := 0
var restart_count := 0


func _ready() -> void:
	hud.action_requested.connect(_on_action)
	hud.end_loop_requested.connect(_on_end_loop)
	hud.restart_requested.connect(_on_restart)

	# TEST 1: Kiem tra thong tin HUD
	hud.update_hud(1, 5, 12, 0)

	assert(hud.level_label.text == "LEVEL 01")
	assert(hud.tick_label.text == "TICK: 5/12")
	assert(hud.echo_label.text == "ECHO: 0")

	print("TEST 1 - HUD DISPLAY: PASS")

	# TEST 2: Kiem tra tung nut bam
	_test_action_button(hud.up_button, "UP")
	_test_action_button(hud.down_button, "DOWN")
	_test_action_button(hud.left_button, "LEFT")
	_test_action_button(hud.right_button, "RIGHT")
	_test_action_button(hud.wait_button, "WAIT")

	print("TEST 2 - ACTION BUTTONS: PASS")

	# TEST 3: Kiem tra ENDLOOP
	hud.end_loop_button.pressed.emit()
	assert(end_loop_count == 1)
	print("TEST 3 - ENDLOOP: PASS")

	# TEST 4: Kiem tra RESTART
	hud.restart_button.pressed.emit()
	assert(restart_count == 1)
	print("TEST 4 - RESTART: PASS")

	print("HUD INTEGRATION TEST: PASS")


func _test_action_button(button: Button, expected: String) -> void:
	var previous_count := received_actions.size()

	button.pressed.emit()

	assert(received_actions.size() == previous_count + 1)
	assert(received_actions[-1] == expected)


func _on_action(action: String) -> void:
	received_actions.append(action)


func _on_end_loop() -> void:
	end_loop_count += 1


func _on_restart() -> void:
	restart_count += 1
