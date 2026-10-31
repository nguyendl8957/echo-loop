class_name Door
extends Node2D

## Signal phát ra khi trạng thái đóng/mở của cửa thay đổi
signal state_changed(is_open: bool)

## Hằng số kích thước ô lưới chuẩn theo AGENTS.md
const CELL_SIZE: int = 48

## Màu sắc hiển thị theo visual spec (AGENTS.md mục 3.3)
const COLOR_CLOSED: Color = Color(0.95, 0.2, 0.2, 1.0)       # Đỏ khóa khi cửa đóng
const COLOR_OPEN: Color = Color(0.2, 0.9, 0.9, 0.35)         # Cyan / Xanh ngọc mờ khi cửa mở

## Tọa độ logic trên bản đồ lưới (Vector2i)
@export var grid_position: Vector2i = Vector2i.ZERO:
	set(value):
		grid_position = value
		update_visual_position()

## Danh sách các công tắc áp lực liên kết với cửa này (1 hoặc 2 công tắc theo Issue #2)
@export var linked_switches: Array[PressureSwitch] = []

## Trạng thái mở cửa hiện tại
var is_open: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	# Khởi tạo placeholder texture nếu chưa gán sprite để hiển thị rõ ràng trên màn hình
	_ensure_placeholder_texture()
	update_visual_position()
	_update_visual_state()


## Đồng bộ vị trí pixel trên màn hình theo công thức chuẩn trong AGENTS.md mục 6:
## world_pos = Vector2(grid_pos * CELL_SIZE) + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
func update_visual_position() -> void:
	position = Vector2(grid_position * CELL_SIZE) + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)


## Tính toán lại trạng thái cửa dựa trên các công tắc liên kết
## Cửa MỞ khi TẤT CẢ công tắc liên kết đang ở trạng thái active = true
## Cửa ĐÓNG ngay khi có ít nhất 1 công tắc chưa kích hoạt (hoặc không có công tắc liên kết)
func evaluate_state() -> bool:
	var should_be_open: bool = false

	if not linked_switches.is_empty():
		should_be_open = true
		for sw in linked_switches:
			if sw == null or not sw.is_active:
				should_be_open = false
				break

	var state_has_changed: bool = (is_open != should_be_open)
	is_open = should_be_open

	if state_has_changed:
		_update_visual_state()
		state_changed.emit(is_open)

	return is_open


## Kiểm tra nhân vật có thể bước vào ô cửa này hay không
## Theo AGENTS.md mục 2.5: Cửa mở thì cho phép bước vào, cửa đóng thì chặn
func can_enter() -> bool:
	return is_open


## Kiểm tra cửa có đang cản đường bước vào hay không
func is_blocking() -> bool:
	return not is_open


## Đặt lại trạng thái cửa về ban đầu (đóng)
func reset_state() -> void:
	if is_open != false:
		is_open = false
		_update_visual_state()
		state_changed.emit(is_open)


## Cập nhật màu sắc theo trạng thái open/closed
func _update_visual_state() -> void:
	if sprite_2d != null:
		sprite_2d.modulate = COLOR_OPEN if is_open else COLOR_CLOSED


## Tạo texture tạm thời dạng ô vuông 36x36 nếu Sprite2D chưa có ảnh
func _ensure_placeholder_texture() -> void:
	if sprite_2d != null and sprite_2d.texture == null:
		var img: Image = Image.create(36, 36, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite_2d.texture = ImageTexture.create_from_image(img)
