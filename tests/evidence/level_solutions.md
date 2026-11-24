# Echo Loop — Hồ sơ Lời giải Chuẩn & Bằng chứng Kiểm thử 5 Màn chơi (Level 01–05)

Hồ sơ Android của baseline Sprint 05. Xem [Level Design V2](../level_design_v2.md) để chạy bản đồ và lời giải của đợt polish.

**Issue:** #28 (`S05-TV3 — QA đường giải và tile/object placement trên 5 màn Android`)  
**Owner:** TV3 (Puzzle & Level)  
**Source Baseline:** `main` commit `b1b48b0` (đã tích hợp đầy đủ Sprint 04 và cấu hình Android Sprint 05)  
**Engine:** Godot Engine `v4.7.2.stable.official.ed1daf0bf`  
**Trạng thái xác minh:**
- **Godot 4.7.2 Integrated Gameplay Runtime (`scenes/gameplay/gameplay.tscn`):** `PASS (5/5 màn hoàn thành đúng lời giải, 0 lỗi placement, 0 đường tắt)`
- **APK Android 15 Thực tế (`EchoLoop-S05-Debug.apk` trên `Samsung SM-A5560`, ADB `127.0.0.1:7555`):** `PASS (5/5 màn hoàn thành trực tiếp qua thao tác cảm ứng trên Android, SHA-256: ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b)`

---

## 1. Bảng Tổng hợp Thông số & Lộ trình 5 Màn chơi Cốt lõi

| Màn | Tên màn (`level_name`) | File Resource | Kích thước Grid | `player_start` (Grid / Pixel) | `exit_position` (Grid / Pixel) | Số Switch | Số Door (Liên kết) | Số Echo bắt buộc | Số Loop | Tick thắng ở Loop cuối | Cơ chế trọng tâm |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **01** | **First Step** | `res://data/levels/level_01.tres` | $7 \times 5$ | `(1, 2)` / `(72, 120)` | `(5, 2)` / `(264, 120)` | 0 | 0 | **0 Echo** | 1 | **6 / 12** | Di chuyển cơ bản trên lưới, vòng qua tường chắn và chạm `ExitPortal` |
| **02** | **Hold the Door** | `res://data/levels/level_02.tres` | $7 \times 5$ | `(1, 2)` / `(72, 120)` | `(5, 2)` / `(264, 120)` | 1 (`(2, 1)`) | 1 (`(4, 2)` $\leftarrow$ `[0]`) | **1 Echo** | 2 | **4 / 12** | Dùng 1 Echo đứng giữ `PressureSwitch` để mở `Door` cho Player đi qua |
| **03** | **Echo Memory** | `res://data/levels/level_03.tres` | $7 \times 5$ | `(1, 2)` / `(72, 120)` | `(5, 2)` / `(264, 120)` | 1 (`(3, 1)`) | 1 (`(4, 2)` $\leftarrow$ `[0]`) | **1 Echo** | 2 | **5 / 12** | Canh nhịp thời gian (`WAIT`) đồng bộ với tick Echo đạp công tắc và quy tắc snapshot cửa đầu tick |
| **04** | **Two Paths** | `res://data/levels/level_04.tres` | $7 \times 7$ | `(1, 3)` / `(72, 168)` | `(5, 5)` / `(264, 264)` | 1 (`(5, 1)`) | 1 (`(4, 5)` $\leftarrow$ `[0]`) | **1 Echo** | 2 | **8 / 12** | Phân chia 2 lộ trình độc lập: Echo đi Tuyến Bắc mở công tắc, Player đi Tuyến Nam qua cửa về đích |
| **05** | **Double Echo** | `res://data/levels/level_05.tres` | $8 \times 7$ | `(1, 3)` / `(72, 168)` | `(6, 3)` / `(312, 168)` | 2 (`(3, 1)`, `(3, 5)`) | 1 (`(5, 3)` $\leftarrow$ `[0, 1]`) | **2 Echo** | 3 | **6 / 12** | Phối hợp tối đa 2 Echo giữ đồng thời 2 công tắc ở 2 phòng (AND logic) để mở cửa trung tâm |

> **Công thức quy đổi tọa độ hiển thị chuẩn (`CELL_SIZE = 48`):**
> - Tâm nhân vật (`Player`, `Echo`) và vật thể (`PressureSwitch`, `Door`, `ExitPortal`): `pixel_pos = Vector2(grid_pos * 48) + Vector2(24, 24)`.
> - Ô tường (`Wall Polygon2D` $48 \times 48$ px): góc trên-trái đặt tại `Vector2(grid_pos * 48)`.

---

## 2. Chi tiết Lời giải Chuẩn & Kiểm chứng Không có Đường tắt (Level 01 – Level 05)

### 2.1. Level 01 — `First Step` (`res://data/levels/level_01.tres`)

