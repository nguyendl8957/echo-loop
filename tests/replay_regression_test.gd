extends Node2D
const TIME_LOOP_SCRIPT: Script = preload("res://scripts/timeloop/time_loop_manager.gd")
const TURN_MANAGER_SCRIPT: Script = preload("res://scripts/core/turn_manager.gd")
const PLAYER_SCRIPT: Script = preload("res://scripts/player/player_controller.gd")
const SWITCH_SCRIPT: Script = preload("res://scripts/puzzle/pressure_switch.gd")
const DOOR_SCRIPT: Script = preload("res://scripts/puzzle/door.gd")
const EXIT_SCRIPT: Script = preload("res://scripts/puzzle/exit_portal.gd")

const ECHO_SCENE_PATH: String = "res://scenes/player/echo.tscn"

const MAX_REPLAY_RUNS: int = 10
const FIXTURE_START: Vector2i = Vector2i(2, 2)
const FIXTURE_SWITCH: Vector2i = Vector2i(1, 2)
const FIXTURE_DOOR: Vector2i = Vector2i(3, 2)
const FIXTURE_EXIT: Vector2i = Vector2i(4, 2)

var passed_tests: int = 0
var failed_tests: int = 0
var not_run_tests: int = 0

var _manager_nodes: Array[Node] = []
var _world_nodes: Array[Node] = []
var _echo_actors: Array[Node] = []
var _trace_lines: PackedStringArray = PackedStringArray()

var _time_loop: Node
var _turn_manager: Node
var _player: Node
var _switch: Node
var _door: Node
var _exit: Node

var _uses_real_echo_controller: bool = false
var _first_loop_padded: bool = false
var _blocked_move_consumed_tick: bool = false
var _door_snapshot_order_ok: bool = false
var _player_won: bool = false
var _last_trace: String = ""
var _aux_run_failed: bool = false

@onready var status_label: Label = get_node_or_null("CanvasLayer/StatusLabel") as Label


func _ready() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	print("====================================================")
	print("ECHO LOOP — S03 TV5 REPLAY REGRESSION (F6 FIXTURE)")
	print("====================================================")
	print("Fixture: start=(2,2), switch=(1,2), door=(3,2), exit=(4,2)")

	_test_tick_limit()

	var canonical_trace: String = ""
	var first_run_flags: Dictionary = {}
	for run_index in range(MAX_REPLAY_RUNS):
		var trace: String = _run_success_fixture()
		if run_index == 0:
			canonical_trace = trace
			first_run_flags = {
				"padding": _first_loop_padded,
				"blocked_tick": _blocked_move_consumed_tick,
				"door_snapshot": _door_snapshot_order_ok,
				"player_won": _player_won
			}
		else:
			_check(
				trace == canonical_trace,
				"Replay run %02d/%02d có trace giống lần đầu" % [run_index + 1, MAX_REPLAY_RUNS]
			)
		print("REPLAY_RUN=%02d TRACE_HASH=%d" % [run_index + 1, hash(trace)])

	_check(bool(first_run_flags.get("padding", false)), "End Loop sớm đệm WAIT đến đủ 12 action")
	_check(bool(first_run_flags.get("blocked_tick", false)), "Di chuyển bị chặn vẫn tiêu tốn 1 tick")
	_check(bool(first_run_flags.get("door_snapshot", false)), "Door chỉ mở sau khi actor hoàn tất di chuyển trong tick")
	_check(bool(first_run_flags.get("player_won", false)), "Player hiện tại đến Exit và thắng trong fixture")
	_check(canonical_trace != "", "Fixture tạo được trace chứa loop/tick/actor/door/win")

	_test_echo_cannot_win()
	_test_restart_state()
	_test_echo_limit()

	if ResourceLoader.exists(ECHO_SCENE_PATH):
		_check(true, "TV2 Echo scene đã có trên nhánh đang chạy")
	else:
		_not_run("EchoController thật: scenes/player/echo.tscn chưa có trên main của source hiện tại")

	print("----------------------------------------------------")
	print("PASSED: %d | FAILED: %d | NOT RUN: %d" % [passed_tests, failed_tests, not_run_tests])
	if failed_tests == 0 and not_run_tests == 0:
		print("RESULT: ALL TESTS PASSED — F6 FIXTURE ONLY")
	elif failed_tests == 0:
		print("RESULT: PARTIAL — F6 FIXTURE PASSED; INTEGRATION ITEMS NOT RUN")
	else:
		print("RESULT: FAILED — REVIEW FAIL LINES")
	print("NOTE: F5 integrated Gameplay/Level 01 is not tested by this fixture.")
	print("====================================================")

	if status_label != null:
		status_label.text = "S03 TV5 | PASS %d | FAIL %d | NOT RUN %d" % [
			passed_tests, failed_tests, not_run_tests
		]
		status_label.modulate = Color.GREEN if failed_tests == 0 and not_run_tests == 0 else Color.ORANGE


