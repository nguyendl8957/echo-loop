extends PlayerController
class_name EchoController

var _history := PackedStringArray()
var _glow := Color.TRANSPARENT


func setup_echo(
	start_cell: Vector2i,
	history: PackedStringArray,
	tint: Color
) -> void:
	_history = history.duplicate()
	reset_position(start_cell)
	$Sprite2D.self_modulate = tint
	_glow = Color("#ab83ff") if tint.r > 1.0 else Color("#72d7ff")
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0, 5), 17, Color(_glow, 0.12))
	draw_arc(Vector2(0, 5), 18, 0, TAU, 28, Color(_glow, 0.75), 1.5, true)


func apply_echo_action(
	tick_index: int,
	blocked_cells: Array[Vector2i]
) -> bool:
	if tick_index < 0 or tick_index >= _history.size():
		return false

	return apply_action(_history[tick_index], blocked_cells)