#### A. Cấu hình bản đồ & Tọa độ Placement
- **Kích thước:** $7 \times 5$ ô (`336 × 240` px).
- **Start:** `Vector2i(1, 2)` $\rightarrow$ Pixel `(72.0, 120.0)`.
- **ExitPortal:** `Vector2i(5, 2)` $\rightarrow$ Pixel `(264.0, 120.0)`, sprite `exit_portal.png` ($48 \times 48$ px).
- **Tường (`wall_cells` — 21 ô):** Toàn bộ viền ngoài bản đồ và 1 khối tường chắn giữa tại `Vector2i(3, 2)` (góc trên-trái `(144.0, 96.0)`).
- **Switch / Door:** Không có (`switch_positions = []`, `door_configs = []`).

#### B. Bảng hành động theo Loop & Tick (Golden Solution — 1 Loop, 0 Echo)
- **Chuỗi lệnh Vòng 1:** `["RIGHT", "UP", "RIGHT", "RIGHT", "DOWN", "RIGHT"]`

| Loop | Tick | Lệnh Player | Vị trí Player (sau tick) | Trạng thái |
|:---:|:---:|:---|:---:|:---|
| 1 | Start | — | `(1, 2)` | Khởi đầu tại điểm xuất phát |
| 1 | 1 | `RIGHT` | `(2, 2)` | Tiến sát trước tường chắn `(3, 2)` |
| 1 | 2 | `UP` | `(2, 1)` | Rẽ lên hành lang trên để vòng qua tường |
| 1 | 3 | `RIGHT` | `(3, 1)` | Đi ngang qua phía trên ô tường `(3, 2)` |
| 1 | 4 | `RIGHT` | `(4, 1)` | Sang phía bên phải của tường chắn |
| 1 | 5 | `DOWN` | `(4, 2)` | Hạ xuống thẳng hàng với cổng thoát hiểm |
| 1 | 6 | `RIGHT` | `(5, 2)` | **Chạm `ExitPortal (5, 2)` $\rightarrow$ `LEVEL COMPLETED AT TICK 6`!** |

#### C. Kiểm chứng Không có đường tắt (Anti-Shortcut Proof)
- Nếu người chơi bấm đi thẳng `["RIGHT", "RIGHT", "RIGHT", "RIGHT"]`: từ Tick 2 trở đi nhân vật bị chặn bởi tường `(3, 2)`, giữ nguyên vị trí tại `(2, 2)` và vẫn tiêu tốn tick theo đúng luật bất biến. Đường đi ngắn nhất trên lưới bắt buộc là **6 ticks** (qua nhánh trên `y = 1` hoặc nhánh dưới `y = 3`).

---

### 2.2. Level 02 — `Hold the Door` (`res://data/levels/level_02.tres`)

#### A. Cấu hình bản đồ & Tọa độ Placement
- **Kích thước:** $7 \times 5$ ô (`336 × 240` px).
- **Start:** `Vector2i(1, 2)` $\rightarrow$ Pixel `(72.0, 120.0)`.
- **ExitPortal:** `Vector2i(5, 2)` $\rightarrow$ Pixel `(264.0, 120.0)`.
- **Switch 0:** `Vector2i(2, 1)` $\rightarrow$ Pixel `(120.0, 72.0)`, sprite `switch_off.png` / `switch_on.png` ($48 \times 48$ px).
- **Door 0:** `Vector2i(4, 2)` $\rightarrow$ Pixel `(216.0, 120.0)`, liên kết `switch_indices = [0]`, sprite `door_closed.png` / `door_open.png` ($48 \times 48$ px).
- **Tường (`wall_cells` — 22 ô):** Viền ngoài + vách ngăn cột 4 tại `(4, 1)` và `(4, 3)`, khóa kín toàn bộ lối sang cột 5 trừ ô cửa `(4, 2)`.

#### B. Bảng hành động theo Loop & Tick (Golden Solution — 2 Loops, 1 Echo)
- **Vòng 1 (Ghi Echo 1):** `["UP", "RIGHT", "WAIT"]` sau đó bấm **`END LOOP`** (hệ thống tự động đệm 9 lệnh `"WAIT"` cho Tick 4–12).
- **Vòng 2 (Player về đích):** `["RIGHT", "RIGHT", "RIGHT", "RIGHT"]`