func _test_tick_limit() -> void:
	var manager: Node = TIME_LOOP_SCRIPT.new() as Node
	add_child(manager)
	var accepted_all: bool = true
	for index in range(12):
		if not bool(manager.call("record_action", "WAIT")):
			accepted_all = false
	var action_count: int = manager.get("current_actions").size()
	var thirteenth_rejected: bool = not bool(manager.call("record_action", "WAIT"))
	_check(accepted_all and action_count == 12 and thirteenth_rejected, "Một vòng tối đa 12 tick; action thứ 13 bị từ chối")
	manager.free()


func _run_success_fixture() -> String:
	_clear_trial()
	_trace_lines.clear()
	_first_loop_padded = false
	_blocked_move_consumed_tick = false
	_door_snapshot_order_ok = false
	_player_won = false

	_time_loop = _add_manager(TIME_LOOP_SCRIPT, "FixtureTimeLoopManager")
	_turn_manager = _add_manager(TURN_MANAGER_SCRIPT, "FixtureTurnManager")
	_turn_manager.call("setup", _time_loop)
	_turn_manager.set("auto_advance_loops", true)
	_turn_manager.connect("tick_actions_requested", Callable(self, "_on_tick_actions_requested"))

	# Loop 1: Player enters the Switch cell, then ends early.
	_build_world_for_current_histories()
	_turn_manager.call("submit_player_action", "LEFT")
	_turn_manager.call("end_current_loop")

	var histories: Array = _time_loop.get("echo_histories")
	if histories.size() == 1:
		var first_history: PackedStringArray = histories[0]
		_first_loop_padded = first_history.size() == 12 and first_history[0] == "LEFT"
		for index in range(1, first_history.size()):
			if first_history[index] != "WAIT":
				_first_loop_padded = false

	# New loop resets the test world; action history is retained by TimeLoopManager.
	_clear_world()
	_build_world_for_current_histories()

	# Loop 2 tick 1: Player tries the closed Door while Echo 1 reaches Switch.
	_turn_manager.call("submit_player_action", "RIGHT")
	_blocked_move_consumed_tick = (
		int(_time_loop.call("get_tick_count")) == 1
		and Vector2i(_player.get("grid_position")) == FIXTURE_START
	)
	_door_snapshot_order_ok = (
		_trace_lines.size() >= 2
		and _trace_lines[_trace_lines.size() - 1].contains("door_start=false")
		and _trace_lines[_trace_lines.size() - 1].contains("door_end=true")
	)

	# Loop 2 tick 2: Player can enter the Door because it was open at tick start.
	_turn_manager.call("submit_player_action", "RIGHT")
	# Loop 2 tick 3: Player reaches Exit; Echo standing elsewhere cannot win.
	_turn_manager.call("submit_player_action", "RIGHT")
	_player_won = (
		bool(_exit.call("check_player_reached", Vector2i(_player.get("grid_position"))))
		and Vector2i(_player.get("grid_position")) == FIXTURE_EXIT
	)

	return "\n".join(_trace_lines)


