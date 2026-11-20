extends Node

# ============================================================
# ECHO LOOP - GAME MANAGER
# Sprint 04 - Final Integration
#
# Quan ly:
# - Dieu huong Main Menu, Gameplay, Level Select
# - Tien trinh mo khoa Level 01-05
# - Luu tien trinh qua SaveManager
# - Khoi tao AudioManager khi game bat dau
# - Khoi phuc sound_enabled tu file Save
# ============================================================

signal game_started
signal level_changed(level_id: int)
signal level_completed(level_id: int)

const GAMEPLAY_SCENE: String = (
	"res://scenes/gameplay/gameplay.tscn"
)

const MAIN_MENU_SCENE: String = (
	"res://scenes/menus/main_menu.tscn"
)

const LEVEL_SELECT_SCENE: String = (
	"res://scenes/ui/level_select.tscn"
)

const SAVE_MANAGER_SCRIPT = preload(
	"res://scripts/data/save_manager.gd"
)

const AUDIO_MANAGER_SCRIPT = preload(
	"res://scripts/data/audio_manager.gd"
)

const LEVEL_UP_SOUND: AudioStream = preload(
	"res://assets/audio/level_up_sound.mp3"
)

var current_level: int = 1
var _level_completed_this_run: bool = false

var audio_manager: Node


# ============================================================
# INITIALIZATION
# ============================================================

func _ready() -> void:
	_initialize_audio()


func _initialize_audio() -> void:
	# Tao AudioManager mot lan trong GameManager Autoload.
	audio_manager = AUDIO_MANAGER_SCRIPT.new()
	audio_manager.name = "AudioManager"

	add_child(audio_manager)

	# Khoi phuc tuy chon am thanh da luu.
	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	var enabled: bool = bool(
		progress.get("sound_enabled", true)
	)

	audio_manager.call(
		"set_sound_enabled",
		enabled
	)

	print(
		"Audio preference restored: ",
		"ON" if enabled else "OFF"
	)


# ============================================================
# AUDIO PREFERENCE
# ============================================================

func is_sound_enabled() -> bool:
	if audio_manager == null:
		return false

	return bool(
		audio_manager.call("is_sound_enabled")
	)


func set_sound_enabled(enabled: bool) -> bool:
	# Luu tuy chon nhung khong thay doi unlocked_level.
	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	progress["sound_enabled"] = enabled

	if not save_manager.save_progress(progress):
		push_warning(
			"Khong the luu tuy chon am thanh."
		)
		return false

	if audio_manager != null:
		audio_manager.call(
			"set_sound_enabled",
			enabled
		)

	return true


# ============================================================
# LEVEL ACCESS
# ============================================================

func get_unlocked_level() -> int:
	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	return clampi(
		int(progress.get("unlocked_level", 1)),
		LevelManager.MIN_LEVEL,
		LevelManager.MAX_LEVEL
	)


func can_play_level(level_id: int) -> bool:
	return (
		level_id >= LevelManager.MIN_LEVEL
		and level_id <= LevelManager.MAX_LEVEL
		and level_id <= get_unlocked_level()
	)


func select_level(level_id: int) -> bool:
	if not can_play_level(level_id):
		push_warning(
			"Level %02d chua mo khoa hoac khong hop le."
			% level_id
		)
		return false

	current_level = level_id
	open_gameplay()

	return true


# ============================================================
# GAME NAVIGATION
# ============================================================

func start_new_game() -> void:
	current_level = 1
	game_started.emit()
	open_gameplay()


func open_gameplay() -> void:
	_level_completed_this_run = false

	get_tree().change_scene_to_file(
		GAMEPLAY_SCENE
	)

	level_changed.emit(current_level)


func back_to_menu() -> void:
	get_tree().change_scene_to_file(
		MAIN_MENU_SCENE
	)


# ============================================================
# LEVEL COMPLETION
# ============================================================

func complete_level() -> void:
	if _level_completed_this_run:
		return

	_level_completed_this_run = true

	var save_manager = SAVE_MANAGER_SCRIPT.new()
	var progress: Dictionary = save_manager.load_progress()

	var unlocked_level: int = int(
		progress.get("unlocked_level", 1)
	)

	# Mo khoa man tiep theo, nhung khong vuot Level 05.
	progress["unlocked_level"] = clampi(
		maxi(unlocked_level, current_level + 1),
		LevelManager.MIN_LEVEL,
		LevelManager.MAX_LEVEL
	)

	if not save_manager.save_progress(progress):
		push_warning(
			"Khong the luu tien trinh Level."
		)

	# Chi phat am thanh neu AudioManager cho phep.
	if audio_manager != null:
		audio_manager.call(
			"play_sound",
			LEVEL_UP_SOUND
		)

	level_completed.emit(current_level)


# ============================================================
# LEVEL SELECT
# ============================================================

func open_level_select() -> void:
	var tree: SceneTree = get_tree()

	var error: Error = tree.change_scene_to_file(
		LEVEL_SELECT_SCENE
	)

	if error != OK:
		push_error(
			"Khong mo duoc Level Select."
		)
		return

	var scene: Node = null

	# Cho scene duoc khoi tao.
	for attempt in range(3):
		await tree.process_frame

		scene = tree.current_scene

		if scene != null:
			break

	if scene == null:
		push_error(
			"Level Select chua duoc khoi tao."
		)
		return

	if scene.scene_file_path != LEVEL_SELECT_SCENE:
		push_error(
			"Scene hien tai khong phai Level Select."
		)
		return

	if not scene.has_method(
		"set_unlocked_levels"
	):
		push_error(
			"Level Select thieu API mo khoa."
		)
		return

	scene.call(
		"set_unlocked_levels",
		get_unlocked_level()
	)

	scene.level_selected.connect(
		_on_level_selected
	)

	scene.back_requested.connect(
		back_to_menu
	)


func _on_level_selected(level_id: int) -> void:
	select_level(level_id)
