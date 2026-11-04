extends Node2D
class_name PlayerController

const CELL_SIZE: int = 48

var grid_position: Vector2i = Vector2i.ZERO


func reset_position(start_cell: Vector2i) -> void:
	grid_position = start_cell
	_update_visual_position()


func apply_action(
	action: String,
	blocked_cells: Array[Vector2i]
) -> bool:
	var direction: Vector2i = Vector2i.ZERO

	match action:
		"UP":
			direction = Vector2i.UP
		"DOWN":
			direction = Vector2i.DOWN
		"LEFT":
			direction = Vector2i.LEFT
		"RIGHT":
			direction = Vector2i.RIGHT
		"WAIT":
			return false
		_:
			return false

	var target_cell: Vector2i = grid_position + direction

	if blocked_cells.has(target_cell):
		return false

	grid_position = target_cell
	_update_visual_position()
	return true


func _update_visual_position() -> void:
	position = (
		Vector2(grid_position) * CELL_SIZE
		+ Vector2.ONE * CELL_SIZE * 0.5
	)
