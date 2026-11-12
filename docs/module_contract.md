# Echo Loop — Module Integration Contract

**Phiên bản:** 0.1 — Sprint 02  
**Phụ trách:** Leader — Game Core & Integration  
**Phạm vi:** Level 01 không Echo, Godot 4.7.2, GDScript  
**Trạng thái:** Chờ kiểm thử tích hợp và nghiệm thu

## 1. Quy tắc gameplay bất biến

- Mỗi Time Loop có tối đa 12 tick.
- Tối đa 2 Echo được tạo từ lịch sử các vòng trước.
- Các action hợp lệ: `UP`, `DOWN`, `LEFT`, `RIGHT`, `WAIT`.
- `WAIT` và hành động di chuyển bị chặn đều tiêu tốn một tick.
- Kết thúc vòng sớm phải đệm các action còn thiếu bằng `WAIT`.
- Trạng thái cửa được chụp tại đầu tick; mọi actor sử dụng cùng trạng thái đó để kiểm tra di chuyển.
- Sau khi tất cả actor di chuyển mới cập nhật switch, door và điều kiện thắng.
- Chỉ Player hiện tại được kích hoạt chiến thắng tại Exit.
- Player và Echo có thể đứng trên cùng một ô.
- Sprint 02 chưa tạo hoặc phát lại Echo. Phần gameplay này được tích hợp ở Sprint 03.

## 2. Quy ước lưới

- Kiểu tọa độ logic: `Vector2i`.
- Kích thước một ô: `48 × 48` pixel.
- Gốc tọa độ `(0, 0)` nằm ở góc trên bên trái bản đồ.
- Tọa độ tăng sang phải theo trục X, xuống dưới theo trục Y.
- Tâm hiển thị của ô `(x, y)` là `Vector2(x * 48 + 24, y * 48 + 24)`.
- Một ô hợp lệ phải thỏa `0 <= x < grid_width` và `0 <= y < grid_height`.

Core chịu trách nhiệm cung cấp danh sách ô bị chặn cho Player, bao gồm tường, biên bản đồ và cửa đóng theo snapshot đầu tick.

## 3. LevelData — hợp đồng dữ liệu màn chơi

**Script:** `res://scripts/core/level_data.gd`  
**Class:** `LevelData extends Resource`  
**Owner:** Leader

Các thuộc tính:

| Thuộc tính | Kiểu dữ liệu | Ý nghĩa |
|---|---|---|
| `level_id` | `int` | Mã màn chơi |
| `level_name` | `String` | Tên màn chơi |
| `grid_width` | `int` | Chiều rộng theo ô |
| `grid_height` | `int` | Chiều cao theo ô |
| `player_start` | `Vector2i` | Vị trí Player ban đầu |
| `exit_position` | `Vector2i` | Vị trí Exit |
| `wall_cells` | `Array[Vector2i]` | Các ô tường |
| `switch_positions` | `Array[Vector2i]` | Vị trí công tắc |
| `door_configs` | `Array[Dictionary]` | Dữ liệu cấu hình cửa |

Các phương thức đã định nghĩa trong script Sprint 02:

- `is_in_bounds(cell: Vector2i) -> bool`
- `validate_level() -> PackedStringArray`

`validate_level()` hiện kiểm tra các điều kiện dữ liệu cơ bản như kích thước, tọa độ Start/Exit, tường và vị trí công tắc. Chưa được coi là bộ kiểm tra đầy đủ cho `door_configs`.

**Quy ước ownership:**

- Leader tạo và duy trì schema `level_data.gd`.
- TV3 tạo và duy trì `res://data/levels/level_01.tres`.
- TV3 không tự đổi tên hoặc kiểu thuộc tính schema.
- Leader không tự sửa dữ liệu Level 01 thuộc TV3.

