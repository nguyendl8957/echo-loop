extends Node


class_name TimeLoopManager

signal loop_started(echo_count: int)
signal loop_finished(loop_number: int)
signal run_failed

const MAX_TICKS: int = 12
const MAX_ECHOES: int = 2

const VALID_ACTIONS: Array[String] = [
	"UP", "DOWN", "LEFT", "RIGHT", "WAIT"
]

var loop_number: int = 1
var current_actions: PackedStringArray = PackedStringArray()
var echo_histories: Array[PackedStringArray] = []
var is_finished: bool = false


func reset_run() -> void:
	loop_number = 1
	current_actions.clear()
	echo_histories.clear()
	is_finished = false
	loop_started.emit(0)


func record_action(action: String) -> bool:
	if is_finished:
		return false

	if not VALID_ACTIONS.has(action):
		return false

	if current_actions.size() >= MAX_TICKS:
		return false

	current_actions.append(action)
	return true


func get_echo_actions(tick_index: int) -> PackedStringArray:
	var result := PackedStringArray()

	for history in echo_histories:
		if tick_index >= 0 and tick_index < history.size():
			result.append(history[tick_index])
		else:
			result.append("WAIT")

	return result


func get_tick_count() -> int:
	return current_actions.size()


func get_echo_count() -> int:
	return echo_histories.size()


func end_loop() -> bool:
	if is_finished:
		return false

	while current_actions.size() < MAX_TICKS:
		current_actions.append("WAIT")

	loop_finished.emit(loop_number)

	if loop_number >= MAX_ECHOES + 1:
		is_finished = true
		run_failed.emit()
		return false

	echo_histories.append(current_actions.duplicate())
	loop_number += 1
	current_actions.clear()

	loop_started.emit(get_echo_count())
	return true
