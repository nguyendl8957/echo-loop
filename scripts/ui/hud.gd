
extends CanvasLayer

signal action_requested(action: String)
signal end_loop_requested
signal restart_requested

@onready var up_button: Button = $HUDRoot/ControlsArea/UpButton
@onready var down_button: Button = $HUDRoot/ControlsArea/DownButton
@onready var left_button: Button = $HUDRoot/ControlsArea/LeftButton
@onready var right_button: Button = $HUDRoot/ControlsArea/RightButton
@onready var wait_button: Button = $HUDRoot/ControlsArea/WaitButton
@onready var end_loop_button: Button = $HUDRoot/ControlsArea/EndLoopButton
@onready var restart_button: Button = $HUDRoot/ControlsArea/RestartButton

@onready var level_label: Label = $HUDRoot/TopBar/LevelLabel
@onready var tick_label: Label = $HUDRoot/TopBar/TickLabel
@onready var echo_label: Label = $HUDRoot/TopBar/EchoLabel


func _ready() -> void:
	up_button.pressed.connect(func(): _request_action("UP"))
	down_button.pressed.connect(func(): _request_action("DOWN"))
	left_button.pressed.connect(func(): _request_action("LEFT"))
	right_button.pressed.connect(func(): _request_action("RIGHT"))
	wait_button.pressed.connect(func(): _request_action("WAIT"))

	end_loop_button.pressed.connect(_on_end_loop_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func _request_action(action: String) -> void:
	action_requested.emit(action)
	print("Action requested: ", action)


func _on_end_loop_pressed() -> void:
	end_loop_requested.emit()
	print("End loop requested")


func _on_restart_pressed() -> void:
	restart_requested.emit()
	print("Restart requested")


func update_hud(
	level: int,
	tick: int,
	max_tick: int,
	echo_count: int
) -> void:
	level_label.text = "LEVEL %02d" % level
	tick_label.text = "TICK: %d/%d" % [tick, max_tick]
	echo_label.text = "ECHO: %d" % echo_count