**Lưu ý:** Cấu trúc từng Dictionary trong `door_configs` chưa được phê duyệt. Trước khi thêm cửa vào dữ liệu màn chơi, Leader và TV3 phải thống nhất các khóa, kiểu dữ liệu và cách ánh xạ cửa–công tắc. Không tự giả định định dạng.

## 4. Player Controller — API hiện có

**Script:** `res://scripts/player/player_controller.gd`  
**Scene:** `res://scenes/player/player.tscn`  
**Class:** `PlayerController`  
**Owner:** TV2

Phương thức:

- `reset_position(start_cell: Vector2i) -> void`
- `apply_action(action: String, blocked_cells: Array[Vector2i]) -> bool`

Quy ước:

- `grid_position` lưu vị trí logic.
- `apply_action()` chỉ xử lý vị trí Player.
- Kết quả `true` nghĩa là Player đã đổi ô.
- Kết quả `false` nghĩa là Player không đổi ô; có thể do `WAIT`, ô bị chặn hoặc action không hợp lệ.
- Core phải phân biệt action hợp lệ và không hợp lệ trước khi gọi Player.
- Player không tự quản lý tick, Echo hoặc trạng thái cửa.

## 5. Puzzle — API hiện có

**PressureSwitch**

Script: `res://scripts/puzzle/pressure_switch.gd`

- `grid_position: Vector2i`
- `is_active: bool`
- `update_state(actor_positions: Array[Vector2i]) -> bool`
- `reset_state() -> void`

Công tắc kích hoạt khi có ít nhất một actor đứng trên ô của nó.

**Door**

Script: `res://scripts/puzzle/door.gd`

- `grid_position: Vector2i`
- `linked_switches: Array[PressureSwitch]`
- `is_open: bool`
- `evaluate_state() -> bool`
- `can_enter() -> bool`
- `is_blocking() -> bool`
- `reset_state() -> void`

Cửa mở khi tất cả công tắc liên kết đang kích hoạt; cửa không có công tắc liên kết mặc định đóng.

Việc kiểm tra đường đi trong tick phải sử dụng trạng thái cửa đã chụp ở đầu tick, không sử dụng trạng thái vừa được cập nhật trong cùng tick.

**ExitPortal — API dự kiến từ PR #34**

- Scene: `res://scenes/puzzle/exit_portal.tscn`
- Script: `res://scripts/puzzle/exit_portal.gd`
- `is_at(cell: Vector2i) -> bool`
- `check_player_reached(player_grid_pos: Vector2i) -> bool`
- Signal: `player_entered(grid_pos: Vector2i)`

Các API ExitPortal chỉ được xem là chính thức sau khi PR #34 được review, kiểm thử và merge.

## 6. HUD — API hiện có

**Script:** `res://scripts/ui/hud.gd`  
**Scene:** `res://scenes/ui/hud.tscn`  
**Owner:** TV4

Signals:

- `action_requested(action: String)`
- `end_loop_requested`
- `restart_requested`

Phương thức:

`update_hud(level: int, tick: int, max_tick: int, echo_count: int) -> void`

Quy tắc:

- HUD chỉ phát yêu cầu thao tác và hiển thị dữ liệu.
- Game Core tiếp nhận signal, kiểm tra điều kiện và xử lý action.
- HUD không trực tiếp gọi Player hoặc tăng tick.
- Trong Gameplay Sprint 02, số Echo hiển thị là `0`.
- Việc sử dụng nút End Loop trong màn chưa tích hợp Echo phải được Leader kiểm soát, không để tự tạo Echo ngoài phạm vi Sprint 02.

## 7. Game Core và Time Loop

**GameManager**

`res://scripts/core/game_manager.gd`

Đang được khai báo Autoload trong `project.godot`.

**TurnManager**

`res://scripts/core/turn_manager.gd`

- `setup(loop_manager: TimeLoopManager) -> void`
- `submit_player_action(action: String) -> void`
- `end_current_loop() -> void`
- `restart_run() -> void`

Signals:

