# Echo Loop — QA bản Final Polish

Kiểm tra trên Windows bằng Godot `4.7.2.stable.official.ed1daf0bf`. Nhánh `feature/EL-FINAL-polish` tại baseline `5aed183`. Mọi lượt kiểm tra có ghi Save dùng hồ sơ riêng để bảo toàn tiến trình chơi hiện có. [Lời giải 5 màn và bảng trạng thái từng tick](level_design_v2.md)

## Kết quả thực thi

| Bài kiểm tra | Kết quả |
|---|---|
| Import và khởi động main scene | Import thành công. Main Menu tải từ cấu hình project. |
| `levels_validation_test` | 39 PASS, 0 FAIL. Lời giải thắng ở các tick 6, 9, 10, 11, 12. Bộ duyệt kiểm tra giới hạn Echo và kiểm tra 9 lối qua cửa. |
| `level_01_test` | PASS. Pressure plate, liên kết cửa và Exit đúng dữ liệu. |
| `core_test`, `sprint_02_turn_test`, `sprint_03_core_test` | Lần lượt 26, 12 và 43 PASS, 0 FAIL. |
| `puzzle_test`, `puzzle_tick_test`, `replay_regression_test` | Lần lượt 31, 34 và 20 PASS, 0 FAIL. Replay cho cùng một trace trong 10 lần chạy. |
| `hud_test`, `hud_loop_test`, `hud_integration_test`, `sprint_04_flow_test` | HUD đạt 8 kiểm tra, các nhóm HUD loop và tích hợp đạt, flow đạt 25 kiểm tra. |
| `player_integration_test`, `actor_visual_test` | Lần lượt 31 và 17 PASS, 0 FAIL. |
| Windows GUI, 1280×720 và 960×540 | Mỗi kích thước đạt 40 PASS, 0 FAIL, cộng kiểm tra Back cuối và Exit. Chuột chạy lời giải cả 5 màn qua D-pad, kiểm tra WAIT, END LOOP, RESTART, Pause/Resume, Back/Esc, Unlock, Next, Replay và Sound. |
| `save_flow_test` trong phiên GUI | 16 PASS, 0 FAIL cho Save/Audio và 10 PASS, 0 FAIL cho dữ liệu level. Hai trường hợp fixture bỏ qua được thực thi qua GameManager trong lượt GUI, gồm Replay giữ mốc unlock và thắng Level 05 vẫn lưu tối đa 05. |
| Android, APK cuối | NOT RUN. Cần kiểm thử cảm ứng, vùng an toàn, Back vật lý, âm thanh, hiệu năng và chạy ngoại tuyến trên thiết bị từ APK của bản này. |

Godot chạy các scene test trực tiếp ở chế độ headless. Ví dụ lệnh PowerShell từ thư mục gốc dự án.

```powershell
$godot = 'D:/ADMIN/Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path . --editor --import
& $godot --headless --path . --scene res://scenes/tests/levels_validation_test.tscn --quit-after 120
& $godot --headless --path . --scene res://scenes/tests/sprint_03_core_test.tscn --quit-after 80
& $godot --headless --path . --scene res://scenes/tests/puzzle_tick_test.tscn --quit-after 80
& $godot --headless --path . --scene res://scenes/tests/replay_regression_test.tscn --quit-after 80
```

Đổi đường dẫn sau `--scene` để chạy các scene test khác trong `scenes/tests/`. Bài GUI dùng cùng engine với trình kết xuất Compatibility và gửi click chuột tới các Button thật.

## Giải thích thuật toán khi vấn đáp

