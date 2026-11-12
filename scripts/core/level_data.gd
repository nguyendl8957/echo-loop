extends Resource
class_name LevelData

## Thông tin cơ bản của màn chơi.
@export var level_id: int = 1
@export var level_name: String = "Unnamed Level"

## Kích thước bản đồ tính theo số ô.
@export var grid_width: int = 7
@export var grid_height: int = 5

## Tọa độ bắt đầu và đích của Player.
@export var player_start: Vector2i = Vector2i(1, 2)
@export var exit_position: Vector2i = Vector2i(5, 2)

## Các ô tường không thể đi vào.
@export var wall_cells: Array[Vector2i] = []

## Vị trí các công tắc áp lực.
@export var switch_positions: Array[Vector2i] = []

## Cấu hình cửa, liên kết tới công tắc bằng chỉ số.
@export var door_configs: Array[Dictionary] = []


## Kiểm tra một ô có nằm trong giới hạn bản đồ.
func is_in_bounds(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.x < grid_width
		and cell.y >= 0
		and cell.y < grid_height
	)


## Trả về các lỗi dữ liệu cơ bản của màn chơi.
## Mảng rỗng nghĩa là các kiểm tra này đã đạt.
func validate_level() -> PackedStringArray:
	var errors := PackedStringArray()

	if level_id < 1:
		errors.append("level_id must be >= 1")

	if grid_width <= 0 or grid_height <= 0:
		errors.append("Invalid grid dimensions")
		return errors

	if not is_in_bounds(player_start):
		errors.append("Player start is out of bounds")

	if not is_in_bounds(exit_position):
		errors.append("Exit position is out of bounds")

	if wall_cells.has(player_start):
		errors.append("Player start overlaps a wall")

	if wall_cells.has(exit_position):
		errors.append("Exit position overlaps a wall")

	for cell in wall_cells:
		if not is_in_bounds(cell):
			errors.append("Wall out of bounds: " + str(cell))

	for cell in switch_positions:
		if not is_in_bounds(cell):
			errors.append("Switch out of bounds: " + str(cell))

	return errors
