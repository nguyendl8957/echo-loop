# Level 02–05 — Solution Record & Validation Proofs (S04-TV3)

**Issue:** #23  
**Owner:** TV3 (Gia Huy)  
**Source baseline:** `main` (commit `58aa072` - tích hợp đầy đủ Sprint 03)  
**Status:** `VERIFIED & PASSED` (F6 test runner: 134/134 assertions passed, 0 failed)  

---

## 1. Tổng quan Kiến trúc Màn chơi (Core MVP Levels 02–05)

Bộ 4 màn chơi cốt lõi được thiết kế theo lộ trình sư phạm (progressive learning curve), dần dần giới thiệu toàn bộ các cơ chế bất biến của **Echo Loop**:
* **Level 02 ("Hold the Door"):** Dạy cơ chế bản sao giữ công tắc áp lực để mở cửa năng lượng cho Player hiện tại bước qua.
* **Level 03 ("Echo Memory"):** Dạy cơ chế đồng bộ thời gian (Timing / Synchronization). Bản sao chỉ kích hoạt công tắc ở đúng nhịp tick nhất định; Player phải căn nhịp di chuyển và `WAIT` để qua cửa đúng lúc.
* **Level 04 ("Two Paths"):** Dạy cơ chế phối hợp hai tuyến đường khác nhau (Bắc và Nam) giữa quá khứ và hiện tại.
* **Level 05 ("Double Echo"):** Đỉnh cao giải đố MVP: Phối hợp 2 bản sao cùng lúc để kích hoạt 2 công tắc áp lực (AND logic), mở cửa an ninh cho Player hiện tại về đích.

---

## 2. Level 02 — "Hold the Door"

### 2.1. Cấu hình Dữ liệu (`res://data/levels/level_02.tres`)
* **Kích thước bản đồ:** $7 \times 5$ ô (`grid_width = 7`, `grid_height = 5`).
* **Vị trí xuất phát (`player_start`):** `Vector2i(1, 2)`.
* **Vị trí đích (`exit_position`):** `Vector2i(5, 2)`.
* **Công tắc áp lực (`switch_positions`):** `[Vector2i(2, 1)]` (Switch 0).
* **Cửa năng lượng (`door_configs`):** `[{"position": Vector2i(4, 2), "switch_indices": [0]}]`.
* **Tường chướng ngại vật (`wall_cells`):** Viền ngoài bản đồ và hàng rào ngăn tại cột 4 (`Vector2i(4, 1)`, `Vector2i(4, 3)`), cô lập ô đích `(5, 2)` sau cửa `(4, 2)`.

### 2.2. Lời giải chi tiết theo từng Vòng & Tick

#### Vòng 1 (Ghi chuỗi hành động cho Echo 1)
| Tick | Lệnh Player | Vị trí Player | Switch 0 | Trạng thái Door (cuối tick) | Ghi chú |
|:---:|:---|:---:|:---:|:---:|:---|
| Start | — | `(1, 2)` | Inactive | Closed | Bắt đầu vòng |
| 1 | `UP` | `(1, 1)` | Inactive | Closed | Di chuyển lên |
| 2 | `RIGHT` | `(2, 1)` | **ACTIVE** | **OPEN** | Đạp lên Switch 0; cửa mở |
| 3–12 | `WAIT` (hoặc End Loop) | `(2, 1)` | **ACTIVE** | **OPEN** | Giữ công tắc cho đến hết vòng |

#### Vòng 2 (Player hiện tại phối hợp cùng Echo 1)
| Tick | Lệnh Player | Lệnh Echo 1 | Vị trí Player | Vị trí Echo 1 | Door Snapshot (đầu tick) | Door (cuối tick) | Kết quả |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---|
| Start | — | — | `(1, 2)` | `(1, 2)` | Closed | Closed | Cả hai ở vạch xuất phát |
| 1 | `RIGHT` | `UP` | `(2, 2)` | `(1, 1)` | Closed | Closed | Player tiến về hành lang, Echo lên phía trên |
| 2 | `RIGHT` | `RIGHT` | `(3, 2)` | `(2, 1)` | Closed | **OPEN** | Echo đạp Switch 0; cuối tick cửa `(4, 2)` mở |
| 3 | `RIGHT` | `WAIT` | `(4, 2)` | `(2, 1)` | **OPEN** | **OPEN** | Snapshot đầu tick mở -> Player bước vào ô Cửa |
| 4 | `RIGHT` | `WAIT` | `(5, 2)` | `(2, 1)` | **OPEN** | **OPEN** | **Player bước lên ExitPortal -> THẮNG MÀN!** |

