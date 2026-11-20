extends Control

## S04-TV5: kiểm thử SaveManager và AudioManager độc lập.
## Chạy bằng F6 qua scenes/tests/save_flow_test.tscn.
## Không thêm Autoload và không gọi/sửa GameManager.
## File user://progress.json và file tạm được sao lưu rồi khôi phục sau test.

const SaveManagerScript = preload("res://scripts/data/save_manager.gd")
const AudioManagerScript = preload("res://scripts/data/audio_manager.gd")
const CLICK_SOUND: AudioStream = preload("res://assets/audio/click_sound.mp3")

const SAVE_PATH: String = "user://progress.json"
const TEMP_PATH: String = "user://progress.json.tmp"
const DEFAULT_DATA: Dictionary = {
	"unlocked_level": 1,
	"sound_enabled": true
}

@onready var status_label: Label = $Margin/Content/StatusLabel
@onready var output: TextEdit = $Margin/Content/Output
@onready var run_save_audio_button: Button = $Margin/Content/RunSaveAudioButton
@onready var check_levels_button: Button = $Margin/Content/CheckLevelsButton
@onready var clear_log_button: Button = $Margin/Content/ClearLogButton

var save_manager: Variant
var audio_manager: Node
var passed_count: int = 0
var failed_count: int = 0
var not_run_count: int = 0
var is_running: bool = false
var original_sound_enabled: bool = true
var original_master_muted: bool = false
var master_bus_index: int = -1


func _ready() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")
	if master_bus_index >= 0:
		original_master_muted = AudioServer.is_bus_mute(master_bus_index)

	save_manager = SaveManagerScript.new()
	audio_manager = AudioManagerScript.new()
	audio_manager.name = "AudioManagerTestFixture"
	add_child(audio_manager)

	# Đồng bộ fixture với tùy chọn âm thanh hiện có trước khi chạy test.
	var initial_progress: Dictionary = save_manager.load_progress()
	original_sound_enabled = bool(initial_progress.get("sound_enabled", true))
	audio_manager.call("set_sound_enabled", original_sound_enabled)

	run_save_audio_button.pressed.connect(_on_run_save_audio_pressed)
	check_levels_button.pressed.connect(_on_check_levels_pressed)
	clear_log_button.pressed.connect(_on_clear_log_pressed)

	status_label.text = "Sẵn sàng. Chọn một nhóm kiểm thử; file save hiện tại sẽ được khôi phục."
	_log("S04-TV5 Save/Audio QA fixture ready.")
	_log("Engine: Godot %s" % str(Engine.get_version_info().get("string", "unknown")))
	_log("SaveManager được tạo bằng SaveManager.new(); AudioManager được inject làm child.")


func _on_run_save_audio_pressed() -> void:
	if is_running:
		return
	_begin_run("SAVE / AUDIO")

	# Chụp nguyên văn cả file chính và file tạm trước mọi thao tác có thể ghi.
	var save_backup: Dictionary = _snapshot_file(SAVE_PATH)
	var temp_backup: Dictionary = _snapshot_file(TEMP_PATH)
	if not bool(save_backup.get("ok", false)) or not bool(temp_backup.get("ok", false)):
		_mark_not_run("Không đọc được file save hiện tại; dừng để bảo vệ dữ liệu người dùng.")
		_finish_run()
		return

	var initial_data: Dictionary = save_manager.load_progress()
	original_sound_enabled = bool(initial_data.get("sound_enabled", true))

	_log("--- SAVE TESTS ---")
	_run_save_tests()
	_log("--- AUDIO TESTS ---")
	_run_audio_tests()

	# Luôn khôi phục dữ liệu người dùng kể cả khi một assertion thất bại.
	_log("--- CLEANUP ---")
	_check(_restore_snapshot(SAVE_PATH, save_backup), "Khôi phục nguyên văn user://progress.json")
	_check(_restore_snapshot(TEMP_PATH, temp_backup), "Khôi phục nguyên văn user://progress.json.tmp")

	# Khôi phục trạng thái audio của phiên editor trước khi test.
	audio_manager.call("stop_sound")
	audio_manager.call("set_sound_enabled", original_sound_enabled)
	if master_bus_index >= 0:
		AudioServer.set_bus_mute(master_bus_index, original_master_muted)

	# Chưa thể kết luận monotonic/cap ở fixture SaveManager: owner của cap phải do Leader chốt.
	_mark_not_run("Unlock monotonic qua GameManager: chờ kiểm thử F5 trên integration branch.")
	_mark_not_run("Cap unlocked_level <= 5: chờ Leader xác nhận vị trí kiểm tra/contract.")
	_finish_run()


