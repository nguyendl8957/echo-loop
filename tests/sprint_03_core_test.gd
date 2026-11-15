extends Node


const GAMEPLAY_SCENE: PackedScene = preload(
	"res://scenes/gameplay/gameplay.tscn"
)

var pass_count: int = 0
var fail_count: int = 0


func _ready() -> void:
	_test_early_end_and_echo_history()
	_test_auto_advance_and_failure()
	_test_replay_determinism()
	_test_echo_door_snapshot()
	_test_echo_only_exit()
	print(
		"SPRINT 03 CORE TEST: ",
		pass_count, " PASS / ",
		fail_count, " FAIL"
	)


func _check(condition: bool, description: String) -> void:
	if condition:
		pass_count += 1
		print("PASS: ", description)
	else:
		fail_count += 1
		push_error("FAIL: " + description)


func _test_early_end_and_echo_history() -> void:
	var loop := TimeLoopManager.new()
	var turn := TurnManager.new()
	add_child(loop)
	add_child(turn)
	turn.setup(loop)

	_check(loop.loop_number == 1, "Starts at Loop 1")
	_check(loop.get_echo_count() == 0, "Starts with 0 Echo")

	turn.submit_player_action("RIGHT")
	turn.submit_player_action("WAIT")
	turn.end_current_loop()

	_check(loop.loop_number == 2, "End Loop starts Loop 2")
	_check(loop.get_echo_count() == 1, "Creates first Echo")
	_check(loop.echo_histories[0].size() == 12, "History padded to 12")
	_check(loop.echo_histories[0][0] == "RIGHT", "Records RIGHT")
	_check(loop.echo_histories[0][1] == "WAIT", "Records WAIT")
	_check(loop.echo_histories[0][11] == "WAIT", "Pads with WAIT")

	turn.restart_run()
	_check(loop.loop_number == 1, "Restart returns to Loop 1")
	_check(loop.get_echo_count() == 0, "Restart clears Echoes")
	_check(loop.get_tick_count() == 0, "Restart clears ticks")

	turn.queue_free()
	loop.queue_free()


func _test_auto_advance_and_failure() -> void:
	var loop := TimeLoopManager.new()
	var turn := TurnManager.new()
	add_child(loop)
	add_child(turn)
	turn.setup(loop)

	for i in range(12):
		turn.submit_player_action("WAIT")

	_check(loop.loop_number == 2, "12 ticks auto-advance")
	_check(loop.get_echo_count() == 1, "Loop 2 has one Echo")
	_check(loop.get_tick_count() == 0, "Next loop starts at tick 0")

	for i in range(12):
		turn.submit_player_action("WAIT")

	_check(loop.loop_number == 3, "Advances to Loop 3")
	_check(loop.get_echo_count() == 2, "Loop 3 has two Echoes")

	for i in range(12):
		turn.submit_player_action("WAIT")

	_check(loop.is_finished, "Loop 3 ends the run")
	_check(turn.input_locked, "Failure locks input")
	_check(loop.get_echo_count() == 2, "Never creates third Echo")

	turn.queue_free()
	loop.queue_free()


func _test_replay_determinism() -> void:
	var expected := PackedStringArray([
		"RIGHT", "UP", "WAIT", "LEFT"
	])

	for run_index in range(10):
		var loop := TimeLoopManager.new()
		var turn := TurnManager.new()
		add_child(loop)
		add_child(turn)
		turn.setup(loop)

		for action in expected:
			turn.submit_player_action(action)

		turn.end_current_loop()

		var actual := PackedStringArray()
		for tick_index in range(12):
			var actions := loop.get_echo_actions(tick_index)
			actual.append(actions[0])

		var correct := true

		for i in range(expected.size()):
			if actual[i] != expected[i]:
				correct = false

		for i in range(expected.size(), 12):
			if actual[i] != "WAIT":
				correct = false

		_check(correct, "Deterministic history run %d" % (run_index + 1))

		turn.queue_free()
		loop.queue_free()


