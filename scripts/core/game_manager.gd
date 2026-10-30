extends Node


signal game_started
signal level_changed(level_id: int)
signal level_completed(level_id: int)

const GAMEPLAY_SCENE: String = "res://scenes/gameplay/gameplay.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"

var current_level: int = 1

func start_new_game() -> void:
	current_level = 1
	game_started.emit()
	open_gameplay()

func open_gameplay() -> void:
	get_tree().change_scene_to_file(GAMEPLAY_SCENE)
	level_changed.emit(current_level)

func back_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func complete_level() -> void:
	level_completed.emit(current_level)
