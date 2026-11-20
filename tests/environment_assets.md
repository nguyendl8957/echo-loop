# Bàn giao asset môi trường S04 — Issue #42

## Phạm vi

Bộ ảnh môi trường phòng thí nghiệm sci-fi, phong cách pixel art
top-down, tông navy, cyan và tím.

Scene preview:
res://scenes/tests/environment_visual_test.tscn

Scene chỉ trưng bày hình ảnh, không triển khai logic Puzzle.

## Danh sách asset môi trường

Thư mục: res://assets/sprites/environment/

| File | Công dụng |
|---|---|
| floor_plain.png | Sàn cơ bản |
| floor_panel.png | Sàn tấm kim loại |
| floor_circuit.png | Sàn trang trí mạch điện |
| wall_horizontal.png | Tường ngang |
| wall_vertical.png | Mẫu tường dọc ban đầu |
| wall_corner_tl.png | Góc trên trái |
| wall_corner_tr.png | Góc trên phải |
| wall_corner_bl.png | Góc dưới trái |
| wall_corner_br.png | Góc dưới phải |

Trong preview hiện tại, tường dọc dùng wall_horizontal.png
xoay 90 độ để đồng nhất với tường ngang.
wall_vertical.png không được dùng trong preview hiện tại.

Bốn ảnh góc sử dụng bản đã sửa để khớp đoạn tường thẳng.

## Danh sách asset Puzzle

Thư mục: res://assets/sprites/objects/

| File | Công dụng |
|---|---|
| switch_off.png | PressureSwitch chưa kích hoạt |
| switch_on.png | PressureSwitch đã kích hoạt |
| door_closed.png | Door đóng |
| door_open.png | Door mở |
| exit_portal.png | Cổng thoát |

## Cách sử dụng

PNG có kích thước 48 × 48 px.
Grid gameplay giữ nguyên 48 × 48 px mỗi ô.

Thiết lập Sprite2D:
Scale: (1, 1).
Centered: On.
Offset: (0, 0).
Texture Filter: Nearest.

Bốn góc tường dùng Rotation = 0 độ.
Tường ngang dùng Rotation = 0 độ.
Tường dọc trong preview dùng wall_horizontal.png,
Rotation = 90 độ.

Với tọa độ ô (x, y), tâm sprite là:
Position = (x * 48 + 24, y * 48 + 24).

Sàn trong preview có Z Index = -10.
Objects và Walls có Z Index = 0.

## Nguồn hình ảnh

Ảnh được tạo bằng ChatGPT/OpenAI cho dự án Echo Loop,
tham chiếu mockup nhóm và quy chuẩn vật thể Puzzle
do TV3 cung cấp.

Ảnh được thu nhỏ về 48 × 48 px.
Các góc tường được xử lý để khớp đoạn tường thẳng.
Không sử dụng gói asset tải từ bên thứ ba.
Không gán giấy phép CC0 cho bộ ảnh này.
Thông tin điều kiện sử dụng cần được Leader xác nhận
khi duyệt asset.

## Trạng thái kiểm tra

Đã dựng preview có sàn, tường và đủ 5 vật thể Puzzle.

F6 preview: đã chạy thực tế trên Godot 4.7.2 ở 1280 × 720.
Quan sát: đủ 3 mẫu sàn, viền tường nối kín, đủ 5 vật thể.
Phân biệt được Switch OFF/ON và Door CLOSED/OPEN.
ExitPortal hiển thị rõ trên nền sàn.
Khả năng phân biệt Player/Echo trên nền mới: chờ kiểm tra.
Puzzle Test sau tích hợp: chưa kiểm thử.
Gameplay F5 sau tích hợp: chưa kiểm thử.
Android thực tế: chưa kiểm thử.

## Bàn giao

TV3 tích hợp ảnh Objects vào các scene Puzzle và kiểm tra
trạng thái Switch, Door, Exit.

Leader tích hợp Floor/Wall vào Gameplay, review chất lượng
hình ảnh và phối hợp kiểm thử F5.

TV2 cung cấp ảnh và scene preview.
Chưa xác nhận TV3 và Leader đã nhận bàn giao.