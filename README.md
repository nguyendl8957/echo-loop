# Echo Loop — Mobile Puzzle Game

Đồ án thực tế Công nghệ phần mềm — Nhóm 5 sinh viên, UTH.

> **Trạng thái:** Skeleton v0.1.1. Mới có Main Menu, Gameplay placeholder và điều hướng. **Chưa có** Player, Time Loop, hệ thống màn chơi, Save hay Tutorial.

## Yêu cầu
- Godot 4.x **Standard / GDScript**, sử dụng cùng phiên bản Godot với nhóm trưởng.
- Windows 11 (máy phát triển); đầu ra dự kiến: APK Android.
- Không cần Firebase, máy chủ, Android Studio để chạy thử F5 trên PC. Android SDK + JDK chỉ phục vụ xuất APK.

## Mở và chạy thử
1. Clone repository (GitHub Desktop → File → Clone repository). **Không** clone đè vào thư mục đang có project.
2. Godot Project Manager → Import → chọn file `project.godot` trong thư mục vừa clone.
3. Mở project, đợi Godot import tài nguyên.
4. Nhấn **F5**: Main Menu xuất hiện; chọn **New Game** → Gameplay Test → **Back to Menu**.
5. Nhấn **F6** chỉ chạy scene đang mở.
6. Nếu lỗi, gửi ảnh tab Debugger/Output và ảnh cây Scene cho leader; đừng tự đổi tên node/path.

## Cấu trúc hiện có — KHÔNG di chuyển/đổi tên
```text
project.godot
scenes/menus/main_menu.tscn
scenes/gameplay/gameplay.tscn
scripts/core/main_menu.gd
scripts/core/gameplay.gd
```
Đây là các đường dẫn đã được nhóm trưởng dùng trong Skeleton. Các thư mục khác sẽ tạo dần khi có Issue tương ứng.

## Cây thư mục chuẩn cho các phần tiếp theo
```text
scenes/menus/       # TV4: scene menu hiện có; các menu mới
scenes/gameplay/    # Leader: Gameplay trung tâm; hạn chế sửa
scenes/player/      # TV2: Player / Echo visual
scenes/puzzle/      # TV3: công tắc/cửa/đích
scenes/ui/          # TV4: HUD / Pause / Tutorial / LevelSelect
scenes/tests/       # các scene F6 thử module
scripts/core/       # Leader: điều hướng, turn, time loop, điều phối
scripts/player/     # TV2: Player và Echo visual
scripts/puzzle/     # TV3: puzzle logic
scripts/ui/         # TV4: UI
scripts/data/       # TV5: lưu/đọc dữ liệu
assets/sprites/     # TV2/TV3/TV5 phối hợp
assets/audio/       # TV5
assets/fonts/       # TV4
data/levels/        # TV3
docs/               # tài liệu
tests/              # test cases / script kiểm thử
```
Các thư mục chưa có file có thể không xuất hiện sau clone vì Git không lưu thư mục rỗng.

## Luật gameplay bất biến (bản thiết kế 1.0)
- Grid top-down; action: `UP`, `DOWN`, `LEFT`, `RIGHT`, `WAIT`.
- Mỗi vòng 12 tick; bị chặn vẫn tiêu tốn tick; kết thúc sớm đệm `WAIT`.
- Tối đa 2 Echo; mỗi vòng reset vị trí và môi trường nhưng giữ lịch sử hành động của Echo.
- Xét cửa theo trạng thái **đầu tick**, di chuyển các nhân vật, sau đó cập nhật switch/door và kiểm tra thắng.
- Player có thể đi xuyên Echo. Chỉ Player tới EXIT mới thắng.
- MVP: 5 màn có lời giải; thêm màn nếu đủ thời gian.

## Quy ước làm việc
- Chưa được tự tạo/sửa GameManager, TurnManager, TimeLoopManager hoặc đổi API công khai nếu chưa có Issue và hợp đồng được leader phê duyệt.
- Trước khi code: đọc `docs/` (sổ tay 1.1, gameplay TXT, UML), Issue và module contract.
- Mỗi Issue → branch ngắn `feature/EL-XX-ten-tinh-nang` → tự test bằng F6/F5 → push → Pull Request.
- Không tự sửa `project.godot`, `scenes/gameplay/gameplay.tscn`, `scripts/core/` hoặc file của người khác nếu chưa thống nhất.
- PR phải ghi các file sửa, cách kiểm thử, kết quả, ảnh/video, rủi ro và phụ thuộc.
- `main` luôn chạy F5 từ menu tới Gameplay. Merge từng PR, không gom 4 nhánh cùng lúc.

## Đóng góp và bảo mật
- Không đưa `*.keystore`, mật khẩu, credential, file APK build và thư mục `.godot/` vào Git.
- Đồ án dùng Godot offline; Firebase không nằm trong phạm vi.
- Liên hệ leader trên kênh nhóm khi gặp lệch kiến trúc hoặc API chưa tồn tại.

---

## Cap nhat Sprint 04 - Tich hop 5 level

**Phien ban phat trien:** Godot 4.7.2 / GDScript.
**Pham vi:** Leader Integration - Issue #21.

Ghi chu: Thong tin Skeleton v0.1.1 o dau README la lich su
du an, khong con phan anh day du trang thai hien tai.

### Gameplay da tich hop

- Nap Level 01-05 qua `LevelManager`.
- Player, Echo, switch, door va Exit trong Gameplay.
- HUD hien thi Level, Tick, Loop va so Echo.
- Level Select kiem tra quyen mo khoa qua SaveManager.
- Thang man hien Level Complete.
- Next Level chi chuyen khi nguoi choi bam nut.
- Replay khoi tao lai luot choi va xoa Echo run cu.
- Pause / Resume / Restart / Main Menu.
- Save luu tien trinh mo khoa va tuy chon am thanh.

### Chay thu

1. Mo `project.godot` bang Godot 4.7.2.
2. Nhan F5 de vao Main Menu.
3. Chon New Game de choi Level 01.
4. Chon Continue de mo Level Select.
5. Hoan thanh man de mo khoa man tiep theo.
6. Su dung Pause de tam dung va Resume de choi tiep.

### Kiem thu Sprint 04

- `scenes/tests/sprint_04_flow_test.tscn`
- `scenes/tests/sprint_03_core_test.tscn`
- `scenes/tests/echo_test.tscn`
- `scenes/tests/puzzle_tick_test.tscn`
- `scenes/tests/levels_validation_test.tscn`

Leader da bao cao cac buoc F5/F6 tich hop PASS.
Ket qua chi tiet va bang chung can duoc dinh kem trong PR.
Viec nghiem thu Sprint 04 cuoi cung phu thuoc regression/QA
va review PR, khong chi dua tren viec game mo duoc.

### Quy uoc source

- Game Core: `scripts/core/`
- Gameplay scene: `scenes/gameplay/gameplay.tscn`
- Level Resources: `data/levels/`
- UI scenes: `scenes/ui/`
- SaveManager: `scripts/data/save_manager.gd`
- Test scripts: `tests/`

Khong thay doi luat 12 tick, toi da 2 Echo
hoac thu tu xu ly door snapshot.