* **Tổng số vòng:** 2 vòng ($1$ Echo).
* **Số tick hoàn thành:** 4 ticks ($\le 12$ ticks).

---

## 3. Level 03 — "Echo Memory"

### 3.1. Cấu hình Dữ liệu (`res://data/levels/level_03.tres`)
* **Kích thước bản đồ:** $7 \times 5$ ô (`grid_width = 7`, `grid_height = 5`).
* **Vị trí xuất phát (`player_start`):** `Vector2i(1, 2)`.
* **Vị trí đích (`exit_position`):** `Vector2i(5, 2)`.
* **Công tắc áp lực (`switch_positions`):** `[Vector2i(3, 1)]` (Switch 0).
* **Cửa năng lượng (`door_configs`):** `[{"position": Vector2i(4, 2), "switch_indices": [0]}]`.
* **Tường chướng ngại vật (`wall_cells`):** Viền ngoài, barrier cột 4 (`(4, 1)`, `(4, 3)`) và vật cản `(2, 3)`.

### 3.2. Lời giải chi tiết theo từng Vòng & Tick

#### Vòng 1 (Ghi chuỗi hành động tuần tra cho Echo 1)
| Tick | Lệnh Player | Vị trí Player | Switch 0 | Door (cuối tick) | Ghi chú |
|:---:|:---|:---:|:---:|:---:|:---|
| Start | — | `(1, 2)` | Inactive | Closed | Bắt đầu vòng |
| 1 | `UP` | `(1, 1)` | Inactive | Closed | Di chuyển lên nhánh trên |
| 2 | `RIGHT` | `(2, 1)` | Inactive | Closed | Di chuyển tiếp |
| 3 | `RIGHT` | `(3, 1)` | **ACTIVE** | **OPEN** | Bước lên Switch 0; cửa mở ở cuối tick 3 |
| 4 | `DOWN` | `(3, 2)` | Inactive | Closed | Rời khỏi Switch 0; cửa đóng ở cuối tick 4 |
| 5–12 | `WAIT` | `(3, 2)` | Inactive | Closed | Đứng yên cho đến hết vòng |

#### Vòng 2 (Player căn nhịp thời gian với ký ức của Echo 1)
| Tick | Lệnh Player | Lệnh Echo 1 | Vị trí Player | Vị trí Echo 1 | Door Snapshot (đầu tick) | Door (cuối tick) | Kết quả |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---|
| 1 | `WAIT` | `UP` | `(1, 2)` | `(1, 1)` | Closed | Closed | Player đứng yên chờ nhịp |
| 2 | `RIGHT` | `RIGHT` | `(2, 2)` | `(2, 1)` | Closed | Closed | Player bắt đầu di chuyển |
| 3 | `RIGHT` | `RIGHT` | `(3, 2)` | `(3, 1)` | Closed | **OPEN** | Echo đạp Switch 0; Door mở ở cuối tick 3 |
| 4 | `RIGHT` | `DOWN` | `(4, 2)` | `(3, 2)` | **OPEN** | Closed | Snapshot mở -> Player bước vào Door; Echo rời switch |
| 5 | `RIGHT` | `WAIT` | `(5, 2)` | `(3, 2)` | Closed | Closed | **Player bước ra khỏi Door về ExitPortal -> THẮNG!** |

* **Đặc điểm bất biến đã chứng minh:** Ở tick 4, Echo rời switch làm cửa đóng lại ở cuối tick 4, nhưng Player đã bước vào cửa dựa trên snapshot đầu tick mở và ở tick 5 bước ra an toàn về đích mà không bị kẹt hay chết (đúng Mục 2.5 AGENTS.md).
* **Tổng số vòng:** 2 vòng ($1$ Echo).
* **Số tick hoàn thành:** 5 ticks ($\le 12$ ticks).

---

## 4. Level 04 — "Two Paths"

