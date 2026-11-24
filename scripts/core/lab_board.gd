extends Node2D

const CELL_SIZE := 48
const FLOOR := [
	preload("res://assets/sprites/environment/floor_panel.png"),
	preload("res://assets/sprites/environment/floor_circuit.png"),
	preload("res://assets/sprites/environment/floor_plain.png")
]
const EDGE := preload("res://assets/sprites/environment/wall_horizontal.png")
const SIDE := preload("res://assets/sprites/environment/wall_vertical.png")
const CORNERS := [
	preload("res://assets/sprites/environment/wall_corner_tl.png"),
	preload("res://assets/sprites/environment/wall_corner_tr.png"),
	preload("res://assets/sprites/environment/wall_corner_bl.png"),
	preload("res://assets/sprites/environment/wall_corner_br.png")
]
const ECHO_COLORS := [Color("#57d9ff"), Color("#b78aff")]
const SWITCH_COLORS := [Color("#5be0ff"), Color("#ca9aff"), Color("#ffd088")]

var level: LevelData
var trails: Array[Array] = []


func reset_trails() -> void:
	trails.clear()
	queue_redraw()


func record_trails(echoes: Array[EchoController]) -> void:
	for i in range(echoes.size()):
		if i == trails.size():
			trails.append([Vector2(level.player_start * CELL_SIZE) + Vector2(24, 29)])
		var point := Vector2(echoes[i].grid_position * CELL_SIZE) + Vector2(24, 29)
		var trail := trails[i]
		if trail.back() != point:
			trail.append(point)
			if trail.size() > 5:
				trail.pop_front()
	queue_redraw()


func _draw() -> void:
	if level == null:
		return

	var size := Vector2(level.grid_width, level.grid_height) * CELL_SIZE
	draw_rect(Rect2(Vector2(-11, -7), size + Vector2(22, 23)), Color("#060a16"))
	draw_rect(Rect2(Vector2(-7, -5), size + Vector2(14, 15)), Color("#1b3048"))
	draw_rect(Rect2(Vector2(-3, -2), size + Vector2(6, 6)), Color("#07111f"))

	for y in range(level.grid_height):
		for x in range(level.grid_width):
			var cell := Vector2i(x, y)
			var rect := Rect2(Vector2(cell * CELL_SIZE), Vector2(48, 48))
			var pattern := (x * 13 + y * 7 + x * y) % 11
			draw_rect(rect, Color("#16253a"))
			draw_texture_rect(FLOOR[0 if pattern < 8 else 1 if pattern < 10 else 2], rect, false, Color(0.82, 0.89, 0.98))
			draw_rect(rect.grow(-1), Color("#2b3c53"), false, 1)
			if level.wall_cells.has(cell):
				if x == 0 or y == 0 or x == level.grid_width - 1 or y == level.grid_height - 1:
					_draw_frame(cell, rect)
				else:
					_draw_bulkhead(cell, rect, pattern)

	_draw_pad(level.player_start, Color("#446176"))
	for i in range(level.switch_positions.size()):
		_draw_pad(level.switch_positions[i], SWITCH_COLORS[i % SWITCH_COLORS.size()])
	_draw_pad(level.exit_position, Color("#bd76ff"))
	var portal := Rect2(Vector2(level.exit_position * CELL_SIZE) + Vector2(7, 5), Vector2(34, 38))
	draw_rect(portal, Color("#27164b"))
	draw_rect(portal, Color("#a760ec"), false, 2)
	draw_rect(Rect2(portal.position + Vector2(7, 2), Vector2(20, 3)), Color("#e3b6ff"))

	for i in range(trails.size()):
		var trail := trails[i]
		var color: Color = ECHO_COLORS[i]
		for j in range(trail.size() - 1):
			var end: Vector2 = trail[j + 1]
			var point: Vector2 = trail[j]
			var alpha := 0.30 + j * 0.095
			draw_line(point, end, Color(color, alpha * 0.45), 2)
			draw_rect(Rect2(point - Vector2(3, 3), Vector2(6, 6)), Color(color, alpha))


func _draw_frame(cell: Vector2i, rect: Rect2) -> void:
	var bottom := cell.y == level.grid_height - 1
	var right := cell.x == level.grid_width - 1
	var horizontal := cell.y == 0 or bottom
	var vertical := cell.x == 0 or right
	var texture := EDGE if horizontal else SIDE
	if horizontal and vertical:
		texture = CORNERS[int(right) + 2 * int(bottom)]
		draw_rect(rect.grow(-2), Color("#32435b"))
	elif horizontal:
		draw_rect(Rect2(rect.position + Vector2(0, 7), Vector2(48, 34)), Color("#32435b"))
		draw_rect(Rect2(rect.position + Vector2(0, 8), Vector2(48, 3)), Color("#728098"))
		draw_rect(Rect2(rect.position + Vector2(0, 37), Vector2(48, 4)), Color("#141f35"))
	else:
		draw_rect(Rect2(rect.position + Vector2(7, 0), Vector2(34, 48)), Color("#32435b"))
		draw_rect(Rect2(rect.position + Vector2(8, 0), Vector2(3, 48)), Color("#728098"))
		draw_rect(Rect2(rect.position + Vector2(37, 0), Vector2(4, 48)), Color("#141f35"))
	draw_texture_rect(texture, rect, false, Color(1.35, 1.47, 1.60))


func _draw_bulkhead(cell: Vector2i, rect: Rect2, pattern: int) -> void:
	var pos := rect.position
	var adjacent := (
		level.wall_cells.has(cell + Vector2i.UP)
		or level.wall_cells.has(cell + Vector2i.DOWN)
		or level.wall_cells.has(cell + Vector2i.LEFT)
		or level.wall_cells.has(cell + Vector2i.RIGHT)
	)
	draw_rect(Rect2(pos + Vector2(2, 6), Vector2(44, 42)), Color("#0a1222"))
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(44, 38)), Color("#52627c"))
	draw_rect(Rect2(pos + Vector2(2, 38), Vector2(44, 6)), Color("#222e46"))
	draw_rect(Rect2(pos + Vector2(6, 6), Vector2(36, 28)), Color("#1f2b41"))
	draw_rect(Rect2(pos + Vector2(8, 8), Vector2(32, 22)), Color("#36465e"))
	for offset in [Vector2(3, 3), Vector2(42, 3), Vector2(3, 34), Vector2(42, 34)]:
		draw_rect(Rect2(pos + offset, Vector2(3, 3)), Color("#8396aa"))
	if adjacent and pattern % 4 != 0:
		for x in range(13, 38, 5):
			draw_rect(Rect2(pos + Vector2(x, 12), Vector2(3, 14)), Color("#141f30"))
	else:
		draw_rect(Rect2(pos + Vector2(11, 12), Vector2(26, 13)), Color("#4b5a71"), false, 1)
		draw_rect(Rect2(pos + Vector2(15, 38), Vector2(18, 2)), Color("#6de3fc"))


func _draw_pad(cell: Vector2i, color: Color) -> void:
	var origin := Vector2(cell * CELL_SIZE)
	draw_rect(Rect2(origin + Vector2(4, 4), Vector2(40, 40)), Color(color, 0.12))
	draw_rect(Rect2(origin + Vector2(3, 3), Vector2(42, 42)), Color(color, 0.62), false, 1)
