class_name ExitPortal
extends Node2D

## Signal phát ra khi Player bước lên ô cổng thoát hiểm
signal player_entered(grid_pos: Vector2i)

## Hằng số kích thước ô lưới chuẩn theo AGENTS.md
const CELL_SIZE: int = 48

## Màu sắc hiển thị fallback theo visual spec (AGENTS.md mục 3.3 - Tím xoáy năng lượng nổi bật)
const COLOR_PORTAL: Color = Color(0.75, 0.2, 0.9, 1.0)

## Đường dẫn sprite chuẩn bàn giao từ TV2 (Issue #42 / #22)
const TEXTURE_PORTAL_PATH: String = "res://assets/sprites/objects/exit_portal.png"

## Tọa độ logic trên bản đồ lưới (Vector2i)
@export var grid_position: Vector2i = Vector2i.ZERO:
	set(value):
		grid_position = value
		update_visual_position()

var _texture_portal: Texture2D = null

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	_load_textures()
	update_visual_position()
	_update_visual_state()


## Nạp texture thật từ assets/sprites/objects/ (nếu có), ngược lại dùng placeholder
func _load_textures() -> void:
	if ResourceLoader.exists(TEXTURE_PORTAL_PATH):
		_texture_portal = ResourceLoader.load(TEXTURE_PORTAL_PATH) as Texture2D
	if _texture_portal == null:
		_ensure_placeholder_texture()


## Cập nhật texture hoặc màu sắc hiển thị
func _update_visual_state() -> void:
	if sprite_2d == null:
		return
	if _texture_portal == null:
		_load_textures()
	sprite_2d.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if _texture_portal != null:
		sprite_2d.texture = _texture_portal
		sprite_2d.modulate = Color.WHITE
	else:
		_ensure_placeholder_texture()
		sprite_2d.modulate = COLOR_PORTAL


## Đồng bộ vị trí pixel trên màn hình theo công thức chuẩn trong AGENTS.md mục 6:
## world_pos = Vector2(grid_pos * CELL_SIZE) + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
func update_visual_position() -> void:
	position = Vector2(grid_position * CELL_SIZE) + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)


## Kiểm tra tọa độ ô truyền vào có trùng với ô cổng thoát hiểm hay không
func is_at(cell: Vector2i) -> bool:
	return grid_position == cell


## Kiểm tra nhân vật Player có bước lên ô thoát hiểm hay không
## Nếu có, phát signal player_entered và trả về true để Core xử lý thắng màn
func check_player_reached(player_grid_pos: Vector2i) -> bool:
	if is_at(player_grid_pos):
		player_entered.emit(grid_position)
		return true
	return false


## Tạo texture tạm thời dạng ô vuông 36x36 nếu Sprite2D chưa có ảnh
func _ensure_placeholder_texture() -> void:
	if sprite_2d != null and sprite_2d.texture == null:
		var img: Image = Image.create(36, 36, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite_2d.texture = ImageTexture.create_from_image(img)
