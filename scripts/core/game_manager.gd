extends Node


signal game_started
signal level_changed(level_id: int)
signal level_completed(level_id: int)

const GAMEPLAY_SCENE: String = "res://scenes/gameplay/gameplay.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"
const SAVE_MANAGER_SCRIPT = preload("res://scripts/data/save_manager.gd")

var current_level: int = 1
var _level_completed_this_run: bool = false

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

	progress["unlocked_level"] = maxi(
		unlocked_level,
		current_level + 1
	)

	if not save_manager.save_progress(progress):
		push_warning("Khong the luu tien trinh Level.")

	level_completed.emit(current_level)
