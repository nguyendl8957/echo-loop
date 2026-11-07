extends RefCounted
## SaveManager (TV5) — lưu/đọc tiến trình cục bộ tại user://.
## Chỉ lưu 2 giá trị: unlocked_level và sound_enabled.
## KHÔNG lưu tick, Echo hay trạng thái đang chơi dở.
## Không phải Autoload: nơi khác tự tạo bằng SaveManager.new() (Leader quyết định cách nối).

const SAVE_PATH: String = "user://progress.json"
const TEMP_PATH: String = "user://progress.json.tmp"

const DEFAULT_DATA: Dictionary = {
	"unlocked_level": 1,
	"sound_enabled": true
}


## Đọc dữ liệu đã lưu. Luôn trả về Dictionary hợp lệ (đủ 2 khóa).
## File không tồn tại / hỏng / sai kiểu -> dùng giá trị mặc định.
func load_progress() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return DEFAULT_DATA.duplicate()

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return DEFAULT_DATA.duplicate()

	var content: String = file.get_as_text()
	file.close()

	# Dùng JSON.new().parse() để file hỏng không in lỗi đỏ ra Debugger.
	var json := JSON.new()
	if json.parse(content) != OK:
		return DEFAULT_DATA.duplicate()

	var loaded_data: Variant = json.data
	if typeof(loaded_data) != TYPE_DICTIONARY:
		return DEFAULT_DATA.duplicate()

	var level: int = _parse_level(loaded_data.get("unlocked_level", null))
	var sound: Variant = loaded_data.get("sound_enabled", null)

	if level < 1:
		level = DEFAULT_DATA["unlocked_level"]
	if typeof(sound) != TYPE_BOOL:
		sound = DEFAULT_DATA["sound_enabled"]

	return {
		"unlocked_level": level,
		"sound_enabled": sound
	}


## Ghi dữ liệu. Trả về true nếu ghi thành công.
## Dữ liệu sai kiểu bị từ chối (không ghi đè lên file cũ).
func save_progress(data: Dictionary) -> bool:
	var level: int = _parse_level(data.get("unlocked_level", null))
	var sound: Variant = data.get("sound_enabled", null)

	if level < 1:
		return false
	if typeof(sound) != TYPE_BOOL:
		return false

	# Chỉ lưu đúng 2 thông tin theo Issue; mọi khóa khác bị bỏ qua.
	var json_text: String = JSON.stringify({
		"unlocked_level": level,
		"sound_enabled": sound
	})

	# Ghi file tạm rồi đổi tên để file chính không hỏng nếu app tắt giữa chừng.
	if _write_text(TEMP_PATH, json_text):
		if DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH) == OK:
			return true
		DirAccess.remove_absolute(TEMP_PATH)

	# Dự phòng: ghi trực tiếp nếu đổi tên thất bại.
	return _write_text(SAVE_PATH, json_text)


## Xóa tiến trình (dùng cho test/QA). Trả về true nếu không còn file.
func reset_progress() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return true
	return DirAccess.remove_absolute(SAVE_PATH) == OK


func _write_text(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	var err: Error = file.get_error()
	file.close()
	return err == OK


## JSON trong Godot trả mọi số là float (2 -> 2.0), nên chấp nhận float
## có giá trị nguyên. Trả về -1 nếu không hợp lệ.
func _parse_level(value: Variant) -> int:
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			if is_equal_approx(value, roundf(value)):
				return int(value)
	return -1
