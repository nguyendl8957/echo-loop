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

### HUD Sprint 03 — Approved API

- `update_hud(level, tick, max_tick, echo_count)`:
  Cập nhật Level, Tick và số Echo theo định dạng x/2.
- `update_loop_status(loop_number, echo_count, is_finished)`:
  Cập nhật vòng hiện tại, số Echo và trạng thái khóa input.
- `set_input_locked(locked)`:
  Khóa/mở D-pad, WAIT và End Loop.
  Restart vẫn được phép sử dụng.

Core quyết định khi nào khóa hoặc mở input.
`is_finished = true` nghĩa là Gameplay tạm thời hoặc
vĩnh viễn không nhận action, không phải tự động báo thắng.
Sau khi chuyển sang vòng mới, Core phải mở khóa input.

---

## 12. Sprint 04 - Leader Integration Contract (Issue #21)

**Trang thai:** Da tich hop tren branch feature/EL-S04-L;
cho review PR va nghiem thu regression cuoi cung.
**Godot:** 4.7.2.
**Owner:** Leader.

### 12.1 LevelManager

Script: `res://scripts/core/level_manager.gd`

- `LevelManager.MIN_LEVEL = 1`
- `LevelManager.MAX_LEVEL = 5`
- `LevelManager.load_level(level_id: int) -> LevelData`

LevelManager nap LevelData tu:
`res://data/levels/level_01.tres` den `level_05.tres`.

Du lieu khong hop le hoac level nam ngoai 1-5
phai duoc tu choi, khong tu tao level moi.

### 12.2 GameManager

Autoload: `GameManager`.

Public API duoc Gameplay/UI su dung:

- `start_new_game() -> void`
- `open_gameplay() -> void`
- `back_to_menu() -> void`
- `complete_level() -> void`
- `get_unlocked_level() -> int`
- `can_play_level(level_id: int) -> bool`
- `select_level(level_id: int) -> bool`
- `open_level_select() -> void`

GameManager giu `current_level` va dieu huong scene.
`complete_level()` chi xu ly mot lan cho moi lan choi
va cap nhat `unlocked_level` qua SaveManager.

So level mo khoa duoc gioi han trong khoang 1-5.
Thang Level 05 khong duoc mo khoa Level 06.

### 12.3 Level Select - TV4

Scene: `res://scenes/ui/level_select.tscn`
Script: `res://scripts/ui/level_select.gd`

Signals:
- `level_selected(level_id: int)`
- `back_requested`

Method:
- `set_unlocked_levels(unlocked_count: int) -> void`

GameManager ket noi signal va ap dung quyen truy cap.
Level Select khong tu thay doi Save.

### 12.4 Level Complete - TV4

Scene: `res://scenes/ui/level_complete.tscn`

Signals:
- `result_next_requested`
- `result_replay_requested`
- `result_level_select_requested`

Method:
- `set_completed_level(level_id: int) -> void`

Gameplay hien Level Complete khi Player den Exit.
Next khong tu dong chay; phai co yeu cau cua nguoi choi.
Tai Level 05, nut Next bi vo hieu hoa.

### 12.5 Pause Menu - TV4

Scene: `res://scenes/ui/pause_menu.tscn`

Signals:
- `pause_resume_requested`
- `pause_restart_requested`
- `pause_menu_requested`

Gameplay dieu khien trang thai Pause.
Trong khi Pause, khong ghi action va khong ket thuc loop.
Resume khong tu tang tick.
Restart nap lai current level, xoa run va Echo cu.
Menu quay ve Main Menu.

Co che hien tai khoa input gameplay;
khong su dung `SceneTree.paused` de dung toan bo scene.

### 12.6 SaveManager - TV5

Script: `res://scripts/data/save_manager.gd`

Core tao instance tu script preload,
khong them SaveManager vao Autoload.

Du lieu luu:
- `unlocked_level`
- `sound_enabled`

Khong luu tick, vi tri Player, Echo histories
hoac trang thai dang choi do.

### 12.7 Gameplay invariant

- Moi Time Loop co 12 tick.
- Toi da 2 Echo.
- Action bi chan va WAIT van tieu ton tick.
- End Loop som dem WAIT.
- Moi actor dung door snapshot dau tick.
- Player va Echo di chuyen truoc khi cap nhat switch/door.
- Chi Player hien tai duoc kich hoat Exit.
- Player va Echo co the trung o.

### 12.8 Dieu kien nghiem thu

- Level 01-05 nap dung Resource.
- Level Select ton trong unlocked_level.
- Next / Replay / Level Select hoat dong.
- Pause khong lam tang tick.
- Restart xoa Echo run hien tai.
- Save ton tai sau khi khoi dong lai game.
- Level 05 khong mo khoa Level 06.
- F6 regression khong co FAIL.
- F5 qua it nhat hai man lien tiep khong crash.

Ket qua test, anh chup va cac han che con lai
can ghi trong PR Issue #21.
