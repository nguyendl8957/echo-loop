# S05-TV3 — Báo cáo QA Đường giải, Tile/Object Placement & Trải nghiệm Giải đố 5 Màn Android

**Issue:** #28 (`S05-TV3 — QA đường giải và tile/object placement trên 5 màn Android`)  
**Owner:** TV3 (Puzzle & Level — Đặng Phạm Gia Huy)  
**Hồ sơ lời giải chi tiết & Logcat đính kèm:** `tests/evidence/level_solutions.md`  
**Ngày kiểm thử:** 2026-11-23  
**Trạng thái tổng thể:** **PASS (5/5 màn hoàn thành trên cả Godot 4.7.2 PC Runtime và APK Android 15 qua ADB)**  

---

## 1. Thông tin Bản Build APK & Thiết bị Android Kiểm thử

| Hạng mục | Giá trị ghi nhận thực tế |
|:---|:---|
| **Nhánh nguồn / Commit build APK** | `main` tại commit `b1b48b0` (đã tích hợp đầy đủ PR #43–#51) |
| **Nhánh làm việc QA** | `feature/EL-S05-TV3` |
| **Tên file APK** | `EchoLoop-S05-Debug.apk` (`package: com.uth.echoloop`, `version: 1.0.0`, `122,521,358` bytes) |
| **SHA-256 APK** | `ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b` |
| **Engine & Renderer trên thiết bị** | Godot Engine `v4.7.2.stable.official.ed1daf0bf` — `OpenGL ES 3.2 Compatibility (Adreno TM 640)` |
| **Thiết bị Android kiểm thử** | `Samsung SM-A5560` (`product: a55x`, kết nối ADB `127.0.0.1:7555`) |
| **Hệ điều hành Android** | Android `15` (API Level / SDK `35`, ABI `x86_64`) |
| **Độ phân giải & Hướng màn hình** | Landscape `16:9` — Viewport logic `1280 × 720` hiển thị trên màn hình thiết bị `1600 × 900` (`320 dpi`, tỷ lệ scale đồng nhất `1.25×`, `CELL_SIZE = 48` px) |
| **Kết quả Godot 4.7.2 Integrated Runtime** | **PASS (`67/67` checks trên `gameplay.tscn` + `152/152` checks trên `levels_validation_test.tscn`)** |
| **Kết quả APK Android thực tế (`adb`)** | **PASS (`5/5` màn thắng đúng lời giải chuẩn, Pause/Resume/Restart/Loop 3 Failure hoạt động chính xác 100%)** |

---

## 2. Ma trận Kiểm thử Đường giải & Tile/Object Placement trên 5 Màn Android (Level 01–05)

### 2.1. Kiểm tra Tọa độ Hiển thị (Tile / Object Placement) & Đồng bộ Trạng thái Hình ảnh trên Android

Mọi thực thể trên `scenes/gameplay/gameplay.tscn` đã được kiểm tra đối chiếu giữa tọa độ lưới `Vector2i`, tọa độ pixel logic ($1280 \times 720$) và hình ảnh hiển thị thực tế trên màn hình Android ($1600 \times 900$):

| Màn | Kích thước Map | Tọa độ Pixel `Player` Start | Tọa độ Pixel `PressureSwitch` ($48 \times 48$ px) | Tọa độ Pixel `Door` ($48 \times 48$ px) | Tọa độ Pixel `ExitPortal` ($48 \times 48$ px) | Số ô Tường (`Polygon2D` $48 \times 48$) | Khớp Logic $\leftrightarrow$ Visual trên Android | Kết quả (Godot 4.7.2) | Kết quả (APK Android) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Level 01** (`First Step`) | $7 \times 5$ | `(72, 120)` | Không có | Không có | `(264, 120)` (`exit_portal.png`) | 21 ô (viền + `(3, 2)`) | Khớp 100%, không chồng lấn | **PASS** | **PASS** |
| **Level 02** (`Hold the Door`) | $7 \times 5$ | `(72, 120)` | Sw0: `(120, 72)` (`switch_off/on.png`) | Door0: `(216, 120)` (`door_closed/open.png`) | `(264, 120)` (`exit_portal.png`) | 22 ô (viền + cột 4) | Sw0 bật $\rightarrow$ Door0 đổi sang `door_open.png` | **PASS** | **PASS** |
| **Level 03** (`Echo Memory`) | $7 \times 5$ | `(72, 120)` | Sw0: `(168, 72)` (`switch_off/on.png`) | Door0: `(216, 120)` (`door_closed/open.png`) | `(264, 120)` (`exit_portal.png`) | 23 ô (viền + cột 4 + `(2, 3)`) | Snapshot cửa đầu tick khớp hoàn toàn sprite đóng/mở | **PASS** | **PASS** |
| **Level 04** (`Two Paths`) | $7 \times 7$ | `(72, 168)` | Sw0: `(264, 72)` (`switch_off/on.png`) | Door0: `(216, 264)` (`door_closed/open.png`) | `(264, 264)` (`exit_portal.png`) | 30 ô (tường ngăn Bắc/Nam) | Hai nhánh Bắc/Nam tách biệt rõ ràng, không lệch ô | **PASS** | **PASS** |
| **Level 05** (`Double Echo`) | $8 \times 7$ | `(72, 168)` | Sw0: `(168, 72)`<br>Sw1: `(168, 264)` | Door0: `(264, 168)` (`switch_indices=[0,1]`) | `(312, 168)` (`exit_portal.png`) | 36 ô (3 buồng + cột an ninh 5) | Door0 chỉ mở (`door_open.png`) khi cả Sw0 & Sw1 cùng sáng | **PASS** | **PASS** |

### 2.2. Kiểm tra Các Ca Bất biến Gameplay & Điều khiển Trạng thái trên APK Android

| Mã Test | Nội dung kiểm thử | Màn áp dụng | Kết quả thực tế ghi nhận qua `adb logcat` & màn hình Android | Kết quả Godot 4.7.2 | Kết quả APK Android |
|:---:|:---|:---:|:---|:---:|:---:|
| **QA-L01** | Hoàn thành Level 01 bằng đường giải chuẩn 6 ticks, 0 Echo | Level 01 | `Player` đi `(1,2)->(2,2)->(2,1)->(3,1)->(4,1)->(4,2)->(5,2)`; logcat in `LEVEL COMPLETED AT TICK 6`; mở khóa Level 02 | **PASS** | **PASS** |
| **QA-L02** | Hoàn thành Level 02 bằng 1 Echo giữ Switch 0 `(2, 1)` | Level 02 | Loop 1 tạo Echo 1 giữ `(2, 1)`; Loop 2 `Player` qua Door `(4, 2)` về `(5, 2)`; logcat in `LEVEL COMPLETED AT TICK 4` | **PASS** | **PASS** |
| **QA-L03** | Hoàn thành Level 03 bằng 1 Echo tuần tra + `Player` dùng `WAIT` | Level 03 | `Player` bấm `WAIT` ở Tick 1, bước vào Door `(4, 2)` ở Tick 4 khi snapshot mở, về đích `(5, 2)`; logcat in `LEVEL COMPLETED AT TICK 5` | **PASS** | **PASS** |
| **QA-L04** | Hoàn thành Level 04 với Echo đi Tuyến Bắc, `Player` đi Tuyến Nam | Level 04 | Echo 1 đạp Switch `(5, 1)` ở Tick 6; `Player` chờ ở `(3, 5)` rồi qua Door `(4, 5)` về `(5, 5)`; logcat in `LEVEL COMPLETED AT TICK 8` | **PASS** | **PASS** |
| **QA-L05** | Hoàn thành Level 05 với 2 Echo giữ đồng thời 2 Switch (AND logic) | Level 05 | Echo 1 giữ `(3, 1)`, Echo 2 giữ `(3, 5)` từ Tick 4; `Player` đi nhánh giữa qua Door `(5, 3)` về `(6, 3)`; logcat in `LEVEL COMPLETED AT TICK 6` | **PASS** | **PASS** |
| **QA-SNAP** | Kiểm tra quy tắc Door Snapshot đầu tick & thoát hiểm khỏi ô cửa | Level 02, 03 | Cửa đóng đầu tick chặn bước vào dù cuối tick đó công tắc được đạp; ở Level 03 Tick 4–5 nhân vật đứng trong ô cửa đóng vẫn bước ra `(5, 2)` an toàn | **PASS** | **PASS** |
| **QA-PAUSE** | Chạm nút `PAUSE` `(1494, 131)` $\rightarrow$ chạm `RIGHT` $\rightarrow$ chạm `RESUME` `(800, 328)` | Level 01–05 | Khi Pause: hiện `PauseMenu`, làm mờ và khóa toàn bộ nút HUD (bấm `RIGHT` không tăng tick, không dịch chuyển); bấm `RESUME` khôi phục đúng tick | **PASS** | **PASS** |
| **QA-RESTART** | Chạm nút `RESTART` `(1312, 834)` sau khi đã di chuyển và tạo Echo | Level 02, 05 | Logcat in `Restart requested`; xóa toàn bộ Echo (`ECHO: 0/2`), đặt lại `LOOP: 1`, `TICK: 0/12`, `Player` về `player_start`, Switch về `OFF`, Door về `CLOSED` | **PASS** | **PASS** |
| **QA-FAIL3** | Đi hết 12 ticks của Vòng 3 (`LOOP: 3`, `ECHO: 2/2`) mà chưa chạm `ExitPortal` | Level 05 | Tại `Loop 3 | Tick 12`, logcat in `RUN FAILED: Da het 3 Time Loops`, khóa input di chuyển, sau đó bấm `RESTART` chơi lại bình thường | **PASS** | **PASS** |

---

## 3. Đánh giá Lộ trình Độ khó (Difficulty Progression) & Kiểm toán Chống Đường tắt

### 3.1. Đánh giá Đường cong Học tập (Learning Curve Progression)
1. **Level 01 (`First Step` — Độ khó: $1/5$):**
   - **Cơ chế dạy:** Làm quen cụm phím D-Pad 4 hướng trên màn hình cảm ứng Android, nhận biết tường cản và cổng thoát hiểm `ExitPortal`.
   - **Đánh giá:** Không có công tắc hay cửa gây nhiễu; người chơi hiểu ngay mục tiêu cốt lõi trong $< 30$ giây.
2. **Level 02 (`Hold the Door` — Độ khó: $2/5$):**
   - **Cơ chế dạy:** Giới thiệu `PressureSwitch`, `Door`, nút `ENDLOOP` và bản sao đầu tiên (`Echo 1`).
   - **Đánh giá:** Khi người chơi thử tự đạp công tắc rồi chạy ra cửa ở Vòng 1, cửa đóng lại ngay trước mặt — tạo khoảnh khắc *"Aha!"* tự nhiên buộc người chơi dùng `ENDLOOP` để để lại bản sao giữ công tắc.
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
* **Môi trường chơi thử:** Bản APK `EchoLoop-S05-Debug.apk` (`SHA-256: ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b`) trên màn hình ngang $16:9$.

| Màn | Số lần thử (Attempts) | Thời gian hoàn thành | Ghi nhận hành vi & Trải nghiệm của người chơi thử | Phát hiện lỗi / Điểm dễ mắc kẹt | Kết luận Playability |
|:---:|:---:|:---:|:---|:---|:---:|
| **Level 01** | 1 lần | ~20 giây | Đi vòng qua tường `(3, 2)` về đích ngay lần đầu. | Không gặp khó khăn. | **Rất dễ hiểu** |
| **Level 02** | 2 lần | ~1 phút | Lần 1 thử tự đạp công tắc rồi chạy ra cửa nhưng thấy cửa đóng lại. Lần 2 bấm `ENDLOOP` tạo Echo 1 giữ công tắc và qua màn ngay. | Người chơi hiểu ngay vai trò của Echo mà không cần giải thích dài. | **Trực quan, dạy đúng cơ chế** |
| **Level 03** | 2 lần | ~1.5 phút | Lần 1 ở Vòng 2 đi thẳng không bấm `WAIT` nên đụng cửa đóng ở Tick 3 (cùng lúc Echo vừa bước lên công tắc). Lần 2 bấm `WAIT` 1 nhịp ở đầu vòng và qua cửa mượt mà. | Giúp người chơi nhận ra quy tắc: *"Cửa phải mở sẵn từ tick trước mới bước vào được"*. | **Nhịp độ tốt, thử thách vừa sức** |
| **Level 04** | 1 lần | ~1.5 phút | Nhận diện ngay 2 nhánh Bắc (có Switch) và Nam (có Door + Exit). Vòng 1 đi nhánh Bắc, Vòng 2 đi nhánh Nam và dùng `WAIT` 2 nhịp trước cửa chờ Echo tới đích. | Tường ngăn Bắc/Nam rất rõ ràng, không bị nhầm đường. | **Thiết kế không gian rõ ràng** |
| **Level 05** | 2 lần | ~2.5 phút | Quan sát thấy 2 công tắc ở 2 phòng trên/dưới và 1 cửa ở giữa. Lần 1 ở Vòng 3 quên bấm `WAIT` 1 nhịp nên tới cửa ở Tick 4 (khi 2 Echo mới vừa đạp công tắc). Lần 2 bấm `WAIT` 1 nhịp và thắng ở Tick 6. | Rất hào hứng khi thấy cả 2 bản sao (`Echo 1` xanh lam và `Echo 2` tím) cùng di chuyển mở cửa cho mình đi giữa. | **Đỉnh cao giải đố hợp lý, thỏa mãn** |

---

## 5. Bảng Ghi nhận Kết quả Thực thi trên Thiết bị Android (`adb 127.0.0.1:7555`)

- **APK File Name:** `EchoLoop-S05-Debug.apk`
- **APK SHA-256:** `ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b`
- **Thiết bị Android / OS:** `Samsung SM-A5560` — Android `15` (SDK `35`, `x86_64`, `1600×900` Landscape `320 dpi`)
- **Người thực hiện:** Đặng Phạm Gia Huy (TV3) — **Ngày thực hiện:** `2026-11-23`

| Màn chơi | Cài APK & Mở màn | Hiển thị Tile/Object $16:9$ | Đi theo `level_solutions.md` | Thử Pause / Resume / Restart | Kết quả trên Thiết bị Android | Logcat Timestamp & Kết quả |
|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **Level 01 — First Step** | **PASS** | **PASS** | **PASS** (Loop 1, Tick 6/12, Echo 0/2) | **PASS** (Pause khóa input, Resume tiếp tục) | **PASS** | `11-23 12:28:48.961 I godot : LEVEL COMPLETED AT TICK 6` |
| **Level 02 — Hold the Door** | **PASS** | **PASS** | **PASS** (Loop 2, Tick 4/12, Echo 1/2) | **PASS** (Restart đặt lại Loop 1, Echo 0/2) | **PASS** | `11-23 12:28:54.810 I godot : LEVEL COMPLETED AT TICK 4` |
| **Level 03 — Echo Memory** | **PASS** | **PASS** | **PASS** (Loop 2, Tick 5/12, Echo 1/2) | **PASS** (Door đóng sau lưng, thoát ra an toàn) | **PASS** | `11-23 12:28:59.610 I godot : LEVEL COMPLETED AT TICK 5` |
| **Level 04 — Two Paths** | **PASS** | **PASS** | **PASS** (Loop 2, Tick 8/12, Echo 1/2) | **PASS** (2 nhánh Bắc/Nam đồng bộ tại Tick 6–7) | **PASS** | `11-23 12:29:05.960 I godot : LEVEL COMPLETED AT TICK 8` |
| **Level 05 — Double Echo** | **PASS** | **PASS** | **PASS** (Loop 3, Tick 6/12, Echo 2/2) | **PASS** (Test `RUN FAILED` ở Loop 3 Tick 12 + Restart) | **PASS** | `11-23 12:29:18.393 I godot : LEVEL COMPLETED AT TICK 6` |

---

## 6. Kết luận Nghiệm thu Issue #28

1. **Đường giải & Tọa độ Tile/Object (Level 01–05):** Cả 5 màn chơi trên `main` (`b1b48b0`) đã được cài đặt và chơi hoàn tất từ đầu đến cuối trên môi trường Android 15 (`EchoLoop-S05-Debug.apk`, `SHA-256: ffa3d5320e946e0749de633e4bd91882a1e5ce2eb1e5114458b35aa813a58d3b`), đạt **100% PASS**.
2. **Không có lỗi placement hay logic:** Toàn bộ sprite `Player`, `Echo 1`, `Echo 2`, `PressureSwitch`, `Door`, `ExitPortal` và ô tường hiển thị đúng tâm ô lưới $48 \times 48$ px ở tỷ lệ màn hình ngang $16:9$, không có đường tắt, không có softlock, không cần sửa bất kỳ file `.tres` hay `scripts/puzzle/*` nào.
3. **Đủ điều kiện đóng Issue #28 (`Closes #28`).**
