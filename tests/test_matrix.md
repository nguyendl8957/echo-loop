# S02 – TV5: Ma trận kiểm thử tích hợp và lưu bằng chứng

## 1\. Thông tin build / người phụ trách

|Trường|Giá trị|
|-|-|
|Issue|S02 #15|
|Owner|TV5|
|Ngày lập/cập nhật|2026-11-10|
|Nhánh làm việc|`feature/EL-S02-TV5` (tạo từ `main` mới nhất khi bắt đầu PR)|
|Commit snapshot trong ZIP được kiểm tra|`9f6a8f4` – chỉ là SHA của source ZIP nhận được, chưa phải SHA nghiệm thu|
|Godot thực tế đã xác nhận|4.7.2.stable|
|Build/commit thực tế được test|Chưa ghi; cập nhật sau khi checkout commit và chạy test|

**Quy tắc trạng thái:** `PASS` chỉ khi đã chạy và có evidence; `FAIL` khi thực tế khác Expected; `WAIT` khi phụ thuộc tích hợp/Leader chưa sẵn sàng; `NOT RUN` khi có thể chạy độc lập nhưng TV5 chưa chạy. Không đổi WAIT/NOT RUN thành PASS chỉ dựa trên việc đọc code.

## 2\. Ma trận theo Issue S02 #15

