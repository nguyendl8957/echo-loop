
extends CanvasLayer

signal action_requested(action: String)
signal end_loop_requested
signal restart_requested

const OBJECTIVES := [
	"Stand on A, then choose END LOOP to record an Echo.",
	"Hold both plates to open the exit route.",
	"Use the first Echo to open a route to the second plate.",
	"Time the A-to-B handoff while C stays held.",
	"Relay to C, then time the handoff between A and B."
]

var level_name: String

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
@onready var loop_label: Label = $HUDRoot/TopBar/LoopLabel
@onready var objective: Label = $HUDRoot/TopBar/Objective


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


func set_level_name(value: String) -> void:
	level_name = value


func show_run_failed() -> void:
	objective.text = "All three loops used. Choose RESTART to try again."


func update_hud(
	level: int,
	tick: int,
	max_tick: int,
	echo_count: int
) -> void:
	level_label.text = "LEVEL %02d" % level
	if not level_name.is_empty():
		level_label.text += "  /  " + level_name
	objective.text = OBJECTIVES[level - 1] if level >= 1 and level <= OBJECTIVES.size() else ""
	if level == 1 and echo_count > 0:
		objective.text = "Let your Echo hold A while you head for the exit."
	tick_label.text = "TICK: %d/%d" % [tick, max_tick]
	echo_label.text = "ECHO: %d/2" % echo_count
	
func update_loop_status(loop_number: int, echo_count: int, is_finished: bool) -> void:
	loop_label.text = "LOOP: %d" % loop_number
	echo_label.text = "ECHO: %d/2" % echo_count
	set_input_locked(is_finished)



func set_input_locked(locked: bool) -> void:
	up_button.disabled = locked
	down_button.disabled = locked
	left_button.disabled = locked
	right_button.disabled = locked
	wait_button.disabled = locked
	end_loop_button.disabled = locked

	# Restart luon cho phep nguoi choi choi lai.
	restart_button.disabled = false