| Loop | Tick | Lệnh Player | Lệnh Echo 1 | Vị trí Player | Vị trí Echo 1 | Switch 0 `(2, 1)` | Door Snapshot (Đầu tick) | Door State (Cuối tick) | Kết quả |
|:---:|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | 1 | `UP` | — | `(1, 1)` | — | OFF | Closed | Closed | Player lên góc trên |
| 1 | 2 | `RIGHT` | — | `(2, 1)` | — | **ON** | Closed | **OPEN** | Player đạp Switch 0, cửa mở cuối tick |
| 1 | 3 | `WAIT` (+ End Loop) | — | `(2, 1)` | — | **ON** | **OPEN** | **OPEN** | Chốt bản ghi Echo 1 (đệm `WAIT` tới tick 12) |
| 2 | 1 | `RIGHT` | `UP` | `(2, 2)` | `(1, 1)` | OFF | Closed | Closed | Cả hai rời điểm xuất phát |
| 2 | 2 | `RIGHT` | `RIGHT` | `(3, 2)` | `(2, 1)` | **ON** | Closed | **OPEN** | Echo 1 đạp Switch 0; Door `(4, 2)` mở ở cuối tick 2 |
| 2 | 3 | `RIGHT` | `WAIT` | `(4, 2)` | `(2, 1)` | **ON** | **OPEN** | **OPEN** | Snapshot đầu tick 3 mở $\rightarrow$ Player bước vào ô Door `(4, 2)` |
| 2 | 4 | `RIGHT` | `WAIT` | `(5, 2)` | `(2, 1)` | **ON** | **OPEN** | **OPEN** | **Player bước lên `ExitPortal (5, 2)` $\rightarrow$ `LEVEL COMPLETED AT TICK 4`!** |

#### C. Kiểm chứng Không có đường tắt (Anti-Shortcut Proof)
- **Không thể giải với 0 Echo:** Khoảng cách Manhattan từ Switch 0 `(2, 1)` tới Door `(4, 2)` là 3 bước. Nếu ở Vòng 1 Player tự đạp Switch 0 tại `(2, 1)` rồi bước xuống `(2, 2)` để chạy về cửa (`["UP", "RIGHT", "DOWN", "RIGHT", "RIGHT"]`), ngay ở cuối tick bước ra khỏi `(2, 1)`, Switch 0 tắt (`OFF`) và Door `(4, 2)` đóng lại (`CLOSED`). Khi Player tới `(3, 2)` và muốn vào `(4, 2)`, cửa đã đóng và chặn đứng Player tại `(3, 2)`. Bắt buộc phải có **1 Echo** đứng giữ công tắc.

---

### 2.3. Level 03 — `Echo Memory` (`res://data/levels/level_03.tres`)

#### A. Cấu hình bản đồ & Tọa độ Placement
- **Kích thước:** $7 \times 5$ ô (`336 × 240` px).
- **Start:** `Vector2i(1, 2)` $\rightarrow$ Pixel `(72.0, 120.0)`.
- **ExitPortal:** `Vector2i(5, 2)` $\rightarrow$ Pixel `(264.0, 120.0)`.
- **Switch 0:** `Vector2i(3, 1)` $\rightarrow$ Pixel `(168.0, 72.0)`.
- **Door 0:** `Vector2i(4, 2)` $\rightarrow$ Pixel `(216.0, 120.0)`, liên kết `switch_indices = [0]`.
- **Tường (`wall_cells` — 23 ô):** Viền ngoài + vách ngăn cột 4 (`(4, 1)`, `(4, 3)`) + tường chắn nhánh dưới `(2, 3)`.

#### B. Bảng hành động theo Loop & Tick (Golden Solution — 2 Loops, 1 Echo)
- **Vòng 1 (Ghi Echo 1):** `["UP", "RIGHT", "RIGHT", "DOWN", "WAIT"]` sau đó bấm **`END LOOP`**.
- **Vòng 2 (Player căn nhịp với `WAIT`):** `["WAIT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"]`

| Loop | Tick | Lệnh Player | Lệnh Echo 1 | Vị trí Player | Vị trí Echo 1 | Switch 0 `(3, 1)` | Door Snapshot (Đầu tick) | Door State (Cuối tick) | Kết quả |
|:---:|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | 1 | `UP` | — | `(1, 1)` | — | OFF | Closed | Closed | Lên hành lang trên |
| 1 | 2 | `RIGHT` | — | `(2, 1)` | — | OFF | Closed | Closed | Tiến về công tắc |
| 1 | 3 | `RIGHT` | — | `(3, 1)` | — | **ON** | Closed | **OPEN** | Đạp Switch 0 ở Tick 3 |
| 1 | 4 | `DOWN` | — | `(3, 2)` | — | OFF | **OPEN** | Closed | Bước khỏi Switch 0 ở Tick 4 |
| 1 | 5 | `WAIT` (+ End Loop) | — | `(3, 2)` | — | OFF | Closed | Closed | Chốt chuỗi lệnh Echo 1 |
| 2 | 1 | `WAIT` | `UP` | `(1, 2)` | `(1, 1)` | OFF | Closed | Closed | **Player dùng `WAIT` 1 nhịp để đồng bộ thời gian** |
| 2 | 2 | `RIGHT` | `RIGHT` | `(2, 2)` | `(2, 1)` | OFF | Closed | Closed | Player tiến lên `(2, 2)` |
| 2 | 3 | `RIGHT` | `RIGHT` | `(3, 2)` | `(3, 1)` | **ON** | Closed | **OPEN** | Player đứng chờ sát cửa `(3, 2)`; Echo 1 đạp Switch 0 mở cửa cuối tick 3 |
| 2 | 4 | `RIGHT` | `DOWN` | `(4, 2)` | `(3, 2)` | OFF | **OPEN** | Closed | Snapshot đầu tick 4 mở $\rightarrow$ Player vào ô Door `(4, 2)` dù cuối tick cửa đóng |
| 2 | 5 | `RIGHT` | `WAIT` | `(5, 2)` | `(3, 2)` | OFF | Closed | Closed | **Player bước từ ô cửa ra `ExitPortal (5, 2)` $\rightarrow$ `LEVEL COMPLETED AT TICK 5`!** |

