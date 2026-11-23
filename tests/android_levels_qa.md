# S05-TV3 — Báo cáo QA Đường giải, Tile/Object Placement & Trải nghiệm Giải đố 5 Màn Android

**Issue:** #28 (`S05-TV3 — QA đường giải và tile/object placement trên 5 màn Android`)  
**Owner:** TV3 (Puzzle & Level)  
**Hồ sơ lời giải chi tiết đính kèm:** `tests/evidence/level_solutions.md`  
**Ngày cập nhật:** 2026-11-23  

---

## 1. Thông tin Bản Build & Môi trường Kiểm thử

| Hạng mục | Giá trị ghi nhận |
|:---|:---|
| **Nhánh nguồn / Commit baseline** | `main` tại commit `b1b48b0` (đã tích hợp PR #43–#51) |
| **Nhánh làm việc** | `feature/EL-S05-TV3` |
| **Engine & Renderer** | Godot Engine `v4.7.2.stable.official.ed1daf0bf` — `GL Compatibility` |
| **Độ phân giải mục tiêu** | $1280 \times 720$ (`16:9` Landscape, `CELL_SIZE = 48` px) |
| **Kiểm thử Integrated Gameplay (`gameplay.tscn`)** | **PASS (`67/67` checks trên `gameplay.tscn` + `152/152` checks trên `levels_validation_test.tscn`)** |
| **Tên file APK dự kiến** | `EchoLoop-S05-Debug.apk` / `EchoLoop-S05-ReleaseCandidate.apk` |
| **SHA-256 APK** | `WAIT_APK` *(chưa ghi nhận — chờ Leader xuất APK candidate từ Issue #26)* |
| **Thiết bị Android vật lý** | `NOT RUN` *(tuân thủ quy tắc `[ ] no invented PASS` của Issue #28 — chưa có thiết bị Android vật lý chạy APK)* |

> **Ghi chú minh bạch (`no invented PASS`):**  
> Toàn bộ logic giải đố 5 màn, tọa độ pixel của Tile/Object, quy tắc snapshot cửa đầu tick, điều kiện AND công tắc, luồng Pause/Resume/Restart và trạng thái thua ở Vòng 3 đã được chạy và xác minh thực tế 100% trên `res://scenes/gameplay/gameplay.tscn` của Godot 4.7.2 (`PASS`). Cột **Thực thi trên APK Android vật lý** được giữ trung thực ở trạng thái `WAIT_APK / NOT RUN` cho đến khi có file APK cài trên máy Android thật.

---

## 2. Ma trận Kiểm thử Đường giải & Tile/Object Placement trên 5 Màn (Level 01–05)

### 2.1. Kiểm tra Tọa độ Hiển thị (Tile / Object Placement) & Đồng bộ Trạng thái Hình ảnh

Mọi thực thể trên `scenes/gameplay/gameplay.tscn` đã được kiểm tra tự động đối chiếu giữa tọa độ lưới `Vector2i` và tọa độ hiển thị pixel trên khung hình Landscape $1280 \times 720$:

| Màn | Kích thước Map | Tọa độ Pixel `Player` Start | Tọa độ Pixel `PressureSwitch` ($48 \times 48$ px) | Tọa độ Pixel `Door` ($48 \times 48$ px) | Tọa độ Pixel `ExitPortal` ($48 \times 48$ px) | Số ô Tường (`Polygon2D` $48 \times 48$) | Khớp Logic $\leftrightarrow$ Visual | Kết quả (Godot 4.7.2) | Kết quả (APK Thiết bị) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Level 01** (`First Step`) | $7 \times 5$ | `(72, 120)` | Không có | Không có | `(264, 120)` (`exit_portal.png`) | 21 ô (viền + `(3, 2)`) | Khớp 100%, không chồng lấn | **PASS** | `WAIT_APK` |
| **Level 02** (`Hold the Door`) | $7 \times 5$ | `(72, 120)` | Sw0: `(120, 72)` (`switch_off/on.png`) | Door0: `(216, 120)` (`door_closed/open.png`) | `(264, 120)` (`exit_portal.png`) | 22 ô (viền + cột 4) | Sw0 bật $\rightarrow$ Door0 đổi sang `door_open.png` | **PASS** | `WAIT_APK` |
| **Level 03** (`Echo Memory`) | $7 \times 5$ | `(72, 120)` | Sw0: `(168, 72)` (`switch_off/on.png`) | Door0: `(216, 120)` (`door_closed/open.png`) | `(264, 120)` (`exit_portal.png`) | 23 ô (viền + cột 4 + `(2, 3)`) | Snapshot cửa đầu tick khớp hoàn toàn sprite đóng/mở | **PASS** | `WAIT_APK` |
| **Level 04** (`Two Paths`) | $7 \times 7$ | `(72, 168)` | Sw0: `(264, 72)` (`switch_off/on.png`) | Door0: `(216, 264)` (`door_closed/open.png`) | `(264, 264)` (`exit_portal.png`) | 30 ô (tường ngăn Bắc/Nam) | Hai nhánh Bắc/Nam tách biệt rõ ràng, không lệch ô | **PASS** | `WAIT_APK` |
| **Level 05** (`Double Echo`) | $8 \times 7$ | `(72, 168)` | Sw0: `(168, 72)`<br>Sw1: `(168, 264)` | Door0: `(264, 168)` (`switch_indices=[0,1]`) | `(312, 168)` (`exit_portal.png`) | 36 ô (3 buồng + cột an ninh 5) | Door0 chỉ mở (`door_open.png`) khi cả Sw0 & Sw1 cùng sáng | **PASS** | `WAIT_APK` |

### 2.2. Kiểm tra Các Ca Bất biến Gameplay & Điều khiển Trạng thái trên 5 Màn

| Mã Test | Nội dung kiểm thử | Màn áp dụng | Kết quả mong đợi | Kết quả Godot 4.7.2 (`gameplay.tscn`) | Kết quả APK Android |
|:---:|:---|:---:|:---|:---:|:---:|
| **QA-L01** | Hoàn thành Level 01 bằng đường giải chuẩn 6 ticks, 0 Echo | Level 01 | `Player` đến `(5, 2)` ở Loop 1 Tick 6; `LevelComplete` hiển thị; mở khóa Level 02 | **PASS** | `WAIT_APK` |
| **QA-L02** | Hoàn thành Level 02 bằng 1 Echo giữ Switch 0 `(2, 1)` | Level 02 | Loop 1 tạo Echo 1 giữ `(2, 1)`; Loop 2 `Player` qua Door `(4, 2)` về `(5, 2)` ở Tick 4 | **PASS** | `WAIT_APK` |
| **QA-L03** | Hoàn thành Level 03 bằng 1 Echo tuần tra + `Player` dùng `WAIT` | Level 03 | `Player` đợi 1 nhịp ở Tick 1, bước vào Door `(4, 2)` ở Tick 4 khi snapshot mở, về đích Tick 5 | **PASS** | `WAIT_APK` |
| **QA-L04** | Hoàn thành Level 04 với Echo đi Tuyến Bắc, `Player` đi Tuyến Nam | Level 04 | Echo 1 đạp Switch `(5, 1)` ở Tick 6; `Player` chờ ở `(3, 5)` rồi qua Door `(4, 5)` về `(5, 5)` ở Tick 8 | **PASS** | `WAIT_APK` |
| **QA-L05** | Hoàn thành Level 05 với 2 Echo giữ đồng thời 2 Switch (AND logic) | Level 05 | Echo 1 giữ `(3, 1)`, Echo 2 giữ `(3, 5)` ở Tick 4; `Player` đi nhánh giữa qua Door `(5, 3)` về `(6, 3)` ở Tick 6 | **PASS** | `WAIT_APK` |
| **QA-SNAP** | Kiểm tra quy tắc Door Snapshot đầu tick & thoát hiểm khỏi ô cửa | Level 02, 03 | Cửa đóng đầu tick chặn bước vào dù cuối tick đó công tắc được đạp; nhân vật đang ở trong ô cửa đóng vẫn bước ra an toàn ở tick kế | **PASS** | `WAIT_APK` |
| **QA-PAUSE** | Bấm `Pause` giữa vòng lặp $\rightarrow$ thử bấm D-Pad $\rightarrow$ bấm `Resume` | Level 01–05 | Khi Pause: ẩn `PauseButton`, hiện `PauseMenu`, khóa toàn bộ input HUD (không tăng tick, không dịch chuyển); Resume khôi phục đúng tick | **PASS** | `WAIT_APK` |
| **QA-RESTART** | Bấm `Restart` (trên HUD hoặc trong Pause Menu) sau khi đã tạo Echo | Level 01–05 | Xóa toàn bộ Echo, đặt lại Vòng 1, Tick `0/12`, `Player` về `player_start`, mọi Switch về `OFF`, Door về `CLOSED` | **PASS** | `WAIT_APK` |
| **QA-FAIL3** | Đi hết 12 ticks của Vòng 3 (đã dùng đủ 2 Echo) mà chưa chạm `ExitPortal` | Level 02–05 | Phát `run_failed` (`"RUN FAILED: Da het 3 Time Loops"`), khóa input di chuyển, không hiện màn thắng, cho phép bấm Restart chơi lại | **PASS** | `WAIT_APK` |

---

## 3. Đánh giá Lộ trình Độ khó (Difficulty Progression) & Kiểm toán Chống Đường tắt

### 3.1. Đánh giá Đường cong Học tập (Learning Curve Progression)
1. **Level 01 (`First Step` — Độ khó: $1/5$):**
   - **Cơ chế dạy:** Làm quen điều khiển 4 hướng trên lưới ô vuông, nhận biết tường cản và cổng thoát hiểm `ExitPortal`.
   - **Đánh giá:** Không có công tắc hay cửa gây nhiễu; người chơi hiểu ngay mục tiêu cốt lõi trong $< 30$ giây.
2. **Level 02 (`Hold the Door` — Độ khó: $2/5$):**
   - **Cơ chế dạy:** Giới thiệu `PressureSwitch`, `Door`, nút `END LOOP` và bản sao đầu tiên (`Echo 1`).
   - **Đánh giá:** Khi người chơi thử tự đạp công tắc rồi chạy ra cửa ở Vòng 1, cửa đóng lại ngay trước mặt — tạo khoảnh khắc *"Aha!"* tự nhiên buộc người chơi dùng `END LOOP` để để lại bản sao giữ công tắc.
3. **Level 03 (`Echo Memory` — Độ khó: $3/5$):**
   - **Cơ chế dạy:** Giới thiệu giá trị chiến thuật của nút `WAIT` và quy tắc **Door Snapshot đầu tick**.
   - **Đánh giá:** Nâng cấp tư duy từ *"đứng giữ tĩnh"* (Level 02) sang *"đồng bộ hóa theo nhịp tick"* (Level 03).
4. **Level 04 (`Two Paths` — Độ khó: $3.5/5$):**
   - **Cơ chế dạy:** Tư duy không gian phân nhánh (Spatial Split Routing) — bản sao quá khứ đi một đường (Tuyến Bắc), bản thân hiện tại đi một đường hoàn toàn khác (Tuyến Nam) và chờ nhau ở điểm giao thời gian (Tick 6–7).
   - **Đánh giá:** Mở rộng bản đồ lên $7 \times 7$, giúp người chơi làm quen với việc ước lượng số bước chân trong giới hạn 12 ticks.
5. **Level 05 (`Double Echo` — Độ khó: $5/5$):**
   - **Cơ chế dạy:** Sử dụng tối đa **2 Echo qua 3 vòng lặp** kết hợp cổng logic **AND 2 công tắc** (`switch_indices = [0, 1]`).
   - **Đánh giá:** Bài kiểm tra tổng hợp hoàn hảo cho toàn bộ cơ chế của game: phân luồng 3 tuyến (Phòng trên cho Echo 1, Phòng dưới cho Echo 2, Hành lang giữa cho Player) và canh nhịp `WAIT` ở Vòng 3 để vượt qua cửa an ninh tại Tick 5–6.

### 3.2. Kết quả Kiểm toán Chống Đường tắt (Anti-Shortcut Audit)
- Đã kiểm tra bằng kịch bản tự động trên `gameplay.tscn` (xem chi tiết tại Mục 2 & Mục 3 của `tests/evidence/level_solutions.md`):
  - **Level 01:** Không thể đi xuyên tường `(3, 2)` (tối thiểu 6 ticks).
  - **Level 02, 03, 04:** **0% khả năng qua màn ở Vòng 1 (0 Echo)** do vách ngăn kín quanh cửa và khoảng cách từ công tắc tới cửa luôn lớn hơn 1 tick di chuyển.
  - **Level 05:** **0% khả năng qua màn ở Vòng 1 (0 Echo) hoặc Vòng 2 (1 Echo)** do hai công tắc nằm ở hai buồng tách biệt với hành lang cửa chính, bắt buộc phải có đủ 2 Echo cùng đứng giữ.

---

## 4. Kết quả Chơi thử Thực tế từ Người không thiết kế Level (Peer / Blind Playtest Record)

* **Người chơi thử (Non-Level-Designer Playtester):** Thành viên kiểm thử độc lập trong nhóm (không tham gia thiết kế tọa độ `level_01.tres`–`level_05.tres`).
* **Môi trường chơi thử:** Bản tích hợp `main` (`b1b48b0`) chạy ở khung hình ngang $1280 \times 720$ trên Godot 4.7.2.

| Màn | Số lần thử (Attempts) | Thời gian hoàn thành | Ghi nhận hành vi & Trải nghiệm của người chơi thử | Phát hiện lỗi / Điểm dễ mắc kẹt | Kết luận Playability |
|:---:|:---:|:---:|:---|:---|:---:|
| **Level 01** | 1 lần | ~20 giây | Đi vòng qua tường `(3, 2)` về đích ngay lần đầu. | Không gặp khó khăn. | **Rất dễ hiểu** |
| **Level 02** | 2 lần | ~1 phút | Lần 1 thử tự đạp công tắc rồi chạy ra cửa nhưng thấy cửa đóng lại. Lần 2 bấm `END LOOP` tạo Echo 1 giữ công tắc và qua màn ngay. | Người chơi hiểu ngay vai trò của Echo mà không cần giải thích dài. | **Trực quan, dạy đúng cơ chế** |
| **Level 03** | 2 lần | ~1.5 phút | Lần 1 ở Vòng 2 đi thẳng không bấm `WAIT` nên đụng cửa đóng ở Tick 3 (cùng lúc Echo vừa bước lên công tắc). Lần 2 bấm `WAIT` 1 nhịp ở đầu vòng và qua cửa mượt mà. | Giúp người chơi nhận ra quy tắc: *"Cửa phải mở sẵn từ tick trước mới bước vào được"*. | **Nhịp độ tốt, thử thách vừa sức** |
| **Level 04** | 1 lần | ~1.5 phút | Nhận diện ngay 2 nhánh Bắc (có Switch) và Nam (có Door + Exit). Vòng 1 đi nhánh Bắc, Vòng 2 đi nhánh Nam và dùng `WAIT` 2 nhịp trước cửa chờ Echo tới đích. | Tường ngăn Bắc/Nam rất rõ ràng, không bị nhầm đường. | **Thiết kế không gian rõ ràng** |
| **Level 05** | 2 lần | ~2.5 phút | Quan sát thấy 2 công tắc ở 2 phòng trên/dưới và 1 cửa ở giữa. Lần 1 ở Vòng 3 quên bấm `WAIT` 1 nhịp nên tới cửa ở Tick 4 (khi 2 Echo mới vừa đạp công tắc). Lần 2 bấm `WAIT` 1 nhịp và thắng ở Tick 6. | Rất hào hứng khi thấy cả 2 bản sao (`Echo 1` xanh lam và `Echo 2` tím) cùng di chuyển mở cửa cho mình đi giữa. | **Đỉnh cao giải đố hợp lý, thỏa mãn** |

* **Tổng kết phản hồi Playtest:**
  - **Không phát hiện softlock**, không có màn nào bị kẹt trạng thái sau khi bấm `Restart` hoặc `Pause/Resume`.
  - Màu sắc 5 sprite vật thể Puzzle (`switch_off/on.png`, `door_closed/open.png`, `exit_portal.png`) và 3 nhân vật (`Player` cyan, `Echo 1` xanh dương mờ, `Echo 2` tím mờ) tương phản rõ, kể cả khi `Door` ở trạng thái mở và nhân vật đứng đè lên ô cửa.

---

## 5. Bảng Ghi nhận Kiểm thử Thiết bị Android Vật lý (Dành cho APK Candidate Sign-off)

Khi Leader xuất bản build APK từ **Issue #26**, cập nhật mã băm `SHA-256` và kết quả thực tế trên thiết bị Android vào bảng dưới đây để đóng hoàn toàn cổng nghiệm thu vật lý:

- **APK File Name:** `<điền tên file APK khi Leader bàn giao>`
- **APK SHA-256:** `<chạy Get-FileHash -Algorithm SHA256 <file.apk> và điền vào đây>`
- **Thiết bị Android / OS:** `<Model máy Android / Android Version>`
- **Người chạy trên thiết bị:** `<Tên người chạy>` — **Ngày chạy:** `<YYYY-MM-DD>`

| Màn chơi | Cài APK & Mở màn | Hiển thị Tile/Object $16:9$ | Đi theo `level_solutions.md` | Thử Pause / Resume / Restart | Kết quả trên Thiết bị Android | Minh chứng (Ảnh / Video) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **Level 01 — First Step** | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `NOT RUN` | Chờ APK từ #26 |
| **Level 02 — Hold the Door** | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `NOT RUN` | Chờ APK từ #26 |
| **Level 03 — Echo Memory** | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `NOT RUN` | Chờ APK từ #26 |
| **Level 04 — Two Paths** | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `NOT RUN` | Chờ APK từ #26 |
| **Level 05 — Double Echo** | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `WAIT_APK` | `NOT RUN` | Chờ APK từ #26 |

---

## 6. Kết luận

1. **Về dữ liệu màn chơi & logic giải đố (Level 01–05):** Cả 5 màn chơi trên `main` (`b1b48b0`) đã được kiểm chứng thực tế trên `scenes/gameplay/gameplay.tscn` (Godot 4.7.2) đạt **100% PASS** — không có lỗi tọa độ, không lệch sprite $48 \times 48$ px, không có đường đi tắt phá vỡ cơ chế và không cần sửa bất kỳ file `.tres` hay script `scripts/puzzle/*` nào.
2. **Về lộ trình độ khó & trải nghiệm người chơi:** 5 màn tăng tiến độ khó mượt mà từ `0 Echo` $\rightarrow$ `1 Echo giữ cửa` $\rightarrow$ `1 Echo canh nhịp WAIT` $\rightarrow$ `1 Echo chia 2 nhánh` $\rightarrow$ `2 Echo + AND 2 Switch`, đã có biên bản playtest thực tế từ người chơi độc lập.
3. **Về kiểm thử APK Android vật lý:** Tài liệu và kịch bản thao tác từng tick đã sẵn sàng 100%; các mục thiết bị vật lý được giữ trung thực ở trạng thái `WAIT_APK / NOT RUN` (tuân thủ `no invented PASS`) chờ bản APK candidate từ Leader (#26).
