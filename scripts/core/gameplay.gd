extends Node2D

const LEVEL_PATH: String = "res://data/levels/level_01.tres"
const EXIT_SCENE: PackedScene = preload(
	"res://scenes/puzzle/exit_portal.tscn"
)
const SWITCH_SCENE: PackedScene = preload(
	"res://scenes/puzzle/pressure_switch.tscn"
)
const DOOR_SCENE: PackedScene = preload(
	"res://scenes/puzzle/door.tscn"
)

const ECHO_SCENE: PackedScene = preload(
	"res://scenes/player/echo.tscn"
)
const CELL_SIZE: int = 48

@onready var player: PlayerController = $LevelRoot/Player
@onready var echo_container: Node2D = $LevelRoot/EchoContainer
@onready var walls_node: Node2D = $LevelRoot/Walls
@onready var objects_node: Node2D = $LevelRoot/InteractiveObjects
@onready var hud = $HUD

# Chi dung de truyen LevelData tam khi kiem thu.
var level_override: LevelData
var level_data: LevelData
var exit_portal: ExitPortal
var loop_manager: TimeLoopManager
var turn_manager: TurnManager
var switches: Array[PressureSwitch] = []
var doors: Array[Door] = []
var echoes: Array[EchoController] = []


func _ready() -> void:
	var resource: Resource = (
	level_override
	if level_override != null
	else ResourceLoader.load(LEVEL_PATH)
)

	if not resource is LevelData:
		push_error("Khong nap duoc LevelData: " + LEVEL_PATH)
		return

	level_data = resource as LevelData

	var errors := level_data.validate_level()
	if not _validate_door_configs():
		push_error("Invalid door configuration. Gameplay aborted.")
		return
	if not errors.is_empty():
		push_error("LevelData khong hop le: " + str(errors))
		return
	

	loop_manager = TimeLoopManager.new()
	turn_manager = TurnManager.new()
	add_child(loop_manager)
	add_child(turn_manager)

	turn_manager.setup(loop_manager)
	turn_manager.auto_advance_loops = true

	hud.action_requested.connect(_on_action_requested)
	hud.end_loop_requested.connect(_on_end_loop_requested)
	hud.restart_requested.connect(_on_restart_requested)

	turn_manager.tick_actions_requested.connect(
		_on_tick_actions_requested
	)
	turn_manager.tick_finished.connect(_on_tick_finished)

	_create_walls()
	_create_switches_and_doors()
	_create_exit()
	
	loop_manager.run_failed.connect(_on_run_failed)
	loop_manager.loop_started.connect(_on_loop_started)
	
	_restart_world()

func _create_walls() -> void:
	for cell in level_data.wall_cells:
		var wall := Polygon2D.new()
		wall.color = Color(0.15, 0.35, 0.48)
		wall.polygon = PackedVector2Array([
			Vector2(0, 0),
			Vector2(CELL_SIZE, 0),
			Vector2(CELL_SIZE, CELL_SIZE),
			Vector2(0, CELL_SIZE)
		])
		wall.position = Vector2(cell * CELL_SIZE)
		walls_node.add_child(wall)


func _create_exit() -> void:
	exit_portal = EXIT_SCENE.instantiate() as ExitPortal
	objects_node.add_child(exit_portal)
	exit_portal.grid_position = level_data.exit_position


func _validate_door_configs() -> bool:
	var occupied_doors: Array[Vector2i] = []

	for config in level_data.door_configs:
		var cell: Variant = config.get("position", null)
		var indices: Variant = config.get("switch_indices", null)

		if not (cell is Vector2i):
			push_error("Door position must be Vector2i")
			return false

		if not level_data.is_in_bounds(cell):
			push_error("Door is out of bounds")
			return false

		if level_data.wall_cells.has(cell):
			push_error("Door overlaps a wall")
			return false

		if occupied_doors.has(cell):
			push_error("Duplicate door position")
			return false

		if not (indices is Array):
			push_error("Door switch_indices must be Array")
			return false

		if indices.size() < 1 or indices.size() > 2:
			push_error("Door requires 1 or 2 switches")
			return false

		for index in indices:
			if typeof(index) != TYPE_INT:
				push_error("Switch index must be int")
				return false

			if index < 0 or index >= level_data.switch_positions.size():
				push_error("Switch index is out of range")
				return false

		occupied_doors.append(cell)

	return true

func _create_switches_and_doors() -> void:
	# Tao cong tac tu LevelData.
	for cell in level_data.switch_positions:
		var sw := SWITCH_SCENE.instantiate() as PressureSwitch
		objects_node.add_child(sw)
		sw.grid_position = cell
		switches.append(sw)

	# Tao cua va lien ket cong tac theo chi so.
	for config in level_data.door_configs:
		var cell: Variant = config.get("position", null)
		var indices: Variant = config.get("switch_indices", null)

		if not (cell is Vector2i) or not (indices is Array):
			push_error("Door config thieu position/switch_indices")
			continue

		if indices.size() < 1 or indices.size() > 2:
			push_error("Moi cua phai lien ket 1 hoac 2 switch")
			continue

		var valid := true
		for index in indices:
			if typeof(index) != TYPE_INT:
				valid = false
			elif index < 0 or index >= switches.size():
				valid = false

		if not valid:
			push_error("Door config co switch index khong hop le")
			continue

		var door := DOOR_SCENE.instantiate() as Door
		objects_node.add_child(door)
		door.grid_position = cell

		for index in indices:
			door.linked_switches.append(switches[index])

		doors.append(door)
		

func _clear_echoes() -> void:
	for echo in echoes:
		if is_instance_valid(echo):
			echo.queue_free()

	echoes.clear()
	