#### C. Kiểm chứng Không có đường tắt & Bất biến Snapshot Cửa
- **Nếu Player không dùng `WAIT` ở Vòng 2** mà đi thẳng `["RIGHT", "RIGHT", "RIGHT"]`: Player tới `(3, 2)` ở Tick 2 và muốn bước vào Door `(4, 2)` ở đầu Tick 3. Tuy nhiên, tại đầu Tick 3, Echo 1 mới đang đi từ `(2, 1)` sang `(3, 1)` nên **snapshot cửa đầu Tick 3 vẫn là `CLOSED`**. Player bị chặn lại ở `(3, 2)` (đúng quy tắc bất biến Mục 2.5: không xuyên cửa vừa mở trong cùng tick).
- Đồng thời ở Tick 4–5, màn chơi chứng minh quy tắc: khi cửa đóng lại lúc Player đang đứng sẵn trên ô cửa `(4, 2)`, Player không bị kẹt và bước ra `(5, 2)` an toàn ở Tick 5.

---

### 2.4. Level 04 — `Two Paths` (`res://data/levels/level_04.tres`)

#### A. Cấu hình bản đồ & Tọa độ Placement
- **Kích thước:** $7 \times 7$ ô (`336 × 336` px).
- **Start:** `Vector2i(1, 3)` $\rightarrow$ Pixel `(72.0, 168.0)`.
- **ExitPortal:** `Vector2i(5, 5)` $\rightarrow$ Pixel `(264.0, 264.0)`.
- **Switch 0:** `Vector2i(5, 1)` $\rightarrow$ Pixel `(264.0, 72.0)` (cuối Tuyến Bắc).
- **Door 0:** `Vector2i(4, 5)` $\rightarrow$ Pixel `(216.0, 264.0)` (trên Tuyến Nam), liên kết `switch_indices = [0]`.
- **Tường (`wall_cells` — 30 ô):** Viền ngoài + dải tường ngăn đôi Bắc/Nam `(2, 3), (3, 3), (4, 3), (5, 3)` + tường khóa buồng đích Tuyến Nam `(4, 4), (5, 4)`.

#### B. Bảng hành động theo Loop & Tick (Golden Solution — 2 Loops, 1 Echo)
- **Vòng 1 (Ghi Echo 1 — Tuyến Bắc):** `["UP", "UP", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "WAIT"]` + **`END LOOP`**.
- **Vòng 2 (Player — Tuyến Nam):** `["DOWN", "DOWN", "RIGHT", "RIGHT", "WAIT", "WAIT", "RIGHT", "RIGHT"]`

| Loop | Tick | Lệnh Player | Lệnh Echo 1 | Vị trí Player | Vị trí Echo 1 | Switch 0 `(5, 1)` | Door Snapshot (Đầu tick) | Door State (Cuối tick) | Kết quả |
|:---:|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | 1–6 | `UP, UP, RIGHT×4` | — | `(5, 1)` | — | **ON** (ở Tick 6) | Closed | **OPEN** (ở Tick 6) | Player đi hết Tuyến Bắc, đạp Switch 0 tại `(5, 1)` ở Tick 6 |
| 1 | 7 | `WAIT` (+ End Loop) | — | `(5, 1)` | — | **ON** | **OPEN** | **OPEN** | Chốt bản ghi Echo 1 giữ Switch 0 từ Tick 6–12 |
| 2 | 1 | `DOWN` | `UP` | `(1, 4)` | `(1, 2)` | OFF | Closed | Closed | Phân nhánh: Player rẽ Nam, Echo 1 rẽ Bắc |
| 2 | 2 | `DOWN` | `UP` | `(1, 5)` | `(1, 1)` | OFF | Closed | Closed | Đi dọc hành lang mỗi nhánh |
| 2 | 3 | `RIGHT` | `RIGHT` | `(2, 5)` | `(2, 1)` | OFF | Closed | Closed | Tiến sâu vào 2 nhánh |
| 2 | 4 | `RIGHT` | `RIGHT` | `(3, 5)` | `(3, 1)` | OFF | Closed | Closed | Player đứng trước Door `(4, 5)` |
| 2 | 5 | `WAIT` | `RIGHT` | `(3, 5)` | `(4, 1)` | OFF | Closed | Closed | Player chờ Echo 1 đi nốt Tuyến Bắc |
| 2 | 6 | `WAIT` | `RIGHT` | `(3, 5)` | `(5, 1)` | **ON** | Closed | **OPEN** | Echo 1 chạm Switch 0 `(5, 1)` $\rightarrow$ Door `(4, 5)` mở cuối Tick 6 |
| 2 | 7 | `RIGHT` | `WAIT` | `(4, 5)` | `(5, 1)` | **ON** | **OPEN** | **OPEN** | Snapshot đầu Tick 7 mở $\rightarrow$ Player bước vào Door `(4, 5)` |
| 2 | 8 | `RIGHT` | `WAIT` | `(5, 5)` | `(5, 1)` | **ON** | **OPEN** | **OPEN** | **Player chạm `ExitPortal (5, 5)` $\rightarrow$ `LEVEL COMPLETED AT TICK 8`!** |