1. `TurnManager.submit_player_action()` kiểm tra action, lấy action Echo theo chỉ số tick, ghi action Player rồi phát signal để `Gameplay` xử lý tick.
2. `Gameplay` lấy tường và trạng thái cửa trước khi bất kỳ actor nào di chuyển. Player và Echo cùng dùng snapshot này để kiểm tra ô đích. WAIT và lệnh bị tường chặn vẫn đã được ghi, nên tick vẫn tính.
3. Sau khi mọi actor di chuyển, `PressureSwitch` xét ô nào đang có actor. `Door` mở khi mọi công tắc liên kết đều hoạt động. Cửa vừa mở có thể vào từ tick kế tiếp. Actor đứng trong ô cửa vẫn được đi ra nếu ô đích hợp lệ.
4. Chỉ tọa độ Player được so với Exit để kết thúc màn. Sau đó TurnManager phát `tick_finished` để HUD hiển thị số tick, loop và Echo hiện có.
5. Ở vòng 1 và 2, `TimeLoopManager.end_loop()` đệm WAIT tới 12 và lưu một bản sao action. `Gameplay` đưa các actor về Start và reset Switch/Door. Echo được tạo theo mỗi bản ghi, đọc đúng action của tick rồi kiểm tra va chạm của thế giới hiện tại.
6. Khi hết vòng 3, game khóa lượt nếu Player chưa thắng. Restart tải lại màn và chỉ reset run. Level 04–05 dùng WAIT để canh lúc một Echo chuyển công tắc. Việc đứng yên đúng nhịp có thể đạt bằng WAIT hoặc bằng hành động di chuyển bị chặn.

## Những file được sửa

| Nhóm | File | Mục đích |
|---|---|---|
| Puzzle | `data/levels/level_01.tres` đến `level_05.tres` | Năm bản đồ 13×9 dùng cấu trúc LevelData hiện có. |
| Hiển thị Gameplay | `scripts/core/gameplay.gd`, `scenes/gameplay/gameplay.tscn`, `scripts/player/echo_controller.gd`, `scenes/player/player.tscn` | Dựng lớp hiển thị, căn bản đồ, nhãn liên kết cửa, dấu Player, vòng sáng và vệt Echo. |
| Giao diện | `scenes/menus/main_menu.tscn`, `scenes/ui/{tutorial,level_select,hud,pause_menu,level_complete}.tscn`, `scripts/ui/{level_select,hud,level_complete}.gd` | Dùng chung theme, cải thiện menu, HUD và lớp phủ. Xử lý Esc ở Level Select trước khi đổi scene để viewport còn hợp lệ. |
| Thêm mới | `scripts/core/lab_board.gd` và UID, `scenes/ui/lab_theme.tres`, `assets/sprites/environment/lab_background.png`, `assets/sprites/lab_controls.png`, `assets/fonts/Oxanium.ttf` và giấy phép OFL, metadata import cho ba asset | Một lớp hiển thị dùng cho mọi bản đồ, một theme, một ảnh nền, một atlas icon và một font ngoại tuyến. |
| Test và tài liệu | `tests/{levels_validation_test,replay_regression_test}.gd`, `scenes/tests/level_01_test.gd`, README, hướng dẫn tiếng Việt, báo cáo QA, tài liệu lời giải Sprint 03–05 và lời giải V2 | Phát lại hành động qua Gameplay, kiểm tra số Echo, kiểm tra cửa bắt buộc và đánh dấu tài liệu lịch sử. Fixture replay dùng scene Switch/Door/Exit để cung cấp đúng node Sprite2D. |

So với ảnh demo, bản Windows có lab navy với console ở hai bên, sàn và khung kim loại, top HUD, Pause ở góc phải, D-pad trái và ba nút hành động phải. Player dùng sprite gốc và có dấu tam giác. Cổng tím dùng sprite xoáy gốc trong khung sáng của một ô. Thiết kế dùng màu và dáng actor hiện có, nền lab riêng và bản đồ khác nhau theo cơ chế từng màn.

