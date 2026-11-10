# S02 – TV5: Nhật ký kiểm thử và bằng chứng

## A. Thông tin lần kiểm thử

|Trường|Giá trị|
|-|-|
|Issue|S02 #15|
|Người thực hiện|TV5|
|Ngày/giờ chạy|2026-11-10 – theo ảnh F6 và xác nhận của TV5|
|Nhánh|`feature/EL-S02-TV5`|
|Commit SHA thực tế|Chưa có – lấy bằng `git rev-parse HEAD` tại commit được test|
|Snapshot source ZIP|`9f6a8f4` (tham chiếu, không phải SHA nghiệm thu)|
|Godot version|4.7.2.stable|
|OS/thiết bị|Windows 11 theo thông tin môi trường người dùng; cập nhật nếu chạy trên máy khác|

## B. Quy tắc bằng chứng

Mỗi lần test phải ghi đầy đủ:

* **Scene/Flow:** đường dẫn F6 scene hoặc các bước F5 đã thực hiện.
* **Expected:** kết quả mong đợi theo Issue/contract.
* **Actual:** nội dung quan sát được, gồm giá trị/log cụ thể.
* **Status:** `PASS`, `FAIL`, `WAIT` hoặc `NOT RUN`.
* **Evidence:** tên ảnh chụp, log, video hoặc artifact liên quan.
* **Build:** Godot version + commit SHA thực tế.

Không ghi PASS chỉ vì code có hàm hoặc nhìn thấy scene trong FileSystem. F6 test scene không chứng minh luồng F5 đã tích hợp. Chỉ ghi PASS sau khi chạy thực tế.

## C. Kết quả test SaveManager độc lập (F6)

Scene: `res://scenes/tests/save\\\_integration\\\_test.tscn`  
API: `SaveManager.new()`, `load\\\_progress()`, `save\\\_progress()`, `reset\\\_progress()`.

|ID|Expected|Actual|Status|Evidence|
|-|-|-|-|-|
|SAVE-01|Tạo SaveManager bằng `new()`, không cần Autoload|Scene chạy bằng F6; API được gọi trong test|PASS|Ảnh F6 2026-11-10: màn hình 10 PASS / 0 FAIL<br />Link ảnh: https://ibb.co/dJMS4Qhn|
|SAVE-02|Không có save file → Level 1, sound ON|`Level 1, sound ON`|PASS|Ảnh F6 2026-11-10|
|SAVE-03|Lưu rồi đọc lại Level 2, sound OFF|Đọc lại đúng Level 2, sound OFF|PASS|Ảnh F6 2026-11-10|
|SAVE-04|File JSON có đúng hai khóa unlocked\_level và sound\_enabled|File JSON có đúng hai khóa được yêu cầu|PASS|Ảnh F6 2026-11-10|
|SAVE-05|Dữ liệu sai bị từ chối, không ghi đè save tốt|Dữ liệu không hợp lệ bị từ chối, save cũ được giữ|PASS|Ảnh F6 2026-11-10|
|SAVE-06|JSON hỏng trả mặc định, không crash|JSON hỏng fallback về mặc định, không crash|PASS|Ảnh F6 2026-11-10|
|SAVE-07|Reset xóa file, load sau reset ra mặc định|File bị xóa; lần load tiếp theo trả mặc định|PASS|Ảnh F6 2026-11-10|

**Kết quả chạy F6 ngày 2026-11-10:** giao diện hiển thị `PASSED: 10 | FAILED: 0` và `RESULT: ALL TESTS PASSED (F6 scene only)`. Godot `4.7.2.stable`. 10 PASS gồm bước chuẩn bị dữ liệu, default, save write, load lại, kiểm tra hai khóa, từ chối input sai, JSON hỏng fallback, reset, load sau reset và cleanup khôi phục file.

**Bảo vệ file save:** Scene F6 sẽ hỏi xác nhận, sao lưu nội dung `user://progress.json` hiện có và cố gắng khôi phục sau test. Đóng game khác đang sử dụng cùng file trước khi chạy. Nếu scene bị crash giữa chừng, kiểm tra lại file save trước khi tiếp tục chơi.

