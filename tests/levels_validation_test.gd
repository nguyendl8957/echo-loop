extends Node2D

const GAMEPLAY := preload("res://scenes/gameplay/gameplay.tscn")
const SOLUTIONS := [
	["UUL", "RRRRRR"],
	["LLLLD", "RRRRDD", "DDWWWWDDD"],
	["UUL", "UURRRRR", "DRRRRWRRRR"],
	["LLWWWWWU", "UUUUULL", "RRWWWWWRRRR"],
	["UULWWWD", "UURRRR", "RRWWWWRRRRRR"]
]
const DIRECTIONS := {
	"U": Vector2i.UP, "D": Vector2i.DOWN,
	"L": Vector2i.LEFT, "R": Vector2i.RIGHT, "W": Vector2i.ZERO
}
const BUTTONS := {
	"U": "up_button", "D": "down_button", "L": "left_button",
	"R": "right_button", "W": "wait_button"
}

var failures := 0
var checks := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var original_level := GameManager.current_level
	var original_completed: bool = GameManager.get("_level_completed_this_run")
	var progress_before := GameManager.get_unlocked_level()

	for level_id in range(1, 6):
		var level := LevelManager.load_level(level_id)
		_check(level != null, "Level %02d loads" % level_id)
		if level == null:
			continue
		var solution: Array = SOLUTIONS[level_id - 1]
		for echo_count in range(solution.size() - 1):
			_check_no_shortcut(level, echo_count)
		_check_door_routes(level)
		await _play_solution(level, solution)

	GameManager.current_level = original_level
	GameManager.set("_level_completed_this_run", original_completed)
	_check(GameManager.get_unlocked_level() == progress_before, "Fixture preserves save data")
	var summary := "LEVELS VALIDATION: %d PASS / %d FAIL" % [checks - failures, failures]
	print(summary)
	$CanvasLayer/ResultsLabel.text = summary
	$CanvasLayer/StatusLabel.text = "LEVELS 01–05  /  ECHO REQUIREMENTS"
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if failures == 0 else 1)


func _check_no_shortcut(level: LevelData, echo_count: int) -> void:
	var start := _cell_id(level, level.player_start)
	var exit := _cell_id(level, level.exit_position)
	var states := {Vector2i(start, start if echo_count == 1 else -1): true}
	var reached_exit := false
	var walls := _wall_lookup(level)

	# Giving the Echo free choices at every tick includes every possible replay.
	# With up to two actors, their positions determine the complete door snapshot.
	for tick in range(TimeLoopManager.MAX_TICKS):
		var next_states := {}
		for pair: Vector2i in states:
			var positions: Array[int] = [pair.x, pair.y]
			var open_doors := _open_doors(level, positions if tick > 0 else ([] as Array[int]))
			for action: String in DIRECTIONS:
				var player_next := _move(level, pair.x, action, walls, open_doors)
				reached_exit = reached_exit or player_next == exit
				if echo_count == 0:
					next_states[Vector2i(player_next, -1)] = true
					continue
				for echo_action: String in DIRECTIONS:
					var echo_next := _move(level, pair.y, echo_action, walls, open_doors)
					next_states[Vector2i(player_next, echo_next)] = true
		states = next_states

	_check(not reached_exit, "%s: no win with %d Echo (%d states at tick 12)" % [
		level.level_name, echo_count, states.size()
	])


func _check_door_routes(level: LevelData) -> void:
	for i in range(level.door_configs.size()):
		var target := level.exit_position
		if i == 0 and level.level_id in [3, 5]:
			# The relay is the only entrance to the chamber with the next plate.
			target = level.switch_positions.back()
		var closed_door := _cell_id(level, level.door_configs[i]["position"])
		var closed := {closed_door: false}
		var walls := _wall_lookup(level)
		var start := _cell_id(level, level.player_start)
		var queue: Array[int] = [start]
		var seen := {start: true}
		var next := 0
		while next < queue.size():
			for action: String in DIRECTIONS:
				var cell := _move(level, queue[next], action, walls, closed)
				if not seen.has(cell):
					seen[cell] = true
					queue.append(cell)
			next += 1
		_check(not seen.has(_cell_id(level, target)), "%s: door %d is required to reach %s" % [
			level.level_name, i + 1, str(target)
		])