|ID|Hạng mục|Cách kiểm tra / điều kiện|Expected|Owner thực hiện / xử lý|Trạng thái ban đầu|Evidence|
|-|-|-|-|-|-|-|
|SAVE-01|SaveManager tạo instance độc lập|F6 `res://scenes/tests/save\\\\\\\\\\\\\\\_integration\\\\\\\\\\\\\\\_test.tscn`; tạo bằng `SaveManager.new()`|Scene chạy, không cần Autoload; gọi được 4 API được giao|TV5|PASS|Ảnh F6: 10 PASS / 0 FAIL, 2026-11-10<br />Link ảnh: https://ibb.co/dJMS4Qhn|
|SAVE-02|Giá trị mặc định|F6; test khi `user://progress.json` tạm thời không tồn tại|`unlocked\\\\\\\\\\\\\\\_level=1`, `sound\\\\\\\\\\\\\\\_enabled=true`|TV5|PASS|Ảnh F6: SAVE-01, 2026-11-10|
|SAVE-03|Save/Load hai khóa|F6; lưu Level 2 + sound OFF, sau đó load|Đọc lại đúng Level 2 và `false`|TV5|PASS|Ảnh F6: SAVE-02, 2026-11-10|
|SAVE-04|Kiểm tra cấu trúc file Save|F6, lưu dữ liệu Level 2 và Sound OFF, sau đó đọc và phân tích file JSON|File JSON có đúng hai khóa unlocked\_level và sound\_enabled|TV5|PASS|Ảnh F6: SAVE-03, 2026-11-10|
|SAVE-05|Dữ liệu không hợp lệ|F6; thử lưu `unlocked\\\\\\\\\\\\\\\_level=0`|`save\\\\\\\\\\\\\\\_progress()` từ chối; save hợp lệ trước đó không bị ghi đè|TV5|PASS|Ảnh F6: SAVE-04, 2026-11-10|
|SAVE-06|JSON hỏng|F6; ghi chuỗi JSON sai định dạng rồi gọi `load\\\\\\\\\\\\\\\_progress()`|Không crash; trả mặc định hợp lệ|TV5|PASS|Ảnh F6: SAVE-05, 2026-11-10|
|SAVE-07|Reset|F6; gọi `reset\\\\\\\\\\\\\\\_progress()`|File save bị xóa; lần load tiếp theo trả mặc định|TV5|PASS|Ảnh F6: SAVE-06, 2026-11-10|
|SAVE-08|Persistence sau khi đóng/mở lại|Dùng `save\\\\\\\\\\\\\\\_test.tscn`: Save Level 2, Sound OFF; dừng hẳn game; chạy lại scene/app rồi Load Progress|Level 2 và Sound OFF vẫn còn sau khi mở lại|TV5; Leader xác nhận khi tích hợp vào game|PASS|TV5 xác nhận chạy thành công trên `save\\\\\\\\\\\\\\\_test.tscn`, 2026-11-10;<br />Link ảnh 1:<br />https://ibb.co/N6wJhNqm<br />Link ảnh 2:<br />https://ibb.co/mrK9175j|
|AUDIO-01|Bật/tắt âm thanh và lưu trạng thái|Dùng `save\\\\\\\\\\\\\\\_test.tscn`; Sound OFF/ON, tải lại và kiểm tra âm thanh click|Trạng thái âm thanh được khôi phục đúng; click phát khi bật và bị tắt khi mute|TV5|PASS|TV5 xác nhận test `save\\\\\\\\\\\\\\\_test.tscn` thành công, 2026-11-10; |
|GAME-01|WAIT tiêu tốn tick|Sau tích hợp, F5/F6 thực hiện WAIT|Tick tăng đúng 1; vị trí Player không đổi|Leader/TV1; TV5 ghi evidence|WAIT|Chưa có|
|GAME-02|Di chuyển bị chặn vẫn tiêu tốn tick|Sau tích hợp, yêu cầu Player đi vào tường/ô blocker|Player không đổi vị trí; tick tăng đúng 1|TV2 + Leader; TV5 ghi evidence|WAIT|Chưa có|
|PUZZLE-01|Cửa khóa chặn di chuyển|Sau tích hợp Level 1, thử bước vào cửa đang đóng|Player không đi xuyên cửa; hành động bị chặn vẫn tiêu tốn tick theo contract|TV3 + Leader; TV5 ghi evidence|WAIT|Chưa có|
|CORE-01|Restart|Sau tích hợp, di chuyển vài tick rồi Restart|Trạng thái run/vị trí/môi trường được reset theo contract đã duyệt|Leader + TV2/TV3; TV5 ghi evidence|WAIT|Chưa có|
|HUD-01|HUD refresh|F6 `res://scenes/tests/hud\\\\\\\\\\\\\\\_test.tscn`, sau đó xác nhận trong gameplay tích hợp|Signal nút và Tick label cập nhật đúng; trong gameplay HUD phản ánh state hiện hành|TV4 + Leader; TV5 ghi evidence|NOT RUN|Chưa có|
|E2E-01|F5 MainMenu → Level 01 → Back|Chỉ chạy trên nhánh test sau khi Leader pull các PR tích hợp|Vào Level 01 và quay lại Menu không crash|Leader; TV5 quan sát/ghi evidence|WAIT|Chưa có|
|E2E-02|No-Echo end-to-end|Chạy Level 01 theo luồng không có Echo trên build tích hợp|Hoàn tất luồng chơi một màn không Echo, không blocker/crash|Leader; TV5 kiểm chứng độc lập|WAIT|Chưa có|

## 3\. File/test hiện có trong source ZIP

