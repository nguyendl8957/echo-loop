# S04-TV5 — Save/Audio Integration \& 5-Level End-to-End Regression

**Issue:** #25  
**Owner:** TV5  
**Branch dự kiến:** `feature/EL-S04-TV5`  
**Engine trên máy kiểm thử:** Godot 4.7.2.stable  
**Ngày chạy F6:** 2026-11-17  
**Trạng thái cập nhật:** Đã chạy F6 Save/Audio và Level Resource Check; kết quả được ghi ở các mục bên dưới. Đây chưa phải xác nhận Sprint 04 PASS.

## 1\. Phạm vi và file bàn giao

TV5 phụ trách regression QA và Save/Audio test fixture. Bộ file của Issue:

* `tests/sprint\\\_04\\\_regression.md`
* `scenes/tests/save\\\_flow\\\_test.tscn`
* `tests/save\\\_flow\\\_test.gd`

Chỉ sửa các file sau khi tái hiện được bug và có thống nhất cần thiết:

* `scripts/data/save\\\_manager.gd`
* `scripts/data/audio\\\_manager.gd`
* `scenes/tests/save\\\_test.tscn` (chỉ bổ sung assertions)

Không sửa GameManager, Gameplay/Core, MainMenu, UI feature, LevelData hay `project.godot` trong PR TV5 này. Lỗi tích hợp ở các module đó phải ghi evidence và báo Leader.

## 2\. Contract Save/Audio

* Save chỉ gồm `unlocked\\\_level` và `sound\\\_enabled`.
* Không lưu current loop, tick, action history, vị trí Player/Echo hoặc lượt chơi đang dở.
* API SaveManager: `SaveManager.new()`, `load\\\_progress()`, `save\\\_progress(data)`, `reset\\\_progress()`.
* API AudioManager: `set\\\_sound\\\_enabled(enabled)`, `is\\\_sound\\\_enabled()`, `play\\\_sound(AudioStream)`, `stop\\\_sound()`.
* AudioManager được tạo và inject làm child trong test fixture; không khai báo Autoload.
* Test phải sao lưu nguyên văn `user://progress.json` và `user://progress.json.tmp`, sau đó khôi phục nguyên trạng hoặc xóa file test nếu trước đó không tồn tại.
* Audio preference phải được đọc từ SaveManager và áp dụng bằng `AudioManager.set\\\_sound\\\_enabled()` trong test fixture. Việc ứng dụng production khôi phục preference khi vào game cần xác nhận riêng trên integration flow.

## 3\. F6 Save/Audio test cases

|ID|Nội dung|Expected|Bằng chứng cần có|Trạng thái|
|-|-|-|-|-|
|SAVE-01|Không có save file|Level 1, Sound ON mặc định|F6 output: reset test file; file không tồn tại → Level 1, Sound ON|PASS|
|SAVE-02|Save Level 3 / Sound OFF rồi tạo SaveManager instance mới và load|Hai giá trị được giữ nguyên|F6 output: save\_progress ghi dữ liệu hợp lệ; instance SaveManager mới đọc lại đúng Level/Sound|PASS|
|SAVE-03|Kiểm tra raw JSON|Chỉ có đúng `unlocked\\\_level`, `sound\\\_enabled`|F6 output xác nhận JSON chỉ chứa hai khóa được phép|PASS|
|SAVE-04|Truyền thêm current\_loop/current\_tick/action\_history|Các trường tạm không được ghi|F6 output xác nhận tick/loop/action không được lưu|PASS|
|SAVE-05|JSON hỏng|`load\\\_progress()` fallback về mặc định, không crash|F6 output xác nhận JSON hỏng → fallback mặc định|PASS|
|CLEANUP-01|Sau test|File save và file tạm được khôi phục nguyên văn; không mất save người dùng|so sánh file trước/sau (progress.json /<br />progress.json.tmp); cần xác nhận riêng|PASS|
|AUDIO-01|Lưu Sound OFF rồi load preference vào AudioManager|`is\\\_sound\\\_enabled()` là false|F6 output xác nhận lưu Sound OFF và AudioManager khôi phục Sound OFF|PASS|
|AUDIO-02|Sound OFF rồi gọi `play\\\_sound()`|Không AudioStreamPlayer nào bắt đầu phát; Master bus mute|F6 output xác nhận play\_sound không phát và Master bus được mute|PASS|
|AUDIO-03|Lưu Sound ON, load preference, gọi `play\\\_sound(click\\\_sound)`|AudioManager ON và một player bắt đầu phát|F6 save\_flow\_test.tscn -> Run Save / Audio Tests <br />Link ảnh: https://ibb.co/HDrz48Rk|PASS|

