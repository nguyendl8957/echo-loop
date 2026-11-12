extends PlayerController
class_name EchoController

var _history := PackedStringArray()


func setup_echo(
	start_cell: Vector2i,
	history: PackedStringArray,
	tint: Color
) -> void:
	_history = history.duplicate()
	reset_position(start_cell)
	$Sprite2D.self_modulate = tint


func apply_echo_action(
	tick_index: int,
	blocked_cells: Array[Vector2i]
) -> bool:
	if tick_index < 0 or tick_index >= _history.size():
		return false

	return apply_action(_history[tick_index], blocked_cells)
