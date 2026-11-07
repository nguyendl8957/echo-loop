class_name PressureSwitch
extends Node2D

## Signal phát ra khi trạng thái kích hoạt của công tắc thay đổi
signal state_changed(is_active: bool)

## Hằng số kích thước ô lưới chuẩn theo AGENTS.md
const CELL_SIZE: int = 48

## Màu sắc hiển thị theo visual spec (AGENTS.md mục 3.3)
const COLOR_INACTIVE: Color = Color(0.95, 0.75, 0.1, 1.0) # Vàng / Cam khi chưa kích hoạt
const COLOR_ACTIVE: Color = Color(0.2, 0.95, 0.4, 1.0)   # Xanh lá / Cyan khi có người đứng lên

## Tọa độ logic trên bản đồ lưới (Vector2i)
@export var grid_position: Vector2i = Vector2i.ZERO:
	set(value):
		grid_position = value
		update_visual_position()

## Trạng thái kích hoạt hiện tại
var is_active: bool = false

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


## Cập nhật trạng thái công tắc dựa trên danh sách tọa độ của Player và Echo
## Công tắc active = true nếu có ÍT NHẤT 1 nhân vật đứng trên ô này
func update_state(actor_positions: Array[Vector2i]) -> bool:
	var has_actor_on_switch: bool = actor_positions.has(grid_position)
	var state_has_changed: bool = (is_active != has_actor_on_switch)

	is_active = has_actor_on_switch

	if state_has_changed:
		_update_visual_state()
		state_changed.emit(is_active)

	return is_active


## Đặt lại trạng thái công tắc về ban đầu (dùng khi World Reset / Restart / New Loop)
func reset_state() -> void:
	if is_active != false:
		is_active = false
		_update_visual_state()
		state_changed.emit(is_active)


## Cập nhật màu sắc theo trạng thái active/inactive
func _update_visual_state() -> void:
	if sprite_2d != null:
		sprite_2d.modulate = COLOR_ACTIVE if is_active else COLOR_INACTIVE


## Tạo texture tạm thời dạng ô vuông 32x32 nếu Sprite2D chưa có ảnh
func _ensure_placeholder_texture() -> void:
	if sprite_2d != null and sprite_2d.texture == null:
		var img: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite_2d.texture = ImageTexture.create_from_image(img)