### Kết quả chạy F6 ngày 2026-11-17

* **Save/Audio:** summary trên màn hình là `16 PASS | 0 FAIL | 2 NOT RUN`.
* CLEANUP-01 chưa được xác minh độc lập bằng so sánh file trước/sau; 
* Summary `16 PASS` là tổng số assertion/check mà fixture báo cáo, không được hiểu là 16 test case độc lập hoặc là toàn bộ yêu cầu Issue đã PASS.
* Dòng kiểm tra giới hạn `unlocked\\\_level <= 5` vẫn NOT RUN, chờ Leader chốt ownership/contract.
* **Level Resource Check:** `2 PASS | 0 FAIL | 4 NOT RUN`; LEVEL-01 có resource, đúng ID và `validate\\\_level()` không báo lỗi. LEVEL-02 đến LEVEL-05 thiếu resource trong source/branch đang chạy.

### Chạy F6

1. Mở `res://scenes/tests/save\\\_flow\\\_test.tscn`.
2. Nhấn F6.
3. Nhấn **Run Save / Audio Tests**.
4. Kiểm tra `PASS`, `FAIL`, `NOT RUN` và xác nhận log có `CLEANUP`.
5. Kiểm tra file save của người dùng vẫn giữ nguyên nội dung trước test.
6. Nhấn **Check Level 01-05 Resources** sau khi các Level đã được merge vào đúng branch.

## 4\. Level resource / solution regression

|ID|Resource|Expected|Trạng thái tại snapshot main|
|-|-|-|-|
|LEVEL-01|`data/levels/level\\\_01.tres`|Load thành `LevelData`, ID = 1, schema hợp lệ|PASS — F6: resource tìm thấy, ID = 1, `LevelData.validate\\\_level()` không có lỗi|
|LEVEL-02|`data/levels/level\\\_02.tres`|Load thành `LevelData`, ID = 2, schema hợp lệ|NOT RUN — chưa có trong main snapshot|
|LEVEL-03|`data/levels/level\\\_03.tres`|Load thành `LevelData`, ID = 3, schema hợp lệ|NOT RUN — chưa có trong main snapshot|
|LEVEL-04|`data/levels/level\\\_04.tres`|Load thành `LevelData`, ID = 4, schema hợp lệ|NOT RUN — chưa có trong main snapshot|
|LEVEL-05|`data/levels/level\\\_05.tres`|Load thành `LevelData`, ID = 5, schema hợp lệ|NOT RUN — chưa có trong main snapshot|

Lưu ý: resource load + đúng `level\\\_id` + `validate\\\_level()` chỉ xác nhận cấu trúc cơ bản. Không tự chứng minh lời giải của màn thắng bằng gameplay. TV3 chịu trách nhiệm LevelData và lời giải; TV5 kiểm thử regression trên integration build sau khi dependency được merge.

## 5\. Gameplay F5 end-to-end regression

|ID|Luồng|Expected|Phụ thuộc|Trạng thái|
|-|-|-|-|-|
|FLOW-01|Main Menu → Level Select|Chọn được Level 1–5 theo unlock|Leader/TV4|WAIT|
|FLOW-02|Continue|Vào level hợp lệ theo unlocked progress|Leader/TV4|WAIT|
|FLOW-03|Win Level N|Unlock Level N+1, không giảm unlock cũ|Leader|WAIT|
|FLOW-04|Unlock cap|Không vượt Level 5|Leader phải chốt nơi kiểm tra cap|BLOCKED — owner decision|
|FLOW-05|Restart|Reset loop/action/actors/switch/door, không đổi unlock/sound|Leader/TV2/TV3|WAIT|
|FLOW-06|Pause/Resume|Không tăng tick hoặc phát input ngầm khi pause|Leader/TV4|WAIT|
|FLOW-07|Result/Next Level|Kết quả đúng và chuyển sang level tiếp theo hợp lệ|Leader/TV4|WAIT|
|FLOW-08|Restore sound preference|Khi mở app/game, AudioManager nhận sound\_enabled đã lưu|Leader|WAIT — production hook chưa thấy trong source snapshot|
|FLOW-09|F5 menu → 5 level → win/unlock/next|Hoàn tất 5 màn không crash/softlock|Leader + TV2/TV3/TV4|WAIT|