#### C. Kiểm chứng Không có đường tắt (Anti-Shortcut Proof)
- **Không thể giải với 0 Echo:** Tường ngăn giữa `(2, 3)..(5, 3)` buộc muốn từ Switch 0 `(5, 1)` sang Door `(4, 5)` phải quay ngược về ngã ba `(1, 3)` (tổng quãng đường $6 + 10 = 16$ bước $> 12$ ticks giới hạn mỗi vòng), và ngay khi rời `(5, 1)` ở bước đầu tiên (`LEFT` về `(4, 1)`), Door `(4, 5)` đã đóng ngay lập tức.

---

### 2.5. Level 05 — `Double Echo` (`res://data/levels/level_05.tres`)

#### A. Cấu hình bản đồ & Tọa độ Placement
- **Kích thước:** $8 \times 7$ ô (`384 × 336` px).
- **Start:** `Vector2i(1, 3)` $\rightarrow$ Pixel `(72.0, 168.0)`.
- **ExitPortal:** `Vector2i(6, 3)` $\rightarrow$ Pixel `(312.0, 168.0)`.
- **Switch 0 (Phòng trên):** `Vector2i(3, 1)` $\rightarrow$ Pixel `(168.0, 72.0)`.
- **Switch 1 (Phòng dưới):** `Vector2i(3, 5)` $\rightarrow$ Pixel `(168.0, 264.0)`.
- **Door 0 (Hành lang giữa):** `Vector2i(5, 3)` $\rightarrow$ Pixel `(264.0, 168.0)`, liên kết **AND 2 công tắc** `switch_indices = [0, 1]`.
- **Tường (`wall_cells` — 36 ô):** Viền ngoài + vách ngăn Phòng trên `(2, 2), (3, 2), (4, 2)` + vách ngăn Phòng dưới `(2, 4), (3, 4), (4, 4)` + vách an ninh cột 5 `(5, 1), (5, 2), (5, 4), (5, 5)`.

#### B. Bảng hành động theo Loop & Tick (Golden Solution — 3 Loops, 2 Echoes)
- **Vòng 1 (Ghi Echo 1 — Phòng trên):** `["UP", "UP", "RIGHT", "RIGHT", "WAIT"]` + **`END LOOP`**.
- **Vòng 2 (Ghi Echo 2 — Phòng dưới):** `["DOWN", "DOWN", "RIGHT", "RIGHT", "WAIT"]` + **`END LOOP`**.
- **Vòng 3 (Player — Hành lang giữa về đích):** `["WAIT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"]`