func _spawn_echoes() -> void:
	var echo_count: int = min(
		loop_manager.echo_histories.size(),
		TimeLoopManager.MAX_ECHOES
	)

	for i in range(echo_count):
		var echo := ECHO_SCENE.instantiate() as EchoController

		if echo == null:
			push_error("Cannot instantiate EchoController")
			return

		echo_container.add_child(echo)

		var tint := Color(0.3, 0.9, 1.0, 0.65)
		if i == 1:
			tint = Color(0.8, 0.4, 1.0, 0.65)

		echo.setup_echo(
			level_data.player_start,
			loop_manager.echo_histories[i],
			tint
		)

		echoes.append(echo)
		

func _reset_world_state() -> void:
	# Xoa cac Echo cu khoi scene.
	_clear_echoes()

	# Reset cong tac va cua.
	for sw in switches:
		sw.reset_state()

	for door in doors:
		door.reset_state()

	# Dua Player ve o bat dau.
	player.reset_position(level_data.player_start)

	# Tao lai Echo tu lich su cac vong da hoan thanh.
	_spawn_echoes()


func _on_loop_started(_echo_count: int) -> void:
	_reset_world_state()
	_update_hud()
	

func _on_run_failed() -> void:
	turn_manager.input_locked = true
	hud.set_input_locked(true)
	print("RUN FAILED: Da het 3 Time Loops")


func _restart_world() -> void:
	# Xoa lich su va quay ve Loop 1.
	# reset_run() se phat signal loop_started.
	turn_manager.restart_run()


func _on_action_requested(action: String) -> void:
	turn_manager.submit_player_action(action)
	
	
func _on_end_loop_requested() -> void:
	if turn_manager.input_locked:
		return

	if loop_manager.is_finished:
		return

	turn_manager.end_current_loop()


func _blocked_for_action(
	start_cell: Vector2i,
	action: String,
	snapshot_blocked: Array[Vector2i]
) -> Array[Vector2i]:
	var blocked: Array[Vector2i] = snapshot_blocked.duplicate()
	var direction := Vector2i.ZERO

	match action:
		"UP":
			direction = Vector2i.UP
		"DOWN":
			direction = Vector2i.DOWN
		"LEFT":
			direction = Vector2i.LEFT
		"RIGHT":
			direction = Vector2i.RIGHT
		"WAIT":
			return blocked
		_:
			return blocked

	var target: Vector2i = start_cell + direction

	if not level_data.is_in_bounds(target):
		blocked.append(target)

	return blocked


func _on_tick_actions_requested(
	tick_number: int,
	action: String,
	echo_actions: PackedStringArray
) -> void:
	# 1. Snapshot cua dau tick.
	# Tat ca actor dung cung danh sach o bi chan.
	var snapshot_blocked: Array[Vector2i] = (
		level_data.wall_cells.duplicate()
	)

	for door in doors:
		var snapshot_is_open: bool = door.is_open

		if door.is_blocking_for_tick(snapshot_is_open):
			snapshot_blocked.append(door.grid_position)

	# 2. TurnManager da thu thap action cua Player
	# va Echo truoc khi phat signal nay.
	var tick_index: int = tick_number - 1

	if echo_actions.size() != echoes.size():
		push_error("Echo action count does not match Echo count")
		return

	# 3. Player di chuyen theo snapshot dau tick.
	var player_blocked := _blocked_for_action(
		player.grid_position,
		action,
		snapshot_blocked
	)

	player.apply_action(action, player_blocked)

	# 4. Moi Echo replay action cua cung tick.
	# Khong cap nhat Switch/Door giua cac actor.
	for i in range(echoes.size()):
		var echo: EchoController = echoes[i]

		var echo_blocked := _blocked_for_action(
			echo.grid_position,
			echo_actions[i],
			snapshot_blocked
		)

		echo.apply_echo_action(tick_index, echo_blocked)

	# 5. Thu thap vi tri TAT CA actor sau di chuyen.
	var actor_positions: Array[Vector2i] = [
		player.grid_position
	]

	for echo in echoes:
		actor_positions.append(echo.grid_position)

	# 6. Cap nhat cong tac SAU khi moi actor da di chuyen.
	for sw in switches:
		sw.update_state(actor_positions)

	# 7. Cap nhat cua SAU cong tac.
	for door in doors:
		door.evaluate_state()

	# 8. Chi Player hien tai duoc kich hoat Exit.
	if exit_portal.check_player_reached(player.grid_position):
		turn_manager.input_locked = true
		GameManager.complete_level()
		print("LEVEL COMPLETED AT TICK ", tick_number)
		return

	# 9. Debug replay.
	# TurnManager se phat tick_finished sau khi ham nay xong.
	print(
		"Loop ", loop_manager.loop_number,
		" | Tick ", tick_number,
		" | Player ", player.grid_position,
		" | Echoes ", echoes.size()
	)


func _on_tick_finished(_tick_number: int) -> void:
	_update_hud()


func _update_hud() -> void:
	var echo_count: int = loop_manager.get_echo_count()

	hud.update_hud(
		level_data.level_id,
		loop_manager.get_tick_count(),
		TimeLoopManager.MAX_TICKS,
		echo_count
	)

	hud.update_loop_status(
		loop_manager.loop_number,
		echo_count,
		turn_manager.input_locked or loop_manager.is_finished
	)


func _on_restart_requested() -> void:
	# Nap lai scene cung reset trang thai thang trong GameManager.
	GameManager.call_deferred("open_gameplay")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				GameManager.call_deferred("back_to_menu")