func _play_solution(level: LevelData, solution: Array) -> void:
	GameManager.current_level = level.level_id
	# Exercise victory and the result UI without writing the tester's progress.
	GameManager.set("_level_completed_this_run", true)
	var gameplay := GAMEPLAY.instantiate()
	add_child(gameplay)
	var walls := _wall_lookup(level)
	var start := _cell_id(level, level.player_start)
	var trace_matches := true

	for loop_index in range(solution.size()):
		var recording: String = solution[loop_index]
		var positions: Array[int] = [start]
		for i in range(loop_index):
			positions.append(start)
		var open_doors := _open_doors(level, [])
		trace_matches = trace_matches and gameplay.loop_manager.get_echo_count() == loop_index
		trace_matches = trace_matches and _matches_world(gameplay, level, positions, open_doors)

		for tick in range(recording.length()):
			positions[0] = _move(level, positions[0], recording[tick], walls, open_doors)
			for i in range(loop_index):
				var history: String = solution[i]
				var replay := history[tick] if tick < history.length() else "W"
				positions[i + 1] = _move(level, positions[i + 1], replay, walls, open_doors)

			var button: Button = gameplay.hud.get(BUTTONS[recording[tick]])
			button.pressed.emit()
			open_doors = _open_doors(level, positions)
			trace_matches = trace_matches and _matches_world(gameplay, level, positions, open_doors)
			trace_matches = trace_matches and gameplay.loop_manager.get_tick_count() == tick + 1
			var final_tick: bool = loop_index == solution.size() - 1 and tick == recording.length() - 1
			trace_matches = trace_matches and gameplay.result_ui.visible == final_tick

		if loop_index < solution.size() - 1:
			gameplay.hud.end_loop_button.pressed.emit()
			trace_matches = trace_matches and gameplay.loop_manager.get_tick_count() == 0

	_check(trace_matches, "%s: Player/Echo cells, 48 px alignment, switches and doors match each tick" % level.level_name)
	_check(gameplay.result_ui.visible and gameplay.turn_manager.input_locked,
		"%s: Player wins with %d Echo at tick %d" % [
			level.level_name, solution.size() - 1, String(solution.back()).length()
		])
	_check(gameplay.result_ui.next_button.disabled == (level.level_id == LevelManager.MAX_LEVEL),
		"%s: Next Level state follows the five-level limit" % level.level_name)
	gameplay.queue_free()
	await get_tree().process_frame


func _wall_lookup(level: LevelData) -> Dictionary:
	var walls := {}
	for cell in level.wall_cells:
		walls[_cell_id(level, cell)] = true
	return walls


func _cell_id(level: LevelData, cell: Vector2i) -> int:
	return cell.y * level.grid_width + cell.x


func _open_doors(level: LevelData, positions: Array[int]) -> Dictionary:
	var doors := {}
	for config in level.door_configs:
		var is_open := true
		for index: int in config["switch_indices"]:
			is_open = is_open and positions.has(_cell_id(level, level.switch_positions[index]))
		doors[_cell_id(level, config["position"])] = is_open
	return doors


func _move(level: LevelData, from: int, action: String, walls: Dictionary, doors: Dictionary) -> int:
	if action == "W":
		return from
	@warning_ignore("integer_division")
	var cell := Vector2i(from % level.grid_width, from / level.grid_width)
	var target := cell + Vector2i(DIRECTIONS[action])
	var target_id := _cell_id(level, target)
	if level.is_in_bounds(target) and not walls.has(target_id) and doors.get(target_id, true):
		return target_id
	return from


func _matches_world(gameplay: Node, level: LevelData, positions: Array[int], doors: Dictionary) -> bool:
	var actors: Array[Node2D] = [gameplay.player]
	actors.append_array(gameplay.echoes)
	for i in range(actors.size()):
		var cell: Vector2i = actors[i].grid_position
		if positions[i] != _cell_id(level, cell) or actors[i].position != Vector2(cell * 48 + Vector2i(24, 24)):
			return false
	if gameplay.exit_portal.grid_position != level.exit_position or not _aligned(gameplay.exit_portal):
		return false
	for sw: PressureSwitch in gameplay.switches:
		if sw.is_active != positions.has(_cell_id(level, sw.grid_position)) or not _aligned(sw):
			return false
	for door: Door in gameplay.doors:
		if door.is_open != doors[_cell_id(level, door.grid_position)] or not _aligned(door):
			return false
	return true


func _aligned(object: Node2D) -> bool:
	return object.position == Vector2(object.grid_position * 48 + Vector2i(24, 24))


func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)