func _make_test_game(level: LevelData) -> Node2D:
	var game := GAMEPLAY_SCENE.instantiate() as Node2D
	game.set("level_override", level)
	add_child(game)
	return game


func _test_echo_door_snapshot() -> void:
	var level := LevelData.new()
	level.player_start = Vector2i(1, 2)
	level.exit_position = Vector2i(5, 2)
	level.switch_positions.append(Vector2i(2, 1))
	level.door_configs.append({
		"position": Vector2i(3, 2),
		"switch_indices": [0]
	})

	var game := _make_test_game(level)
	var turn: TurnManager = game.get("turn_manager")
	var player: PlayerController = game.get("player")
	var loop: TimeLoopManager = game.get("loop_manager")
	var sw: PressureSwitch = game.get("switches")[0]
	var door: Door = game.get("doors")[0]

	# Loop 1: ghi lich su UP, RIGHT, DOWN.
	turn.submit_player_action("UP")
	turn.submit_player_action("RIGHT")
	turn.submit_player_action("DOWN")
	turn.end_current_loop()

	_check(loop.get_echo_count() == 1,
		"Fixture: created one Echo")
	_check(not door.is_open,
		"Fixture: door reset closed")

	# Loop 2, tick 1:
	# Player RIGHT; Echo UP.
	turn.submit_player_action("RIGHT")
	_check(player.grid_position == Vector2i(2, 2),
		"Fixture: Player reaches cell before door")

	# Tick 2: Player thu vao cua dang dong.
	# Echo RIGHT len switch; cua chi mo SAU di chuyen.
	turn.submit_player_action("RIGHT")
	_check(player.grid_position == Vector2i(2, 2),
		"Snapshot: newly opened door blocks same tick")
	_check(sw.is_active,
		"Fixture: Echo activates switch")
	_check(door.is_open,
		"Fixture: switch opens door after movement")

	# Tick 3: Player buoc vao cua dang mo.
	# Echo DOWN roi switch; cua dong sau khi di chuyen.
	turn.submit_player_action("RIGHT")
	_check(player.grid_position == Vector2i(3, 2),
		"Snapshot: Player enters open door")
	_check(not door.is_open,
		"Fixture: Echo leaving switch closes door")

	# Tick 4: Actor dang trong o cua dong van roi duoc.
	turn.submit_player_action("LEFT")
	_check(player.grid_position == Vector2i(2, 2),
		"Fixture: Player can leave closed door")

	game.free()


func _test_echo_only_exit() -> void:
	var level := LevelData.new()
	level.player_start = Vector2i(1, 2)
	level.exit_position = Vector2i(3, 2)
	level.switch_positions.append(Vector2i(1, 2))
	level.door_configs.append({
		"position": Vector2i(3, 2),
		"switch_indices": [0]
	})

	var game := _make_test_game(level)
	var turn: TurnManager = game.get("turn_manager")
	var player: PlayerController = game.get("player")
	var door: Door = game.get("doors")[0]

	# Loop 1: Player roi switch; cua van dong.
	turn.submit_player_action("RIGHT")
	turn.submit_player_action("RIGHT")
	_check(player.grid_position == Vector2i(2, 2),
		"Echo exit fixture: closed door blocks Player")

	turn.end_current_loop()

	# Loop 2: Player WAIT tai switch.
	# Echo replay RIGHT, RIGHT.
	turn.submit_player_action("WAIT")
	_check(door.is_open,
		"Echo exit fixture: Player opens door")

	turn.submit_player_action("WAIT")
	var echo: EchoController = game.get("echoes")[0]

	_check(echo.grid_position == level.exit_position,
		"Echo reaches Exit")
	_check(player.grid_position != level.exit_position,
		"Player remains outside Exit")
	_check(not turn.input_locked,
		"Echo alone cannot trigger victory")

	game.free()
