# S05-TV5 — Final QA Report

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

