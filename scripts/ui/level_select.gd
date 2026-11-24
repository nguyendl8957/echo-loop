extends Control

signal level_selected(level_id: int)
signal back_requested

@onready var level_01_button: Button = $LevelGrid/Level01Button
@onready var level_02_button: Button = $LevelGrid/Level02Button
@onready var level_03_button: Button = $LevelGrid/Level03Button
@onready var level_04_button: Button = $LevelGrid/Level04Button
@onready var level_05_button: Button = $LevelGrid/Level05Button
@onready var back_button: Button = $BackButton


func _ready() -> void:
	level_01_button.pressed.connect(func(): level_selected.emit(1))
	level_02_button.pressed.connect(func(): level_selected.emit(2))
	level_03_button.pressed.connect(func(): level_selected.emit(3))
	level_04_button.pressed.connect(func(): level_selected.emit(4))
	level_05_button.pressed.connect(func(): level_selected.emit(5))

	back_button.pressed.connect(func(): back_requested.emit())

	set_unlocked_levels(1)


func set_unlocked_levels(unlocked_count: int) -> void:
	var buttons: Array[Button] = [
		level_01_button,
		level_02_button,
		level_03_button,
		level_04_button,
		level_05_button
	]

	for i in range(buttons.size()):
		var level := LevelManager.load_level(i + 1)
		buttons[i].disabled = i >= unlocked_count or level == null
		var title := level.level_name if level != null else "Unavailable"
		var status := "LOCKED" if buttons[i].disabled else "READY"
		buttons[i].text = "LEVEL %02d\n\n%s\n\n%s" % [i + 1, title, status]

# Android Back / PC Escape
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back()


func _input(event: InputEvent) -> void:
	if OS.has_feature("android"):
		return

	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				_handle_back()


func _handle_back() -> void:
	GameManager.back_to_menu()