| Loop | Tick | Lệnh Player | Lệnh Echo 1 | Lệnh Echo 2 | Vị trí Player | Vị trí Echo 1 | Vị trí Echo 2 | Sw 0 `(3,1)` | Sw 1 `(3,5)` | Door Snapshot | Door Cuối Tick | Kết quả |
|:---:|:---:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | 1–4 | `UP, UP, RIGHT, RIGHT` | — | — | `(3, 1)` | — | — | **ON** (T4) | OFF | Closed | Closed | Player giữ Switch 0; thiếu Switch 1 nên cửa vẫn đóng |
| 1 | 5 | `WAIT` (+ End Loop) | — | — | `(3, 1)` | — | — | **ON** | OFF | Closed | Closed | Chốt Echo 1 giữ Switch 0 từ Tick 4–12 |
| 2 | 1–4 | `DOWN, DOWN, RIGHT, RIGHT` | `UP, UP, RIGHT, RIGHT` | — | `(3, 5)` | `(3, 1)` | — | **ON** (T4) | **ON** (T4) | Closed | **OPEN** (T4) | Player giữ Switch 1, Echo 1 giữ Switch 0 $\rightarrow$ Cửa mở ở Tick 4 |
| 2 | 5 | `WAIT` (+ End Loop) | `WAIT` | — | `(3, 5)` | `(3, 1)` | — | **ON** | **ON** | **OPEN** | **OPEN** | Chốt Echo 2 giữ Switch 1 từ Tick 4–12 |
| 3 | 1 | `WAIT` | `UP` | `DOWN` | `(1, 3)` | `(1, 2)` | `(1, 4)` | OFF | OFF | Closed | Closed | 2 Echo tách lên/xuống 2 buồng công tắc |
| 3 | 2 | `RIGHT` | `UP` | `DOWN` | `(2, 3)` | `(1, 1)` | `(1, 5)` | OFF | OFF | Closed | Closed | Player tiến vào hành lang giữa |
| 3 | 3 | `RIGHT` | `RIGHT` | `RIGHT` | `(3, 3)` | `(2, 1)` | `(2, 5)` | OFF | OFF | Closed | Closed | Player đi giữa `(3, 3)` |
| 3 | 4 | `RIGHT` | `RIGHT` | `RIGHT` | `(4, 3)` | `(3, 1)` | `(3, 5)` | **ON** | **ON** | Closed | **OPEN** | Cả 2 Echo đạp 2 Switch ở Tick 4 $\rightarrow$ Door `(5, 3)` mở cuối Tick 4 |
| 3 | 5 | `RIGHT` | `WAIT` | `WAIT` | `(5, 3)` | `(3, 1)` | `(3, 5)` | **ON** | **ON** | **OPEN** | **OPEN** | Snapshot đầu Tick 5 mở $\rightarrow$ Player bước vào Door `(5, 3)` |
| 3 | 6 | `RIGHT` | `WAIT` | `WAIT` | `(6, 3)` | `(3, 1)` | `(3, 5)` | **ON** | **ON** | **OPEN** | **OPEN** | **Player chạm `ExitPortal (6, 3)` $\rightarrow$ `LEVEL COMPLETED AT TICK 6`!** |

#### C. Kiểm chứng Không có đường tắt (Anti-Shortcut Proof)
- **Không thể giải với 0 Echo hoặc 1 Echo:** Door `(5, 3)` yêu cầu điều kiện AND (`switch_indices = [0, 1]`). Nếu chỉ dùng 1 Echo giữ Switch 0 `(3, 1)` và Player tự đạp Switch 1 `(3, 5)` ở Vòng 2, cửa `(5, 3)` mở ra nhưng ngay khi Player bước khỏi `(3, 5)` (`LEFT` về `(2, 5)`) để quay ra hành lang giữa, Switch 1 tắt (`OFF`) và Door `(5, 3)` đóng lại ngay cuối tick đó. Do đó, bắt buộc phải dùng đủ **2 Echo (3 vòng lặp)**.

---

## 3. Log Bằng chứng Thực thi Thực tế trên `scenes/gameplay/gameplay.tscn` (Godot 4.7.2)

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
Baseline commit: b1b48b0 | Scene: res://scenes/gameplay/gameplay.tscn

--- 1. Verifying Golden Solutions & Placement on Integrated gameplay.tscn ---
  [PASS] L01 Player pixel pos == (72.0, 120.0) | ExitPortal pixel pos == (264.0, 120.0) | Wall count == 21
  LEVEL COMPLETED AT TICK 6 -> L01 Gameplay: Player reached Exit (5, 2) at Tick 6
  [PASS] L02 Player pixel pos == (72.0, 120.0) | Switch[0] == (120.0, 72.0) | Door[0] == (216.0, 120.0) | Exit == (264.0, 120.0)
  LEVEL COMPLETED AT TICK 4 -> L02 Gameplay: Player reached Exit (5, 2) at Loop 2 Tick 4
  [PASS] L03 Player pixel pos == (72.0, 120.0) | Switch[0] == (168.0, 72.0) | Door[0] == (216.0, 120.0) | Exit == (264.0, 120.0)
  LEVEL COMPLETED AT TICK 5 -> L03 Gameplay: Player reached Exit (5, 2) at Loop 2 Tick 5
  [PASS] L04 Player pixel pos == (72.0, 168.0) | Switch[0] == (264.0, 72.0) | Door[0] == (216.0, 264.0) | Exit == (264.0, 264.0)
  LEVEL COMPLETED AT TICK 8 -> L04 Gameplay: Player reached Exit (5, 5) at Loop 2 Tick 8
  [PASS] L05 Player pixel pos == (72.0, 168.0) | Switch[0] == (168.0, 72.0) | Switch[1] == (168.0, 264.0) | Door[0] == (264.0, 168.0) | Exit == (312.0, 168.0)
  LEVEL COMPLETED AT TICK 6 -> L05 Gameplay: Player reached Exit (6, 3) at Loop 3 Tick 6

--- 2. Verifying Anti-Shortcut / Unintended Bypass Audit ---
  [PASS] L01 Anti-Shortcut: Straight path blocked by obstacle wall (3, 2)
  [PASS] L02 Anti-Shortcut: Solo player leaving switch closes door before reaching (4, 2)
  [PASS] L03 Anti-Shortcut: Rushing without WAIT is blocked at Tick 3 by start-of-tick door snapshot
  [PASS] L04 Anti-Shortcut: Leaving North Switch (5, 1) immediately closes South Door (4, 5)
  [PASS] L05 Anti-Shortcut: 1 Echo + Player cannot pass Door (5, 3) because leaving Switch 1 deactivates AND condition