## 6\. Phát hiện từ source snapshot (không phải runtime result)

1. `SaveManager.save\\\_progress()` hiện lọc đúng hai khóa và `load\\\_progress()` fallback JSON hỏng về mặc định.
2. `SaveManager` hiện chỉ từ chối `unlocked\\\_level < 1`; chưa có cap tối đa 5.
3. `GameManager.complete\\\_level()` dùng `maxi(unlocked\\\_level, current\\\_level + 1)` nên có ý đồ giữ unlock đơn điệu, nhưng chưa cap Level 5.
4. Trong source snapshot, `GameManager` chưa thấy khôi phục `sound\\\_enabled` vào AudioManager production. `AudioManager` chủ yếu được tạo trong `save\\\_test.tscn`.
5. `main` chỉ có `data/levels/level\\\_01.tres`; Level 02–05 tồn tại trên nhánh TV3 `feature/EL-S04-TV3` trong Git bundle nhưng chưa có trong `main` snapshot.
6. `main\\\_menu.gd` hiện chỉ kết nối New Game/Exit; Continue và Tutorial đang disabled. Chưa thấy Level Select, PauseMenu và LevelComplete scene trong `main` snapshot.

Các điểm 2–6 là integration gap hoặc dependency cần Leader/TV3/TV4 xử lý. TV5 không tự patch Core, UI, GameManager hay LevelData.

## 7\. Evidence record

|Trường|Giá trị cần điền khi chạy|
|-|-|
|Người chạy|Chưa ghi tên người chạy|
|Ngày/giờ|2026-11-17 (ảnh chụp kết quả; giờ cụ thể chưa ghi)|
|Godot version|Godot 4.7.2.stable|
|Commit SHA / branch|Chưa ghi — bổ sung SHA và branch thực tế trước khi tạo PR|
|F6 Save/Audio|16 PASS / 0 FAIL / 2 NOT RUN (theo summary hiển thị trong F6). Các trường hợp có log PASS được đánh dấu riêng ở mục 3; CLEANUP-01 và AUDIO-03 chưa được xác minh độc lập từ ảnh.|
|F6 Level resources|2 PASS / 0 FAIL / 4 NOT RUN. LEVEL-01 PASS; LEVEL-02 đến LEVEL-05 NOT RUN vì thiếu resource trong source/branch đang chạy.|
|F5 End-to-End|WAIT|
|Evidence screenshot/video|Link ảnh 1: https://ibb.co/bj5ZTTdG<br />Link ảnh 2: https://ibb.co/Kz62VPvC|
|Bug / blocker|Level 02–05 chưa có trong source/branch đang chạy; FLOW-04 chờ Leader quyết định nơi kiểm tra cap Level 5; F5 end-to-end chưa chạy.|

## 8\. Gate Sprint 04

Chỉ đề nghị PASS khi F5 menu → select → đủ 5 Level → win/unlock/next, Tutorial, Pause, Restart, Result, Save/Audio đều được xác minh trên integration/main; cả 5 lời giải được kiểm chứng; các PR đã merge và regression trên main không có blocker. Không lấy kết quả F6 độc lập thay cho F5 end-to-end.

---

## Sprint 04 - Final Integration Verification (2026-11-20)

Integration baseline: main sau PR #48 va PR #49.

### F6
- Save/Audio fixture: 16 PASS / 0 FAIL / 2 NOT RUN.
- Level Resource Check: 10 PASS / 0 FAIL / 0 NOT RUN.
- Sprint 04 Flow: 26 PASS / 0 FAIL.
- Sprint 03 Core: 43 PASS / 0 FAIL.
- Levels Validation: 152 PASS / 0 FAIL.
- Cac regression suite con lai: Leader bao cao 0 FAIL.

### F5
- Level 03 -> 04 -> 05: PASS.
- Level 05 su dung 2 Echo: PASS.
- Unlock khong vuot Level 05: PASS.
- Save persistence sau restart: PASS.
- Audio ON/OFF va restore preference: PASS.
- Tutorial, Pause, Next, Replay: PASS.

### Remaining notes
- Hai NOT RUN thuoc fixture Save/Audio doc lap;
  cac hanh vi GameManager lien quan da duoc Leader
  kiem thu tren integration flow.
- F6 Level Resources khong thay the kiem thu
  loi giai gameplay.
- Ket qua F5/F6 tren duoc Leader bao cao;
  bang chung chi tiet luu trong PR va test record.