func _on_tick_actions_requested(
	tick_number: int,
	player_action: String,
	echo_actions: PackedStringArray
) -> void:
	# Door state is snapshotted before any actor moves in this tick.
	var door_open_at_start: bool = bool(_door.get("is_open"))
	var blocked_cells: Array[Vector2i] = []
	if not door_open_at_start:
		blocked_cells.append(FIXTURE_DOOR)

	_player.call("apply_action", player_action, blocked_cells)

	for echo_index in range(_echo_actors.size()):
		var echo_actor: Node = _echo_actors[echo_index]
		if _uses_real_echo_controller:
			echo_actor.call("apply_echo_action", tick_number - 1, blocked_cells)
		else:
			var action: String = "WAIT"
			if echo_index < echo_actions.size():
				action = echo_actions[echo_index]
			echo_actor.call("apply_action", action, blocked_cells)

	var actor_positions: Array[Vector2i] = []
	actor_positions.append(Vector2i(_player.get("grid_position")))
	var echo_position_text := PackedStringArray()
	for echo_actor in _echo_actors:
		var echo_cell: Vector2i = Vector2i(echo_actor.get("grid_position"))
		actor_positions.append(echo_cell)
		echo_position_text.append(str(echo_cell))

	_switch.call("update_state", actor_positions)
	_door.call("evaluate_state")
	var player_reached_exit: bool = bool(
		_exit.call("check_player_reached", Vector2i(_player.get("grid_position")))
	)
	if player_reached_exit:
		_player_won = true

	var loop_number: int = int(_time_loop.get("loop_number"))
	var player_cell: Vector2i = Vector2i(_player.get("grid_position"))
	_trace_lines.append(
		"loop=%d|tick=%d|player=%s|echoes=%s|door_start=%s|door_end=%s|win=%s" % [
			loop_number,
			tick_number,
			str(player_cell),
			"[" + ",".join(echo_position_text) + "]",
			str(door_open_at_start).to_lower(),
			str(bool(_door.get("is_open"))).to_lower(),
			str(player_reached_exit).to_lower()
		]
	)


func _build_world_for_current_histories() -> void:
	_player = _spawn_script_node(PLAYER_SCRIPT, "FixturePlayer", false)
	_player.call("reset_position", FIXTURE_START)

	_switch = _spawn_script_node(SWITCH_SCRIPT, "FixtureSwitch", true)
	_switch.set("grid_position", FIXTURE_SWITCH)

	var door_instance: Node = DOOR_SCRIPT.new() as Node
	door_instance.name = "FixtureDoor"
	door_instance.add_child(Sprite2D.new())
	door_instance.set("grid_position", FIXTURE_DOOR)
	var switch_links: Array[PressureSwitch] = []
	switch_links.append(_switch as PressureSwitch)
	door_instance.set("linked_switches", switch_links)
	_door = _add_world_node(door_instance)

	_exit = _spawn_script_node(EXIT_SCRIPT, "FixtureExit", true)
	_exit.set("grid_position", FIXTURE_EXIT)

	_echo_actors.clear()
	var histories: Array = _time_loop.get("echo_histories")
	_uses_real_echo_controller = ResourceLoader.exists(ECHO_SCENE_PATH)
	var echo_scene: PackedScene = null
	if _uses_real_echo_controller:
		echo_scene = load(ECHO_SCENE_PATH) as PackedScene
		if echo_scene == null:
			_uses_real_echo_controller = false

	for echo_index in range(histories.size()):
		var history: PackedStringArray = histories[echo_index]
		var echo_actor: Node
		if _uses_real_echo_controller and echo_scene != null:
			echo_actor = echo_scene.instantiate()
			echo_actor.name = "FixtureEcho%d" % [echo_index + 1]
			_add_world_node(echo_actor)
			echo_actor.call(
				"setup_echo",
				FIXTURE_START,
				history,
				Color(0.25, 0.75, 1.0, 0.7) if echo_index == 0 else Color(0.65, 0.4, 1.0, 0.5)
			)
		else:
			echo_actor = _spawn_script_node(PLAYER_SCRIPT, "FixtureEcho%d" % [echo_index + 1], false)
			echo_actor.call("reset_position", FIXTURE_START)
		_echo_actors.append(echo_actor)


