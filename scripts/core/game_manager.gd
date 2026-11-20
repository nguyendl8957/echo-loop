extends Node


signal game_started
signal level_changed(level_id: int)
signal level_completed(level_id: int)

const GAMEPLAY_SCENE: String = "res://scenes/gameplay/gameplay.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/ui/level_select.tscn"
const SAVE_MANAGER_SCRIPT = preload("res://scripts/data/save_manager.gd")

var current_level: int = 1
var _level_completed_this_run: bool = false

# Doc tien trinh da luu, gioi han trong 5 level.
func get_unlocked_level() -> int:
	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	return clampi(
		int(progress.get("unlocked_level", 1)),
		LevelManager.MIN_LEVEL,
		LevelManager.MAX_LEVEL
	)


# Kiem tra nguoi choi co duoc vao level nay khong.
func can_play_level(level_id: int) -> bool:
	return (
		level_id >= LevelManager.MIN_LEVEL
		and level_id <= LevelManager.MAX_LEVEL
		and level_id <= get_unlocked_level()
	)

# Mo man choi neu da duoc mo khoa.
func select_level(level_id: int) -> bool:
	if not can_play_level(level_id):
		push_warning(
			"Level %02d chua duoc mo khoa hoac khong hop le."
			% level_id
		)
		return false

	current_level = level_id
	open_gameplay()
	return true

func start_new_game() -> void:
	current_level = 1
	game_started.emit()
	open_gameplay()

func open_gameplay() -> void:
	_level_completed_this_run = false
	get_tree().change_scene_to_file(GAMEPLAY_SCENE)
	level_changed.emit(current_level)

func back_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func complete_level() -> void:
	if _level_completed_this_run:
		return

	_level_completed_this_run = true

	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	var unlocked_level: int = int(
		progress.get("unlocked_level", 1)
	)


	progress["unlocked_level"] = clampi(
		maxi(unlocked_level, current_level + 1),
		LevelManager.MIN_LEVEL,
		LevelManager.MAX_LEVEL
	)

	if not save_manager.save_progress(progress):
		push_warning("Khong the luu tien trinh Level.")

	level_completed.emit(current_level)


# Mo giao dien chon man cua TV4.
func open_level_select() -> void:
	var tree: SceneTree = get_tree()

	var error: Error = tree.change_scene_to_file(
		LEVEL_SELECT_SCENE
	)

	if error != OK:
		push_error("Khong mo duoc Level Select.")
		return

	# Cho Godot hoan tat qua trinh chuyen scene.
	var scene: Node = null

	for attempt in range(3):
		await tree.process_frame
		scene = tree.current_scene

		if scene != null:
			break

	if scene == null:
		push_error("Level Select chua duoc khoi tao.")
		return

	if scene.scene_file_path != LEVEL_SELECT_SCENE:
		push_error("Scene hien tai khong phai Level Select.")
		return

	scene.call(
		"set_unlocked_levels",
		get_unlocked_level()
	)

	scene.level_selected.connect(_on_level_selected)
	scene.back_requested.connect(back_to_menu)

func _on_level_selected(level_id: int) -> void:
	select_level(level_id)
