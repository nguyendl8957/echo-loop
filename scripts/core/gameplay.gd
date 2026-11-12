extends Node2D

const LEVEL_PATH: String = "res://data/levels/level_01.tres"
const EXIT_SCENE: PackedScene = preload(
	"res://scenes/puzzle/exit_portal.tscn"
)
const CELL_SIZE: int = 48

@onready var player: PlayerController = $LevelRoot/Player
@onready var walls_node: Node2D = $LevelRoot/Walls
@onready var objects_node: Node2D = $LevelRoot/InteractiveObjects
@onready var hud = $HUD

var level_data: LevelData
var exit_portal: ExitPortal
var loop_manager: TimeLoopManager
var turn_manager: TurnManager


func _ready() -> void:
	var resource := ResourceLoader.load(LEVEL_PATH)

	if not resource is LevelData:
		push_error("Khong nap duoc LevelData: " + LEVEL_PATH)
		return

	level_data = resource as LevelData

	var errors := level_data.validate_level()
	if not errors.is_empty():
		push_error("LevelData khong hop le: " + str(errors))
		return

	loop_manager = TimeLoopManager.new()
	turn_manager = TurnManager.new()
	add_child(loop_manager)
	add_child(turn_manager)

	turn_manager.setup(loop_manager)
	turn_manager.auto_advance_loops = false

	hud.action_requested.connect(_on_action_requested)
	hud.restart_requested.connect(_on_restart_requested)

	turn_manager.tick_actions_requested.connect(
		_on_tick_actions_requested
	)
	turn_manager.tick_finished.connect(_on_tick_finished)

	# Sprint 02 chua su dung End Loop de tao Echo.
	hud.get_node(
		"HUDRoot/ControlsArea/EndLoopButton"
	).disabled = true

	_create_walls()
	_create_exit()
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


func _restart_world() -> void:
	turn_manager.restart_run()
	player.reset_position(level_data.player_start)
	_update_hud()


func _on_action_requested(action: String) -> void:
	turn_manager.submit_player_action(action)


func _on_tick_actions_requested(
	tick_number: int,
	action: String,
	_echo_actions: PackedStringArray
) -> void:
	# Chi kiem tra target, khong doi trang thai cua o.
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

	# Tuong va bien ban do deu la o bi chan.
	var blocked: Array[Vector2i] = level_data.wall_cells.duplicate()
	var target: Vector2i = player.grid_position + direction

	if not level_data.is_in_bounds(target):
		blocked.append(target)

	# Player tu xu ly UP/DOWN/LEFT/RIGHT/WAIT.
	player.apply_action(action, blocked)

	print(
		"Tick ", tick_number,
		" | ", action,
		" | Cell: ", player.grid_position
	)

	# Chi Player duoc kiem tra dieu kien thang.
	if exit_portal.check_player_reached(player.grid_position):
		turn_manager.input_locked = true
		GameManager.complete_level()
		print("LEVEL 01 COMPLETED")


func _on_tick_finished(_tick_number: int) -> void:
	_update_hud()


func _update_hud() -> void:
	hud.update_hud(
		level_data.level_id,
		loop_manager.get_tick_count(),
		TimeLoopManager.MAX_TICKS,
		0
	)


func _on_restart_requested() -> void:
	# Nap lai scene cung reset trang thai thang trong GameManager.
	GameManager.call_deferred("open_gameplay")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				GameManager.call_deferred("back_to_menu")