func _test_echo_cannot_win() -> void:
	if _echo_actors.is_empty():
		_not_run("Echo-only Exit test: fixture did not create an Echo actor")
		return

	_player.call("reset_position", FIXTURE_START)
	_echo_actors[0].call("reset_position", FIXTURE_EXIT)
	var echo_only_reached: bool = bool(
		_exit.call("check_player_reached", Vector2i(_player.get("grid_position")))
	)
	_check(not echo_only_reached, "Echo đứng tại Exit không làm Player hiện tại thắng")


func _test_restart_state() -> void:
	_turn_manager.call("restart_run")
	_clear_world()
	_build_world_for_current_histories()
	var histories: Array = _time_loop.get("echo_histories")
	_check(
		histories.is_empty()
		and int(_time_loop.call("get_tick_count")) == 0
		and int(_time_loop.get("loop_number")) == 1,
		"Restart manager xóa Echo history và reset loop/tick"
	)
	_check(
		_echo_actors.is_empty()
		and not bool(_switch.get("is_active"))
		and not bool(_door.get("is_open"))
		and Vector2i(_player.get("grid_position")) == FIXTURE_START,
		"Fixture world sau restart có Player ở Start, không Echo, Switch inactive, Door closed"
	)


func _test_echo_limit() -> void:
	_aux_run_failed = false
	var manager: Node = TIME_LOOP_SCRIPT.new() as Node
	add_child(manager)
	manager.connect("run_failed", Callable(self, "_on_aux_run_failed"))

	var loop_results: Array[bool] = []
	for loop_index in range(3):
		manager.call("record_action", "WAIT")
		loop_results.append(bool(manager.call("end_loop")))

	_check(
		loop_results.size() == 3
		and loop_results[0]
		and loop_results[1]
		and not loop_results[2]
		and int(manager.call("get_echo_count")) == 2
		and bool(manager.get("is_finished"))
		and _aux_run_failed,
		"Tối đa 2 Echo; kết thúc vòng 3 phát run_failed và không tạo Echo thứ 3"
	)
	manager.free()


func _on_aux_run_failed() -> void:
	_aux_run_failed = true


func _spawn_script_node(script: Script, node_name: String, add_sprite: bool) -> Node:
	var instance: Node = script.new() as Node
	instance.name = node_name
	if add_sprite:
		instance.add_child(Sprite2D.new())
	return _add_world_node(instance)


func _add_world_node(instance: Node) -> Node:
	add_child(instance)
	_world_nodes.append(instance)
	return instance


func _add_manager(script: Script, node_name: String) -> Node:
	var instance: Node = script.new() as Node
	instance.name = node_name
	add_child(instance)
	_manager_nodes.append(instance)
	return instance


func _clear_world() -> void:
	for node in _world_nodes:
		if is_instance_valid(node):
			node.free()
	_world_nodes.clear()
	_echo_actors.clear()


func _clear_trial() -> void:
	_clear_world()
	for node in _manager_nodes:
		if is_instance_valid(node):
			node.free()
	_manager_nodes.clear()
	_time_loop = null
	_turn_manager = null


func _check(condition: bool, description: String) -> void:
	if condition:
		passed_tests += 1
		print("PASS: " + description)
	else:
		failed_tests += 1
		push_error("FAIL: " + description)


func _not_run(description: String) -> void:
	not_run_tests += 1
	print("NOT RUN: " + description)