### 4.1. Cấu hình Dữ liệu (`res://data/levels/level_04.tres`)
* **Kích thước bản đồ:** $7 \times 7$ ô (`grid_width = 7`, `grid_height = 7`).
* **Vị trí xuất phát (`player_start`):** `Vector2i(1, 3)` (trung tâm ngã ba phân nhánh).
* **Vị trí đích (`exit_position`):** `Vector2i(5, 5)` (cuối Tuyến Nam).
* **Công tắc áp lực (`switch_positions`):** `[Vector2i(5, 1)]` (cuối Tuyến Bắc).
* **Cửa năng lượng (`door_configs`):** `[{"position": Vector2i(4, 5), "switch_indices": [0]}]`.
* **Tường chướng ngại vật (`wall_cells`):**
  * Tường ngăn cách giữa Bắc và Nam: `(2, 3), (3, 3), (4, 3), (5, 3)`.
  * Khối phong tỏa phòng đích ở Tuyến Nam: `(4, 4), (5, 4)`.

### 4.2. Lời giải chi tiết theo từng Vòng & Tick

#### Vòng 1 (Player đi Tuyến Bắc giữ Switch 0)
* Lộ trình: `(1, 3)` -> `(1, 2)` -> `(1, 1)` -> `(2, 1)` -> `(3, 1)` -> `(4, 1)` -> `(5, 1)` (Switch 0).
* Chuỗi lệnh: `["UP", "UP", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "WAIT", ...]`
* Tại tick 6: Player đến `(5, 1)`, Switch 0 kích hoạt, Cửa `(4, 5)` ở Tuyến Nam mở.

#### Vòng 2 (Echo 1 đi Tuyến Bắc, Player đi Tuyến Nam)
| Tick | Lệnh Player | Vị trí Player | Lệnh Echo 1 | Vị trí Echo 1 | Door Snapshot | Door (cuối tick) |
|:---:|:---|:---:|:---|:---:|:---:|:---:|
| 1 | `DOWN` | `(1, 4)` | `UP` | `(1, 2)` | Closed | Closed |
| 2 | `DOWN` | `(1, 5)` | `UP` | `(1, 1)` | Closed | Closed |
| 3 | `RIGHT` | `(2, 5)` | `RIGHT` | `(2, 1)` | Closed | Closed |
| 4 | `RIGHT` | `(3, 5)` | `RIGHT` | `(3, 1)` | Closed | Closed |
| 5 | `WAIT` | `(3, 5)` | `RIGHT` | `(4, 1)` | Closed | Closed |
| 6 | `WAIT` | `(3, 5)` | `RIGHT` | `(5, 1)` (on switch) | Closed | **OPEN** |
| 7 | `RIGHT` | `(4, 5)` (in door) | `WAIT` | `(5, 1)` | **OPEN** | **OPEN** |
| 8 | `RIGHT` | `(5, 5)` (EXIT) | `WAIT` | `(5, 1)` | **OPEN** | **OPEN** |

* **Kết quả:** Player bước lên ExitPortal `(5, 5)` ở Tick 8 -> **THẮNG MÀN!**
* **Tổng số vòng:** 2 vòng ($1$ Echo).
* **Số tick hoàn thành:** 8 ticks ($\le 12$ ticks).

---

## 5. Level 05 — "Double Echo"

### 5.1. Cấu hình Dữ liệu (`res://data/levels/level_05.tres`)
* **Kích thước bản đồ:** $8 \times 7$ ô (`grid_width = 8`, `grid_height = 7`).
* **Vị trí xuất phát (`player_start`):** `Vector2i(1, 3)` (trung tâm kết nối 3 phòng).
* **Vị trí đích (`exit_position`):** `Vector2i(6, 3)` (cuối Hành lang giữa).
* **Công tắc áp lực (`switch_positions`):**
  * Switch 0: `Vector2i(3, 1)` (Phòng trên).
  * Switch 1: `Vector2i(3, 5)` (Phòng dưới).
* **Cửa năng lượng (`door_configs`):**
  * `[{"position": Vector2i(5, 3), "switch_indices": [0, 1]}]` (Cửa an ninh liên kết cả 2 Switch - AND logic).
* **Tường chướng ngại vật (`wall_cells`):**
  * Tách phòng trên: `(2, 2), (3, 2), (4, 2)`.
  * Tách phòng dưới: `(2, 4), (3, 4), (4, 4)`.
  * Cột bảo mật chặn cửa: `(5, 1), (5, 2), (5, 4), (5, 5)`.

### 5.2. Lời giải chi tiết theo từng Vòng & Tick

#### Vòng 1 (Tạo Echo 1 giữ Switch 0 ở phòng trên)
* Player đi: `UP` -> `UP` -> `RIGHT` -> `RIGHT` đến `(3, 1)` (Switch 0) ở Tick 4.
* Giữ `WAIT` đến hết vòng. Switch 0 active nhưng Door `(5, 3)` vẫn đóng vì thiếu Switch 1.