```

---

## 4. Logcat Bằng chứng Thực thi Thực tế trên Thiết bị Android 15 (`adb -s 127.0.0.1:7555 logcat -d -s godot:I`)

* **APK:** `EchoLoop-S05-Debug.apk` (`package: com.uth.echoloop`, `122,521,358` bytes)
* **APK SHA-256:** `ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b`
* **Device:** `Samsung SM-A5560` — Android `15` (SDK `35`, `x86_64`, `1600×900` Landscape `320 dpi`)

```text
11-23 12:28:41.142  3276  3315 I godot   : Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
11-23 12:28:41.336  3276  3315 I godot   : OpenGL API OpenGL ES 3.2 v334 R - Compatibility - Using Device: Qualcomm - Adreno (TM) 640
11-23 12:28:43.032  3276  3315 I godot   : Audio preference restored: ON
11-23 12:28:47.007  3276  3315 I godot   : Resume requested
11-23 12:28:47.592  3276  3315 I godot   : Loop 1 | Tick 1 | Player (2, 2) | Echoes 0
11-23 12:28:47.857  3276  3315 I godot   : Loop 1 | Tick 2 | Player (2, 1) | Echoes 0
11-23 12:28:48.141  3276  3315 I godot   : Loop 1 | Tick 3 | Player (3, 1) | Echoes 0
11-23 12:28:48.408  3276  3315 I godot   : Loop 1 | Tick 4 | Player (4, 1) | Echoes 0
11-23 12:28:48.675  3276  3315 I godot   : Loop 1 | Tick 5 | Player (4, 2) | Echoes 0
11-23 12:28:48.961  3276  3315 I godot   : LEVEL COMPLETED AT TICK 6
11-23 12:28:49.791  3276  3315 I godot   : Next level requested
11-23 12:28:50.841  3276  3315 I godot   : Loop 1 | Tick 1 | Player (1, 1) | Echoes 0
11-23 12:28:51.108  3276  3315 I godot   : Loop 1 | Tick 2 | Player (2, 1) | Echoes 0
11-23 12:28:51.374  3276  3315 I godot   : End loop requested
11-23 12:28:51.957  3276  3315 I godot   : Restart requested
11-23 12:28:52.624  3276  3315 I godot   : Loop 1 | Tick 1 | Player (1, 1) | Echoes 0
11-23 12:28:52.891  3276  3315 I godot   : Loop 1 | Tick 2 | Player (2, 1) | Echoes 0
11-23 12:28:53.158  3276  3315 I godot   : Loop 1 | Tick 3 | Player (2, 1) | Echoes 0
11-23 12:28:53.424  3276  3315 I godot   : End loop requested
11-23 12:28:54.008  3276  3315 I godot   : Loop 2 | Tick 1 | Player (2, 2) | Echoes 1
11-23 12:28:54.274  3276  3315 I godot   : Loop 2 | Tick 2 | Player (3, 2) | Echoes 1
11-23 12:28:54.541  3276  3315 I godot   : Loop 2 | Tick 3 | Player (4, 2) | Echoes 1
11-23 12:28:54.810  3276  3315 I godot   : LEVEL COMPLETED AT TICK 4
11-23 12:28:55.641  3276  3315 I godot   : Next level requested
11-23 12:28:56.674  3276  3315 I godot   : Loop 1 | Tick 1 | Player (1, 1) | Echoes 0
11-23 12:28:56.941  3276  3315 I godot   : Loop 1 | Tick 2 | Player (2, 1) | Echoes 0
11-23 12:28:57.208  3276  3315 I godot   : Loop 1 | Tick 3 | Player (3, 1) | Echoes 0
11-23 12:28:57.474  3276  3315 I godot   : Loop 1 | Tick 4 | Player (3, 2) | Echoes 0
11-23 12:28:57.741  3276  3315 I godot   : Loop 1 | Tick 5 | Player (3, 2) | Echoes 0
11-23 12:28:58.008  3276  3315 I godot   : End loop requested
11-23 12:28:58.541  3276  3315 I godot   : Loop 2 | Tick 1 | Player (1, 2) | Echoes 1
11-23 12:28:58.808  3276  3315 I godot   : Loop 2 | Tick 2 | Player (2, 2) | Echoes 1
11-23 12:28:59.075  3276  3315 I godot   : Loop 2 | Tick 3 | Player (3, 2) | Echoes 1
11-23 12:28:59.341  3276  3315 I godot   : Loop 2 | Tick 4 | Player (4, 2) | Echoes 1
11-23 12:28:59.610  3276  3315 I godot   : LEVEL COMPLETED AT TICK 5
11-23 12:29:00.441  3276  3315 I godot   : Next level requested
11-23 12:29:01.474  3276  3315 I godot   : Loop 1 | Tick 1 | Player (1, 2) | Echoes 0
11-23 12:29:01.741  3276  3315 I godot   : Loop 1 | Tick 2 | Player (1, 1) | Echoes 0
11-23 12:29:02.008  3276  3315 I godot   : Loop 1 | Tick 3 | Player (2, 1) | Echoes 0
11-23 12:29:02.274  3276  3315 I godot   : Loop 1 | Tick 4 | Player (3, 1) | Echoes 0
11-23 12:29:02.541  3276  3315 I godot   : Loop 1 | Tick 5 | Player (4, 1) | Echoes 0
11-23 12:29:02.808  3276  3315 I godot   : Loop 1 | Tick 6 | Player (5, 1) | Echoes 0
11-23 12:29:03.074  3276  3315 I godot   : Loop 1 | Tick 7 | Player (5, 1) | Echoes 0
11-23 12:29:03.341  3276  3315 I godot   : End loop requested
11-23 12:29:03.874  3276  3315 I godot   : Loop 2 | Tick 1 | Player (1, 4) | Echoes 1
11-23 12:29:04.141  3276  3315 I godot   : Loop 2 | Tick 2 | Player (1, 5) | Echoes 1
11-23 12:29:04.408  3276  3315 I godot   : Loop 2 | Tick 3 | Player (2, 5) | Echoes 1
11-23 12:29:04.674  3276  3315 I godot   : Loop 2 | Tick 4 | Player (3, 5) | Echoes 1
11-23 12:29:05.174  3276  3315 I godot   : Loop 2 | Tick 5 | Player (3, 5) | Echoes 1
11-23 12:29:05.424  3276  3315 I godot   : Loop 2 | Tick 6 | Player (3, 5) | Echoes 1
11-23 12:29:05.691  3276  3315 I godot   : Loop 2 | Tick 7 | Player (4, 5) | Echoes 1
11-23 12:29:05.960  3276  3315 I godot   : LEVEL COMPLETED AT TICK 8
11-23 12:29:06.808  3276  3315 I godot   : Next level requested
11-23 12:29:07.841  3276  3315 I godot   : End loop requested
11-23 12:29:08.358  3276  3315 I godot   : End loop requested
11-23 12:29:08.891  3276  3315 I godot   : Loop 3 | Tick 1 | Player (1, 3) | Echoes 2
...
11-23 12:29:11.857  3276  3315 I godot   : Loop 3 | Tick 12 | Player (1, 3) | Echoes 2
11-23 12:29:11.858  3276  3315 I godot   : RUN FAILED: Da het 3 Time Loops
11-23 12:29:12.524  3276  3315 I godot   : Restart requested
11-23 12:29:13.208  3276  3315 I godot   : Loop 1 | Tick 1 | Player (1, 2) | Echoes 0
11-23 12:29:13.474  3276  3315 I godot   : Loop 1 | Tick 2 | Player (1, 1) | Echoes 0
11-23 12:29:13.741  3276  3315 I godot   : Loop 1 | Tick 3 | Player (2, 1) | Echoes 0
11-23 12:29:14.008  3276  3315 I godot   : Loop 1 | Tick 4 | Player (3, 1) | Echoes 0
11-23 12:29:14.291  3276  3315 I godot   : Loop 1 | Tick 5 | Player (3, 1) | Echoes 0
11-23 12:29:14.558  3276  3315 I godot   : End loop requested
11-23 12:29:15.124  3276  3315 I godot   : Loop 2 | Tick 1 | Player (1, 4) | Echoes 1
11-23 12:29:15.391  3276  3315 I godot   : Loop 2 | Tick 2 | Player (1, 5) | Echoes 1
11-23 12:29:15.657  3276  3315 I godot   : Loop 2 | Tick 3 | Player (2, 5) | Echoes 1
11-23 12:29:15.941  3276  3315 I godot   : Loop 2 | Tick 4 | Player (3, 5) | Echoes 1
11-23 12:29:16.208  3276  3315 I godot   : Loop 2 | Tick 5 | Player (3, 5) | Echoes 1
11-23 12:29:16.474  3276  3315 I godot   : End loop requested
11-23 12:29:17.041  3276  3315 I godot   : Loop 3 | Tick 1 | Player (1, 3) | Echoes 2
11-23 12:29:17.307  3276  3315 I godot   : Loop 3 | Tick 2 | Player (2, 3) | Echoes 2
11-23 12:29:17.574  3276  3315 I godot   : Loop 3 | Tick 3 | Player (3, 3) | Echoes 2
11-23 12:29:17.858  3276  3315 I godot   : Loop 3 | Tick 4 | Player (4, 3) | Echoes 2
11-23 12:29:18.124  3276  3315 I godot   : Loop 3 | Tick 5 | Player (5, 3) | Echoes 2
11-23 12:29:18.393  3276  3315 I godot   : LEVEL COMPLETED AT TICK 6
```