func _run_save_tests() -> void:
	var reset_ok: bool = save_manager.reset_progress()
	_check(reset_ok, "SAVE-01: reset test file để kiểm tra dữ liệu mặc định")
	var default_data: Dictionary = save_manager.load_progress()
	_check(default_data == DEFAULT_DATA, "SAVE-01: file không tồn tại -> Level 1, Sound ON")

	var test_input: Dictionary = {
		"unlocked_level": 3,
		"sound_enabled": false,
		"current_loop": 2,
		"current_tick": 7,
		"action_history": ["RIGHT", "WAIT"]
	}
	_check(save_manager.save_progress(test_input), "SAVE-02: save_progress ghi dữ liệu hợp lệ")

	var fresh_manager: Variant = SaveManagerScript.new()
	var loaded_data: Dictionary = fresh_manager.load_progress()
	var expected_data: Dictionary = {
		"unlocked_level": 3,
		"sound_enabled": false
	}
	_check(loaded_data == expected_data, "SAVE-02: instance SaveManager mới đọc lại đúng Level/Sound")

	var raw_json: String = _read_text(SAVE_PATH)
	var parser := JSON.new()
	var parse_ok: bool = parser.parse(raw_json) == OK
	var only_allowed_keys: bool = false
	var transient_fields_absent: bool = false
	if parse_ok and typeof(parser.data) == TYPE_DICTIONARY:
		var stored: Dictionary = parser.data
		only_allowed_keys = (
			stored.size() == 2
			and stored.has("unlocked_level")
			and stored.has("sound_enabled")
		)
		transient_fields_absent = (
			not stored.has("current_loop")
			and not stored.has("current_tick")
			and not stored.has("action_history")
		)
	_check(only_allowed_keys, "SAVE-03: JSON chỉ chứa unlocked_level và sound_enabled")
	_check(transient_fields_absent, "SAVE-04: tick/loop/action không được lưu")

	var corrupt_written: bool = _write_text(SAVE_PATH, "{ invalid json ")
	var fallback_data: Dictionary = fresh_manager.load_progress()
	_check(corrupt_written and fallback_data == DEFAULT_DATA, "SAVE-05: JSON hỏng -> fallback mặc định")


func _run_audio_tests() -> void:
	# Kiểm tra khôi phục preference: đọc từ SaveManager rồi áp dụng cho AudioManager fixture.
	_check(save_manager.save_progress({"unlocked_level": 3, "sound_enabled": false}), "AUDIO-01: lưu preference Sound OFF")
	var loaded_off: Dictionary = SaveManagerScript.new().load_progress()
	audio_manager.call("set_sound_enabled", bool(loaded_off.get("sound_enabled", true)))
	_check(not bool(audio_manager.call("is_sound_enabled")), "AUDIO-01: AudioManager khôi phục Sound OFF từ save")

	# Mute phải chặn play_sound, không chỉ mute Master bus.
	audio_manager.call("stop_sound")
	audio_manager.call("play_sound", CLICK_SOUND)
	_check(not _any_audio_player_playing(), "AUDIO-02: play_sound không phát khi Sound OFF")
	if master_bus_index >= 0:
		_check(AudioServer.is_bus_mute(master_bus_index), "AUDIO-02: Master bus được mute khi Sound OFF")
	else:
		_mark_not_run("Không tìm thấy audio bus Master để kiểm tra trạng thái mute.")

	_check(save_manager.save_progress({"unlocked_level": 3, "sound_enabled": true}), "AUDIO-03: lưu preference Sound ON")
	var loaded_on: Dictionary = SaveManagerScript.new().load_progress()
	audio_manager.call("set_sound_enabled", bool(loaded_on.get("sound_enabled", false)))
	_check(bool(audio_manager.call("is_sound_enabled")), "AUDIO-03: AudioManager khôi phục Sound ON từ save")
	audio_manager.call("stop_sound")
	audio_manager.call("play_sound", CLICK_SOUND)
	_check(_any_audio_player_playing(), "AUDIO-03: play_sound bắt đầu phát click khi Sound ON")
	audio_manager.call("stop_sound")