#### Vòng 2 (Tạo Echo 2 giữ Switch 1 ở phòng dưới)
* Echo 1 tái hiện Loop 1, đến `(3, 1)` ở Tick 4 và giữ Switch 0.
* Player đi: `DOWN` -> `DOWN` -> `RIGHT` -> `RIGHT` đến `(3, 5)` (Switch 1) ở Tick 4.
* Tại Tick 4: Cả 2 công tắc cùng active -> Door `(5, 3)` mở, nhưng Player đang ở phòng dưới không thể qua cửa trong vòng này. Kết thúc vòng tạo Echo 2.

#### Vòng 3 (Player đi hành lang giữa với sự hỗ trợ của 2 Echo)
| Tick | Lệnh Player | Vị trí Player | Lệnh Echo 1 | Vị trí Echo 1 | Lệnh Echo 2 | Vị trí Echo 2 | Door Snapshot | Door (cuối tick) |
|:---:|:---|:---:|:---|:---:|:---|:---:|:---:|:---:|
| 1 | `WAIT` | `(1, 3)` | `UP` | `(1, 2)` | `DOWN` | `(1, 4)` | Closed | Closed |
| 2 | `RIGHT` | `(2, 3)` | `UP` | `(1, 1)` | `DOWN` | `(1, 5)` | Closed | Closed |
| 3 | `RIGHT` | `(3, 3)` | `RIGHT` | `(2, 1)` | `RIGHT` | `(2, 5)` | Closed | Closed |
| 4 | `RIGHT` | `(4, 3)` | `RIGHT` | `(3, 1)` (sw0) | `RIGHT` | `(3, 5)` (sw1) | Closed | **OPEN** |
| 5 | `RIGHT` | `(5, 3)` (in door) | `WAIT` | `(3, 1)` | `WAIT` | `(3, 5)` | **OPEN** | **OPEN** |
| 6 | `RIGHT` | `(6, 3)` (EXIT) | `WAIT` | `(3, 1)` | `WAIT` | `(3, 5)` | **OPEN** | **OPEN** |

* **Kết quả:** Player bước lên ExitPortal `(6, 3)` ở Tick 6 -> **HOÀN THÀNH TOÀN DIỆN LEVEL 05!**
* **Tổng số vòng:** 3 vòng (dùng đủ $2$ Echo).
* **Số tick hoàn thành:** 6 ticks ($\le 12$ ticks).

---

## 6. Kết quả Kiểm thử & Bằng chứng Nghiệm thu (Test Evidence)

### 6.1. Suite kiểm thử `scenes/tests/levels_validation_test.tscn`
* Chạy trực tiếp qua Godot 4.7.2 stable headless:
```text
==================================================
STARTING LEVELS VALIDATION SUITE (LEVELS 02 - 05)
==================================================
--- Validating Resource: res://data/levels/level_02.tres --- (19 checks PASS)
--- Validating Resource: res://data/levels/level_03.tres --- (19 checks PASS)
--- Validating Resource: res://data/levels/level_04.tres --- (19 checks PASS)
--- Validating Resource: res://data/levels/level_05.tres --- (22 checks PASS)
--- Testing Level 02: Hold the Door Solution --- (12 checks PASS)
--- Testing Level 03: Echo Memory Solution --- (11 checks PASS)
--- Testing Level 04: Two Paths Solution --- (8 checks PASS)
--- Testing Level 05: Double Echo Solution --- (14 checks PASS)

LEVELS VALIDATION: 134 PASSED | 0 FAILED
==================================================
```

### 6.2. Kiểm tra Regression trên toàn bộ Project
1. `scenes/tests/levels_validation_test.tscn`: **134/134 PASSED (0 FAILED)**
2. `scenes/tests/puzzle_tick_test.tscn`: **34/34 PASSED (0 FAILED)**
3. `scenes/tests/level_01_test.tscn`: **21/21 PASSED (0 FAILED)**
4. `scenes/tests/sprint_03_core_test.tscn`: **19/19 PASSED (0 FAILED)**
5. `scenes/tests/replay_regression_test.tscn`: **20/20 PASSED (0 FAILED)**
6. Chạy F5 Main Menu $\leftrightarrow$ Gameplay: Hoạt động bình thường, không có lỗi runtime/debugger đỏ.