## D. Kiểm tra persistence thủ công sau khi đóng/mở lại

Dùng `res://scenes/tests/save\\\_test.tscn`:

1. Chạy F6, nhấn **Save Level 2**.
2. Nhấn **Turn Sound Off**.
3. Ghi nhận trạng thái Level 2 / Sound OFF.
4. Dừng hẳn game (không chỉ chuyển scene).
5. Chạy lại scene hoặc mở lại ứng dụng; nhấn **Load Progress**.
6. Expected: Level 2 và Sound OFF vẫn được đọc lại; AudioManager được đặt về mute tương ứng.

|Expected|Actual|Status|Evidence|
|-|-|-|-|
|Level 2 và Sound OFF còn sau khi dừng hẳn rồi mở lại|TV5 xác nhận `save\\\_test.tscn` chạy thành công sau khi thực hiện quy trình kiểm tra|PASS|Xác nhận của TV5 trong hội thoại ngày 2026-11-10;<br />Link ảnh 1:<br />https://ibb.co/N6wJhNqm<br />Link ảnh 2:<br />https://ibb.co/mrK9175j|
|AUDIO-01 – Sound ON/OFF|Đổi ON/OFF, load lại và kiểm tra click audio|TV5 xác nhận kiểm thử `save\\\_test.tscn` thành công|PASS|

## E. Ma trận tích hợp chờ Leader

|ID|F5/F6 flow|Expected|Actual|Status|Evidence|
|-|-|-|-|-|-|
|GAME-01|WAIT trong gameplay tích hợp|Tick tăng 1, vị trí không đổi|Chờ nhánh tích hợp|WAIT|Chưa có|
|GAME-02|Player di chuyển vào tường/ô bị chặn|Vị trí không đổi nhưng tick tăng 1|Chờ Player + core integration|WAIT|Chưa có|
|PUZZLE-01|Player thử bước vào cửa khóa|Không đi xuyên cửa; hành động bị chặn vẫn tính tick|Chờ Puzzle + core integration|WAIT|Chưa có|
|CORE-01|Restart sau vài hành động|Run/player/world trở về trạng thái đầu theo contract|Chờ Leader integration|WAIT|Chưa có|
|HUD-01|HUD refresh trong Gameplay|Tick/state hiển thị đúng dữ liệu hiện hành|Chờ F5 integration|WAIT|Chưa có|
|E2E-01|F5 MainMenu → Level 01 → Back|Điều hướng hoàn chỉnh, không crash|Chờ Leader pull PR|WAIT|Chưa có|
|E2E-02|F5 no-Echo end-to-end|Chơi trọn luồng Level 01 không Echo|Chờ Leader pull PR|WAIT|Chưa có|

## F. Lỗi phát hiện / Issue phát sinh

|Bug ID / Issue|Expected|Actual|Bước tái hiện|Evidence|Owner|Trạng thái|
|-|-|-|-|-|-|-|
|Chưa có dữ liệu|—|Chỉ cập nhật sau khi chạy test|—|—|—|—|

Khi phát hiện lỗi ở Player/Puzzle/UI/Core, TV5 chỉ ghi nhận và mở Issue/báo đúng owner; không tự sửa file ngoài phạm vi.

## G. Gate Sprint 02 – xác nhận của Leader

* \[ ] TV5 cập nhật matrix có owner, ngày và build SHA.
* \[ ] Save chỉ có hai khóa `unlocked\\\_level`, `sound\\\_enabled`.
* \[ ] F6 SaveManager integration test có evidence.
* \[ ] Persistence save/load sau khi đóng/mở lại đã được kiểm tra.
* \[ ] Leader pull từng PR vào nhánh test và chạy F6 từng module.
* \[ ] Leader chạy F5 MainMenu → Level 01 → Back.
* \[ ] Leader chạy no-Echo end-to-end.
* \[ ] Mọi FAIL đã có Issue/owner; mọi WAIT/NOT RUN được ghi rõ.
* \[ ] Leader xác nhận evidence S02 trước khi chuyển Sprint 03.

**Gate chưa được xác nhận.**