func _on_check_levels_pressed() -> void:
	if is_running:
		return
	_begin_run("LEVEL RESOURCE CHECK")
	_log("Kiểm tra res://data/levels/level_01.tres đến level_05.tres.")

	for level_id in range(1, 6):
		var path: String = "res://data/levels/level_%02d.tres" % level_id
		if not ResourceLoader.exists(path):
			_mark_not_run("LEVEL-%02d: thiếu %s (chờ TV3 merge vào main/integration)." % [level_id, path])
			continue

		var loaded_resource: Resource = ResourceLoader.load(path)
		if loaded_resource == null or not (loaded_resource is LevelData):
			_check(false, "LEVEL-%02d: resource không load được thành LevelData" % level_id)
			continue

		var level_data: LevelData = loaded_resource as LevelData
		_check(level_data.level_id == level_id, "LEVEL-%02d: level_id đúng bằng %d" % [level_id, level_id])
		var validation_errors: PackedStringArray = level_data.validate_level()
		_check(validation_errors.is_empty(), "LEVEL-%02d: LevelData.validate_level() không có lỗi: %s" % [level_id, str(validation_errors)])

	_log("Lưu ý: test này kiểm tra Resource/ID/schema cơ bản, không tự chứng minh lời giải thắng bằng gameplay.")
	_finish_run()


func _begin_run(title: String) -> void:
	is_running = true
	passed_count = 0
	failed_count = 0
	not_run_count = 0
	output.clear()
	status_label.text = "Đang chạy: %s" % title
	run_save_audio_button.disabled = true
	check_levels_button.disabled = true
	clear_log_button.disabled = true
	_log("==================================================")
	_log("START: %s" % title)
	_log("==================================================")


func _finish_run() -> void:
	_log("--------------------------------------------------")
	_log("SUMMARY: %d PASS | %d FAIL | %d NOT RUN" % [passed_count, failed_count, not_run_count])
	_log("--------------------------------------------------")
	status_label.text = "%d PASS | %d FAIL | %d NOT RUN" % [passed_count, failed_count, not_run_count]
	is_running = false
	run_save_audio_button.disabled = false
	check_levels_button.disabled = false
	clear_log_button.disabled = false


func _check(condition: bool, description: String) -> void:
	if condition:
		passed_count += 1
		_log("[PASS] " + description)
	else:
		failed_count += 1
		_log("[FAIL] " + description)
		push_error("[FAIL] " + description)


func _mark_not_run(description: String) -> void:
	not_run_count += 1
	_log("[NOT RUN] " + description)


func _any_audio_player_playing() -> bool:
	if audio_manager == null:
		return false
	for child in audio_manager.get_children():
		if child is AudioStreamPlayer and child.is_playing():
			return true
	return false


func _snapshot_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": true, "exists": false, "content": ""}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "exists": true, "content": ""}
	var content: String = file.get_as_text()
	file.close()
	return {"ok": true, "exists": true, "content": content}


func _restore_snapshot(path: String, snapshot: Dictionary) -> bool:
	if bool(snapshot.get("exists", false)):
		return _write_text(path, str(snapshot.get("content", "")))
	return _remove_file(path)


func _remove_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var absolute_path: String = ProjectSettings.globalize_path(path)
	return DirAccess.remove_absolute(absolute_path) == OK


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


func _write_text(path: String, content: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.flush()
	var result: bool = file.get_error() == OK
	file.close()
	return result


func _on_clear_log_pressed() -> void:
	if is_running:
		return
	output.clear()
	status_label.text = "Log đã được xóa."
	_log("Ready.")


func _log(message: String) -> void:
	# Ghi log ra Output của Godot và TextEdit trong scene test.
	print(message)
	if output != null:
		output.text += message + "\n"
