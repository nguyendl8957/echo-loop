extends CanvasLayer

signal move_requested(direction: Vector2i)
signal wait_requested
signal end_loop_requested
signal restart_requested

@onready var up_button = $HUDRoot/ControlsArea/UpButton
@onready var down_button = $HUDRoot/ControlsArea/DownButton
@onready var left_button = $HUDRoot/ControlsArea/LeftButton
@onready var right_button = $HUDRoot/ControlsArea/RightButton
@onready var wait_button = $HUDRoot/ControlsArea/WaitButton
@onready var end_loop_button = $HUDRoot/ControlsArea/EndLoopButton
@onready var restart_button = $HUDRoot/ControlsArea/RestartButton

@onready var level_label = $HUDRoot/TopBar/LevelLabel
@onready var tick_label = $HUDRoot/TopBar/TickLabel
@onready var echo_label = $HUDRoot/TopBar/EchoLabel

func _ready() -> void:
	up_button.pressed.connect(
		func(): _request_move(Vector2i.UP)
	)
	down_button.pressed.connect(
		func(): _request_move(Vector2i.DOWN)
	)
	left_button.pressed.connect(
		func(): _request_move(Vector2i.LEFT)
	)
	right_button.pressed.connect(
		func(): _request_move(Vector2i.RIGHT)
	)

	wait_button.pressed.connect(_on_wait_pressed)
	end_loop_button.pressed.connect(_on_end_loop_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

func _request_move(direction: Vector2i) -> void:
	move_requested.emit(direction)
	print("Move requested: ", direction)

func _on_wait_pressed() -> void:
	wait_requested.emit()
	print("Wait requested")

func _on_end_loop_pressed() -> void:
	end_loop_requested.emit()
	print("End loop requested")

func _on_restart_pressed() -> void:
	restart_requested.emit()
	print("Restart requested")

func update_hud(level: int, tick: int, max_tick: int, echo_count: int) -> void:
	level_label.text = "LEVEL %02d" % level
	tick_label.text = "TICK: %d/%d" % [tick, max_tick]
	echo_label.text = "ECHO: %d" % echo_count