- `tick_actions_requested(...)`
- `tick_finished(tick_number: int)`
- `input_rejected(action: String)`

**TimeLoopManager**

`res://scripts/timeloop/time_loop_manager.gd`

- `MAX_TICKS = 12`
- `MAX_ECHOES = 2`

Game Core phải đảm bảo mô phỏng thế giới hoàn tất trước khi HUD và các hệ thống phụ thuộc nhận thông báo tick đã xử lý xong. Việc thay đổi giao thức `tick_finished` phải được kiểm thử, không chỉnh sửa chỉ dựa trên giả định về signal.

## 8. Thứ tự xử lý một tick

1. Ghi nhận trạng thái cửa tại đầu tick.
2. Thu thập và kiểm tra action hợp lệ của các actor hiện hành.
3. Xác định các ô có thể di chuyển theo snapshot cửa.
4. Áp dụng di chuyển.
5. Cập nhật trạng thái công tắc từ vị trí actor.
6. Tính lại trạng thái cửa.
7. Kiểm tra chiến thắng của Player.
8. Hoàn tất tick và đồng bộ HUD.

Ở Sprint 02 chỉ có Player. Giao thức vẫn phải cho phép bổ sung Echo trong Sprint 03 mà không thay đổi luật xử lý.

## 9. SaveManager — API hiện có

**Script:** `res://scripts/data/save_manager.gd`  
**Owner:** TV5

`SaveManager` hiện kế thừa `RefCounted`, không phải Autoload và không khai báo `class_name`.

Core phải nạp script trước khi khởi tạo instance, ví dụ thông qua `preload()`.

Các phương thức:

- `load_progress() -> Dictionary`
- `save_progress(data: Dictionary) -> bool`
- `reset_progress() -> bool`

Dữ liệu lưu:

- `unlocked_level`
- `sound_enabled`

Không lưu tick, lịch sử Echo, vị trí Player hoặc trạng thái đang chơi dở.

## 10. Phân chia trách nhiệm tích hợp

| Thành viên | Phạm vi chính |
|---|---|
| Leader | `scripts/core/`, `scripts/timeloop/`, Gameplay scene, hợp đồng module |
| TV2 | `scripts/player/`, `scenes/player/` |
| TV3 | `scripts/puzzle/`, `scenes/puzzle/`, `data/levels/` |
| TV4 | `scripts/ui/`, `scenes/ui/` |
| TV5 | `scripts/data/`, `assets/audio/`, tài liệu QA/test được phân công |

Các thay đổi trên file dùng chung cần được Leader thống nhất trước. Mỗi PR chỉ chỉnh sửa các file thuộc phạm vi Issue.

## 11. Điều kiện nghiệm thu Sprint 02

- Resource Level 01 nạp được bằng hệ thống Resource của Godot.
- Main Menu mở được Gameplay Level 01.
- Player di chuyển đúng trên lưới 48px.
- `WAIT` và hành động bị chặn tiêu tốn đúng một tick.
- Tường, biên bản đồ và cửa đóng chặn đúng theo logic.
- Trạng thái switch/door được cập nhật sau khi di chuyển.
- Player đến Exit được xác nhận thắng.
- HUD cập nhật Level, Tick và Echo đúng.
- Restart đưa các thành phần về trạng thái ban đầu.
- SaveManager không làm mất tùy chọn âm thanh khi cập nhật tiến trình.
- Các module không gây lỗi khi chạy F6/F5.

**Ghi chú kiểm thử:** Level 01 trong PR #34 hiện chưa chứa switch và door. Vì vậy kiểm thử cửa/công tắc cần fixture độc lập hoặc dữ liệu Level 01 được TV3 điều chỉnh theo yêu cầu nghiệm thu. Không được coi riêng đường giải Level 01 là bằng chứng đã kiểm tra logic cửa.

**Trạng thái nghiệm thu:** Chưa xác nhận PASS. Chỉ cập nhật sau khi Leader kiểm thử trên code và commit thực tế.