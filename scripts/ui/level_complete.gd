extends Control

signal result_next_requested
signal result_replay_requested
signal result_level_select_requested

@onready var next_button: Button = $CompletePanel/VBoxContainer/NextButton
@onready var replay_button: Button = $CompletePanel/VBoxContainer/ReplayButton
@onready var level_select_button: Button = $CompletePanel/VBoxContainer/LevelSelectButton

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	replay_button.pressed.connect(_on_replay_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)

func set_completed_level(level_id: int) -> void:
	next_button.disabled = level_id >= LevelManager.MAX_LEVEL
	$CompletePanel/VBoxContainer/Detail.text = (
		"Final level cleared" if next_button.disabled else "Level %02d cleared" % level_id
	)

func _on_next_pressed() -> void:
	result_next_requested.emit()
	print("Next level requested")

func _on_replay_pressed() -> void:
	result_replay_requested.emit()
	print("Replay requested")

func _on_level_select_pressed() -> void:
	result_level_select_requested.emit()
	print("Level select requested")
