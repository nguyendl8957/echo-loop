extends Node


class_name TurnManager

signal tick_actions_requested(
	tick_number: int,
	player_action: String,
	echo_actions: PackedStringArray
)

signal tick_finished(tick_number: int)
signal input_rejected(action: String)

var time_loop: TimeLoopManager
var input_locked: bool = false


func setup(loop_manager: TimeLoopManager) -> void:
	time_loop = loop_manager
	input_locked = false


func submit_player_action(action: String) -> void:
	if input_locked or time_loop == null:
		return

	if not TimeLoopManager.VALID_ACTIONS.has(action):
		input_rejected.emit(action)
		return

	var tick_index: int = time_loop.get_tick_count()

	if tick_index >= TimeLoopManager.MAX_TICKS:
		return

	var echo_actions := time_loop.get_echo_actions(tick_index)

	if not time_loop.record_action(action):
		input_rejected.emit(action)
		return

	var tick_number: int = tick_index + 1

	tick_actions_requested.emit(
		tick_number,
		action,
		echo_actions
	)

	tick_finished.emit(tick_number)

	if tick_number >= time_loop.MAX_TICKS:
		end_current_loop()


func end_current_loop() -> void:
	if input_locked or time_loop == null:
		return

	if time_loop.is_finished:
		return

	var started_next_loop: bool = time_loop.end_loop()

	if not started_next_loop:
		input_locked = true


func restart_run() -> void:
	if time_loop == null:
		return

	input_locked = false
	time_loop.reset_run()
