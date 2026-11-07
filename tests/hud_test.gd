extends Node

var actions: Array[String] = []
var end_count: int = 0
var restart_count: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	var hud: Node = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)

	hud.connect("action_requested", _on_action)
	hud.connect("end_loop_requested", _on_end_loop)
	hud.connect("restart_requested", _on_restart)

	_test_action(hud, "UpButton", "UP")
	_test_action(hud, "DownButton", "DOWN")
	_test_action(hud, "LeftButton", "LEFT")
	_test_action(hud, "RightButton", "RIGHT")
	_test_action(hud, "WaitButton", "WAIT")

	_press(hud, "EndLoopButton")
	check(end_count == 1, "END LOOP signal")

	_press(hud, "RestartButton")
	check(restart_count == 1, "RESTART signal")

	hud.call("update_hud", 2, 5, 12, 1)

	var tick_label: Label = hud.get_node(
        "HUDRoot/TopBar/TickLabel"
	)

	check(tick_label.text == "TICK: 5/12", "HUD tick update")

	print("HUD TEST RESULT: %d PASSED / %d FAILED" % [
		passed, failed
	])


func _test_action(
	hud: Node,
	button_name: String,
	expected: String
) -> void:
	var previous: int = actions.size()
	_press(hud, button_name)

	check(
		actions.size() == previous + 1
		and actions[previous] == expected,
		button_name + " -> " + expected
	)


func _press(hud: Node, button_name: String) -> void:
	var button: Button = hud.get_node(
		"HUDRoot/ControlsArea/" + button_name
	) as Button

	button.pressed.emit()


func _on_action(action: String) -> void:
	actions.append(action)


func _on_end_loop() -> void:
	end_count += 1


func _on_restart() -> void:
	restart_count += 1


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)