Ảnh nền lab được tạo riêng cho game. Font được đóng gói cùng giấy phép OFL để hiển thị ngoại tuyến. [Nguồn font Oxanium](https://github.com/google/fonts/tree/main/ofl/oxanium)

`TurnManager`, `TimeLoopManager`, `GameManager`, cấu trúc Save và cấu hình Android/branding dùng nguyên bản baseline. Các nút tiếp tục phát signal cũ. Tệp import và UID có từ trước được đối chiếu hash.

## Kiểm tra trong editor và trên điện thoại

1. Mở `project.godot` bằng Godot 4.7.2 Standard. Đợi import và nhấn **F5** để vào Main Menu theo cấu hình dự án.
2. Chọn **How to play** rồi **Back**. Chọn **Continue** và kiểm tra thẻ khóa theo tiến trình hiện tại.
3. Chọn **New Game**. Thử WAIT, Pause/Esc, Resume và Restart. Chơi Level 01 theo lời giải V2, rồi đi tiếp qua **Next Level**.
4. Mở `scenes/tests/levels_validation_test.tscn`, nhấn **F6** và xem dòng `LEVELS VALIDATION: 39 PASS / 0 FAIL` trong Output. Dùng F6 cho `sprint_03_core_test.tscn` và `puzzle_tick_test.tscn` để xem các kiểm tra snapshot riêng.
5. Từ APK của bản polish, thử các thao tác trên điện thoại landscape. Xác minh vùng chạm cạnh màn hình, Back vật lý, âm thanh sau khi khởi động lại và lưu tiến trình trong chế độ offline. Dùng lời giải từng tick để phát lại Level 04–05.

---

## Báo cáo Sprint 05 trước đợt polish

**DRAFT — NOT RELEASE APPROVAL**

**Issue:** [#30 — S05-TV5](https://github.com/nguyendl8957/echo-loop/issues/30)  
**Owner:** TV5  
**Ngày lập:** 2026-11-23 (Asia/Ho\_Chi\_Minh)  
**Branch PR:** `feature/EL-S05-TV5`
**Release gate:** **BLOCKED — chưa có APK candidate / Android run evidence**

## 1\. Mục đích và phạm vi

Báo cáo tổng hợp kiểm tra tĩnh source, tài liệu đã có và kế hoạch QA Android cho sản phẩm Echo Loop. TV5 không sửa game logic, config, scene, `project.godot`, assets hoặc module của thành viên khác trong Issue này.

Các kết luận trong báo cáo được phân biệt thành:

* **Source review:** đọc cấu trúc/code/resource từ source ZIP; không phải kiểm thử runtime.
* **Reported result:** kết quả được ghi trong tài liệu trước đó của nhóm, chưa được TV5 chạy lại trên APK.
* **Android runtime result:** chỉ được cập nhật khi có APK candidate, commit SHA, APK SHA-256, thiết bị/OS và evidence thực tế.

## 2\. Build / source identity

|Trường|Giá trị|
|-|-|
|Repository|`https://github.com/nguyendl8957/echo-loop`|
|Source ZIP kiểm tra|`echo-loop(8).zip`|
|Nhánh snapshot|`main`|
|HEAD trong ZIP|`b1b48b027bb5714e3c58832ed51d0f30563bacb4`|
|Commit|Merge PR #51 — `feature/EL-S05-L`|
|Commit date|2026-11-20 23:01:42 +07:00|
|Lịch sử `main` trong ZIP|60 commits|
|Trạng thái working tree|Dirty: có 4 tracked changes và 3 file `.uid` chưa tracked|
|Godot theo Android export guide|4.7.2 stable (chưa chạy xác minh lại trong môi trường này)|
|APK filename / version|Chưa cung cấp|
|APK build commit SHA|Chưa xác định|
|APK SHA-256|Chưa cung cấp|
|Android device / OS|Chưa cung cấp|
|Testers / test date trên thiết bị|Chưa có|

### 2.1. Đối chiếu latest source

* Git metadata của ZIP cho thấy `main` và `origin/main` đang trỏ cùng commit `b1b48b0…`; `git rev-list --count main` cho kết quả 60.
* Trang public repository GitHub hiện hiển thị 60 commits và Issue #30 vẫn Open, chưa có branch/PR liên kết tại thời điểm truy cập.
* Tuy nhiên, `git ls-remote origin` từ môi trường thực hiện không thành công do DNS không phân giải được `github.com`. Không thể khẳng định live HEAD SHA tuyệt đối từ lần rà soát này. Cần chạy `git fetch origin`/`git pull origin main` trên máy nhóm trước khi tạo branch/PR.
* `feature/EL-S05-TV5` chưa có trong refs của ZIP; snapshot có refs `feature/EL-S05-L` và `feature/EL-S05-TV4`.

**Lưu ý làm việc:** Không dùng `git add .`. ZIP có thay đổi sẵn ở `assets/audio/click\_sound.mp3.import`, `assets/audio/level\_up\_sound.mp3.import`, `icon.svg.import`, `tests/test\_matrix.md`, cộng thêm `scripts/data/audio\_manager.gd.uid`, `scripts/data/save\_manager.gd.uid`, `tests/save\_flow\_test.gd.uid`. Bảo toàn những thay đổi này và chỉ stage 5 file thuộc Issue #30.

## 3\. Source review findings

### 3.1. Levels và gameplay

* Tìm thấy đủ `data/levels/level\_01.tres` đến `level\_05.tres`.
* Level ID 1–5 có tên: First Step, Hold the Door, Echo Memory, Two Paths, Double Echo.
* `LevelManager.MIN\_LEVEL = 1`, `MAX\_LEVEL = 5`.
* `TimeLoopManager.MAX\_TICKS = 12`, `MAX\_ECHOES = 2`; `end\_loop()` đệm `WAIT` tới đủ 12 action. Sau vòng cuối, run chuyển sang trạng thái thất bại nếu chưa thắng.
* `GameManager.complete\_level()` sử dụng giá trị unlock hiện tại và level vừa hoàn thành, sau đó giới hạn trong 1–5.
* Source có Main Menu, Level Select, Tutorial, HUD, Pause Menu và Level Complete. Đây là kiểm tra hiện diện code/resource, không chứng minh UI hoạt động trên thiết bị.

### 3.2. Save và Audio

* `SaveManager` ghi đúng hai trường `unlocked\_level`, `sound\_enabled`; không ghi loop, tick, Echo/action history hay vị trí nhân vật.
* `GameManager.\_initialize\_audio()` đọc `sound\_enabled` từ SaveManager khi Autoload khởi tạo và áp dụng lên AudioManager.
* `GameManager.set\_sound\_enabled()` ghi preference và cập nhật AudioManager; AudioManager chặn phát khi disabled và mute Master bus.
* **Source-level gap:** chưa tìm thấy Settings scene, Sound CheckButton hoặc UI caller gọi `GameManager.set\_sound\_enabled()`. Do đó, kiểm thử bật/tắt Sound như người chơi thực hiện đang BLOCKED cho tới khi Leader/TV4 xác nhận cách truy cập hoặc xử lý bằng Issue riêng. Xem `docs/known\_issues.md` KI-01.

### 3.3. Android export / orientation

* `docs/android\_export\_guide.md` ghi Godot 4.7.2 stable, GL Compatibility, Android landscape; yêu cầu export preset, SDK/JDK và export templates được cấu hình tại máy build.
* File `project.godot` trong ZIP không có cấu hình orientation rõ ràng.
* `.gitignore` bỏ qua `export\_presets.cfg`; không có APK candidate trong ZIP.
* Guide hiện ghi APK export, cài đặt Android và full gameplay regression là NOT RUN. Vì vậy chưa có căn cứ xác nhận landscape, permission, install, launch, FPS, touch layout hoặc offline trên thiết bị.

### 3.4. Security / clean clone

* Không tìm thấy file APK/AAB/keystore/JKS/P12/PFX/PEM hoặc export preset trong các file được Git index theo snapshot.
* Scan pattern giới hạn trên working tree: không phát hiện private-key header, token dạng GitHub token, Google API key shape hoặc AWS access-key shape.
* Đây **không phải** full Git-history secret scan, GitHub secret scanning hoặc kiểm tra toàn bộ commit trên remote. Cần Leader chạy scan repository/history và xác nhận trước release.
* Clean clone → import → F5 chưa được thực hiện trong lượt rà soát này. Không có Godot CLI/GUI khả dụng trong môi trường thực hiện.

## 4\. Kết quả QA Android

|Nhóm|Kết quả hiện tại|Kết luận|
|-|-|-|
|Install / launch / splash|NOT RUN|Không có APK candidate|
|Main Menu / Tutorial / Level Select|NOT RUN trên Android|Hiện diện scene/script trong source; chưa test device|
|Level 01–05 E2E|NOT RUN trên Android|Có 5 Resource và tài liệu lời giải; chưa xác minh trên APK|
|12 tick / 2 Echo / replay / door snapshot|NOT RUN trên Android|Có code và F6 suites trong source; chưa test APK|
|Pause / Resume / Restart / Result / Next|NOT RUN trên Android|Có source flow; chưa test APK|
|Save persistence sau close/reopen|NOT RUN trên Android|Có API/flow trong source; cần test thiết bị|
|Sound settings từ UI|BLOCKED|Không thấy UI control/caller trong source|
|Landscape / aspect ratio / touch|NOT RUN|Cần APK và thiết bị thật|
|Offline / Android permission|NOT RUN|Chưa có APK/manifest candidate|
|Clean clone / F5|NOT RUN trong lượt này|Cần thực hiện trên máy nhóm bằng Godot 4.7.2|
|Secret scan toàn bộ lịch sử|BLOCKED|Mới scan giới hạn working tree/index|

Chi tiết từng case, metadata lặp theo yêu cầu Issue và chỗ gắn bằng chứng nằm trong `tests/android\_test\_matrix.md`.

## 5\. Kết quả cũ được báo cáo trong tài liệu nhóm (không phải Android QA)

`tests/sprint\_04\_regression.md` trong source ZIP có mục **Sprint 04 - Final Integration Verification (2026-11-20)** ghi các kết quả được Leader báo cáo:

* Save/Audio fixture F6: 16 PASS / 0 FAIL / 2 NOT RUN.
* Level Resource F6: 10 PASS / 0 FAIL / 0 NOT RUN.
* Sprint 04 Flow F6: 26 PASS / 0 FAIL.
* Sprint 03 Core F6: 43 PASS / 0 FAIL.
* Levels Validation F6: 152 PASS / 0 FAIL.
* F5 được báo cáo PASS cho Level 03 → 04 → 05, Level 05 với 2 Echo, unlock cap, save persistence, Audio ON/OFF/restore, Tutorial, Pause, Next và Replay.

Đây là thông tin lịch sử do Leader ghi trong tài liệu; không phải kết quả TV5 chạy lại và **không chứng minh APK Android Sprint 05 đã đạt**. Không sử dụng các PASS này để điền PASS vào matrix Android mới.

## 6\. Defects / release risks

1. **KI-01 — Sound setting chưa có UI entry point trong source review:** BLOCKED cho test người chơi; cần Leader/TV4 xác nhận owner/giải pháp.
2. **KI-02 — Landscape phụ thuộc export preset local:** cần Leader xác nhận preset thực tế và test trên thiết bị; chưa có orientation setting trong `project.godot`.
3. **KI-03 — APK candidate và identity chưa có:** chưa thể liên kết bất kỳ test nào với build commit/APK hash.
4. **KI-04 — Device, touch, aspect ratio, offline, permission và clean clone chưa có evidence:** là khoảng trống QA, chưa kết luận có bug.
5. **KI-05 — README cần Leader review:** chỉ cập nhật link evidence sau khi Leader đồng ý theo Issue #30.

Xem `docs/known\_issues.md` để biết mô tả, mức độ, owner và cách đóng từng mục.

## 7\. Kết luận / release gate

**Kết quả hiện tại: BLOCKED — NOT READY FOR RELEASE ACCEPTANCE.**

Lý do: chưa có APK candidate, build commit SHA, APK SHA-256 và thiết bị Android để chạy matrix; Sound setting UI chưa xác định được lối thao tác; các yêu cầu Android landscape/touch/offline/permissions/close-reopen/clean clone chưa có evidence.

Gate chỉ được nâng lên khi:

* Có APK ổn định và source commit tương ứng.
* Các test Android có kết quả và evidence; không còn blocker/crash chưa xử lý.
* Ma trận ghi đủ metadata từng dòng.
* Known issues phản ánh trung thực trạng thái cuối.
* User guide khớp APK cuối.
* Các testers ký/xác nhận report và Leader duyệt release gate.

## 8\. Xác nhận của testers và Leader (chưa ký)

|Vai trò|Họ tên / GitHub|Xác nhận / ngày|Ghi chú|
|-|-|-|-|
|TV5 — QA tổng hợp|TRAN HUU PHUC|Chờ test APK||
|TV2 — Player/Echo|NGUYEN THE HOANG BACH|Chờ evidence module/device||
|TV3 — Puzzle/Level|DANG PHAM GIA HUY|Chờ evidence 5 level/device||
|TV4 — UI/Tutorial|LE TRUNG TIN|Chờ evidence UI/device||
|Leader — Release approval|DANG LAM NGUYEN|Chưa phê duyệt||

**Báo cáo này là bản nháp dựa trên source ZIP và tài liệu nhóm ngày 2026-11-23. Không phải chứng nhận APK đã qua QA.**