|Thành phần|Vị trí|Vai trò trong QA|
|-|-|-|
|SaveManager|`scripts/data/save\\\\\\\\\\\\\\\_manager.gd`|Có `load\\\\\\\\\\\\\\\_progress()`, `save\\\\\\\\\\\\\\\_progress()`, `reset\\\\\\\\\\\\\\\_progress()`; dùng instance, không phải Autoload|
|AudioManager|`scripts/data/audio\\\\\\\\\\\\\\\_manager.gd`|Có `set\\\\\\\\\\\\\\\_sound\\\\\\\\\\\\\\\_enabled()`, `is\\\\\\\\\\\\\\\_sound\\\\\\\\\\\\\\\_enabled()`, `play\\\\\\\\\\\\\\\_sound()`, `stop\\\\\\\\\\\\\\\_sound()`|
|Save/Audio manual test|`scenes/tests/save\\\\\\\\\\\\\\\_test.tscn`|F6 kiểm tra Save Level 2, Load Progress, Sound ON/OFF, Reset|
|Core test|`tests/core\\\\\\\\\\\\\\\_test.gd` + `scenes/tests/core\\\\\\\\\\\\\\\_test.tscn`|Test độc lập core; không thay thế F5 gameplay tích hợp|
|HUD test|`tests/hud\\\\\\\\\\\\\\\_test.gd` + `scenes/tests/hud\\\\\\\\\\\\\\\_test.tscn`|Test signal/nút và tick label của HUD|
|Player test|`scenes/tests/player\\\\\\\\\\\\\\\_test.tscn`|Test độc lập Player; xem Output khi chạy F6|
|Puzzle test|`scenes/tests/puzzle\\\\\\\\\\\\\\\_test.tscn`|Test độc lập switch/door; không chứng minh Level 01 F5 đã tích hợp|
|Save integration test|`scenes/tests/save\\\\\\\\\\\\\\\_integration\\\\\\\\\\\\\\\_test.tscn`|Test tự động API SaveManager, được tạo trong Issue #15|

## 4\. Ranh giới công việc TV5

* Chỉ thêm/sửa tài liệu QA trong `tests/` và scene test riêng trong `scenes/tests/` theo Issue #15.
* Không sửa `scripts/core/\\\\\\\\\\\\\\\*`, `scenes/gameplay/\\\\\\\\\\\\\\\*`, `scenes/menus/\\\\\\\\\\\\\\\*`, `project.godot`, Player/Puzzle/UI modules.
* Không gắn SaveManager thành Autoload. Không tự thêm tích hợp vào GameManager hoặc LevelComplete.
* Không lưu tick, Echo, action history hoặc lượt chơi đang dở.
* Nếu phát hiện lỗi ở module khác, ghi Expected/Actual, ảnh/log và mở Issue giao đúng owner; không tự sửa ngoài phạm vi.

## 5\. Quy trình QA / cập nhật trạng thái

1. F6 scene SaveIntegrationTest: đã chạy 10 PASS / 0 FAIL ngày 2026-11-10; lưu ảnh kết quả.
2. Save/Audio `save\\\\\\\\\\\\\\\_test.tscn`: TV5 xác nhận kiểm thử thành công ngày 2026-11-10; cần bổ sung ảnh/log vào evidence nếu có.
3. Leader pull các PR vào nhánh test; chạy F6 từng module.
4. Leader chạy F5: MainMenu → Level 01 → Back, sau đó no-Echo end-to-end.
5. TV5 cập nhật Expected/Actual/Status/Evidence và SHA đúng build đã chạy.
6. Chỉ báo PASS/Gate hoàn tất khi evidence được Leader xem và xác nhận.

## 6\. Điều kiện nghiệm thu Issue #15

* \[ ] Ma trận có owner, ngày và build SHA thực tế.
* \[ ] Save chỉ chứa `unlocked\\\\\\\\\\\\\\\_level` và `sound\\\\\\\\\\\\\\\_enabled`.
* \[ ] F6 SaveIntegrationTest chạy và evidence chứng minh các API SaveManager.
* \[ ] Đã kiểm tra save/load persistence sau khi đóng và mở lại.
* \[ ] WAIT, blocked move, door locked, restart, HUD refresh, save/load và no-Echo run có Expected/Actual/Status/Evidence.
* \[ ] Các case chưa chạy được ghi WAIT hoặc NOT RUN, không đánh dấu PASS.
* \[ ] Leader đã kiểm tra F6 từng module trên nhánh test.
* \[ ] Leader đã chạy F5 MainMenu → Level 01 → Back.
* \[ ] Leader đã chạy no-Echo end-to-end.
* \[ ] Evidence S02 được Leader xác nhận trước khi chuyển Sprint 03.

