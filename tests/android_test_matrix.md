# S05-TV5 — Android Test Matrix

**Issue:** [#30 — S05-TV5: QA Android tổng hợp, release evidence và tài liệu nộp](https://github.com/nguyendl8957/echo-loop/issues/30)  
**Owner:** TV5  
**Branch dự kiến:** `feature/EL-S05-TV5`  
**Ngày tạo bản ma trận:** 2026-11-23 (Asia/Ho_Chi_Minh)  
**Trạng thái:** DRAFT — chưa có APK candidate và chưa có kết quả Android thật.

## 1. Quy tắc ghi nhận kết quả

Issue #30 yêu cầu mỗi dòng kiểm thử gắn với `case ID`, commit build, APK SHA-256, thiết bị/OS, steps, expected, actual, status, evidence link và tester. Không tái sử dụng PASS của APK cũ cho APK mới. `NOT RUN` không được tính là PASS. Không tự điền thiết bị, commit APK hoặc hash khi chưa có candidate.

Giá trị trạng thái được dùng: `PASS`, `FAIL`, `BLOCKED`, `NOT RUN`. Khi chạy, thay các giá trị `Chưa có` ở từng dòng bằng thông tin thực tế.

## 2. Thông tin source snapshot đã rà soát (không phải build APK)

| Trường | Giá trị |
|---|---|
| Repository | `https://github.com/nguyendl8957/echo-loop` |
| Source ZIP | `echo-loop(8).zip` do nhóm gửi trong hội thoại |
| Nhánh đang checkout trong ZIP | `main` |
| HEAD / `origin/main` bên trong ZIP | `b1b48b027bb5714e3c58832ed51d0f30563bacb4` |
| Commit message | `Merge pull request #51 from nguyendl8957/feature/EL-S05-L` |
| Commit date | 2026-11-20 23:01:42 +07:00 |
| Commit count trong lịch sử `main` của ZIP | 60 |
| Branch TV5 Sprint 05 trong refs đã lưu | Chưa thấy `feature/EL-S05-TV5` |
| Godot mục tiêu theo `docs/android_export_guide.md` | Godot 4.7.2 stable |
| APK candidate / APK SHA-256 | Chưa được cung cấp |
| Thiết bị Android / OS | Chưa được cung cấp |
| Commit thực sự dùng để build APK | Chưa xác định; không suy ra từ HEAD source ZIP |

**Giới hạn xác minh mới nhất:** trang repository GitHub được truy cập tại thời điểm rà soát hiển thị 60 commits, khớp số commit trong ZIP; Issue #30 đang Open và chưa hiển thị branch/PR liên kết. Tuy nhiên, kết nối `git ls-remote` từ môi trường này thất bại do không phân giải được `github.com`; vì vậy chưa thể xác nhận live HEAD SHA tuyệt đối. Trước khi tạo PR, TV5 phải `git fetch`/`git pull` và đối chiếu `main` mới nhất trên máy của nhóm.

**Working tree trong ZIP không sạch:** có thay đổi sẵn ở `assets/audio/click_sound.mp3.import`, `assets/audio/level_up_sound.mp3.import`, `icon.svg.import`, `tests/test_matrix.md` và ba file `.uid` mới. Giữ nguyên các thay đổi này; không dùng `git add .` trong PR TV5.

## 3. Kết quả rà soát tĩnh source (không tính là Android runtime PASS)

- Có `data/levels/level_01.tres` đến `level_05.tres`; tên trong Resource lần lượt là First Step, Hold the Door, Echo Memory, Two Paths, Double Echo.
- `LevelManager` giới hạn ID trong khoảng 1–5; `GameManager.complete_level()` giữ tiến trình mở khóa đơn điệu và clamp trong giới hạn Level 01–05.
- Luồng giao diện trong source gồm Main Menu (New Game, Continue, How to play, Exit), Level Select, HUD, Pause Menu và Level Complete.
- `SaveManager` chỉ ghi `unlocked_level` và `sound_enabled`; không ghi tick, Echo hoặc lượt chơi dở.
- `GameManager` đọc `sound_enabled` khi khởi tạo AudioManager và có phương thức `set_sound_enabled()` để lưu tùy chọn. Tuy nhiên source audit không thấy Settings scene/control hoặc nút UI gọi phương thức này; kiểm thử bật/tắt Sound từ góc nhìn người chơi đang BLOCKED (KI-01).
- Tài liệu Android export yêu cầu landscape, Godot 4.7.2 và cài APK lên thiết bị thật. `project.godot` không khai báo orientation; Android export preset bị `.gitignore` loại khỏi repo và phải kiểm tra cấu hình local khi build.
- ZIP không có APK candidate. Hướng dẫn export hiện có ghi APK export, cài đặt Android và full gameplay Android là NOT RUN.
- Kiểm tra tên file tracked không thấy APK/AAB/keystore/JKS/P12/PFX/PEM hoặc `export_presets.cfg`; scan pattern giới hạn trên working tree không có hit cho private-key header/GitHub-token-like/Google API key/AWS access-key. Chưa phải full-history secret scan.

## 4. Android QA cases

| Case ID | Build commit SHA | APK SHA-256 | Device / Android OS | Steps | Expected | Actual | Status | Evidence link | Tester |
|---|---|---|---|---|---|---|---|---|---|
| APK-01 — Cài đặt APK candidate | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Cài APK được Leader phát hành lên Android thật; ghi rõ cài mới hay cập nhật. | Ứng dụng cài thành công, không lỗi package/signature. | Chưa chạy: ZIP không chứa APK candidate. | NOT RUN | Chưa có | Chưa ghi |
| APK-02 — Khởi chạy lần đầu | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Mở ứng dụng sau cài mới; quan sát splash, màn hình đầu và log crash. | Splash và Main Menu xuất hiện; không crash hoặc treo. | Chưa chạy trên Android thật. | NOT RUN | Chưa có | Chưa ghi |
| APP-01 — Khởi chạy offline | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Tắt Wi-Fi và dữ liệu di động trước khi mở app; thử vào gameplay. | Menu và gameplay hoạt động offline; không yêu cầu đăng nhập/máy chủ. | Chưa chạy trên thiết bị. | NOT RUN | Chưa có | Chưa ghi |
| MENU-01 — Main Menu hiển thị | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Mở app và kiểm tra các nút New Game, Continue, How to play, Exit. | Tên nút, chữ, bố cục và thao tác hiển thị đúng trên APK cuối. | Source có 4 nút; hình ảnh/kích thước chạm trên thiết bị chưa xác minh. | NOT RUN | Chưa có | Chưa ghi |
| MENU-02 — Hướng dẫn / How to play | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Từ Main Menu chọn How to play; đọc nội dung và bấm BACK. | Hướng dẫn điều khiển, WAIT, Time Loop, Echo, Switch/Door, Exit; BACK quay lại menu. | Source hiện có màn Tutorial và nút BACK; chưa chạy trên APK. | NOT RUN | Chưa có | Chưa ghi |
| FLOW-01 — New Game vào Level 01 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Từ Main Menu chọn New Game. | Mở Level 01 – First Step ở trạng thái vòng mới. | Chưa chạy trên APK. | NOT RUN | Chưa có | Chưa ghi |
| FLOW-02 — Continue mở Level Select | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Tạo tiến trình đã mở khóa nhiều level; từ menu chọn Continue. | Mở Level Select và chỉ cho chọn level đã mở khóa. Continue không khôi phục lượt đang chơi dở. | Source nối Continue tới Level Select; hành vi APK chưa chạy. | NOT RUN | Chưa có | Chưa ghi |
| LEVEL-01 — Chơi và thắng Level 01 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Đi theo lời giải Level 01 trên APK; tới Exit bằng Player. | Level Complete xuất hiện; mở khóa level kế tiếp (hoặc giữ mức 5 nếu đã ở cuối). | Resource First Step có trong source; chưa thực hiện gameplay trên APK. | NOT RUN | Chưa có | Chưa ghi |
| LEVEL-02 — Chơi và thắng Level 02 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Giải Hold the Door bằng Echo giữ Switch và Player đi qua Door tới Exit. | Player tới Exit; level hoàn thành; không softlock. | Resource và tài liệu lời giải có trong source; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| LEVEL-03 — Chơi và thắng Level 03 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Giải Echo Memory bằng hành động WAIT/căn nhịp Echo theo lời giải. | Player qua Door theo snapshot đầu tick và tới Exit. | Resource và tài liệu lời giải có trong source; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| LEVEL-04 — Chơi và thắng Level 04 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Giải Two Paths bằng phối hợp tuyến đường của Player/Echo. | Player kích hoạt điều kiện Door và đến Exit; không softlock. | Resource và tài liệu lời giải có trong source; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| LEVEL-05 — Chơi và thắng Level 05 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Giải Double Echo bằng hai Echo giữ hai Switch; Player tới Exit. | Level Complete xuất hiện; Echo không thể thay Player thắng; Next Level bị vô hiệu hóa ở Level 05. | Resource và tài liệu lời giải có trong source; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| RULE-01 — Giới hạn 12 tick | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Trong một vòng thực hiện đủ 12 action; thử nhập action tiếp theo. | Mỗi vòng tối đa 12 tick; không ghi thêm tick thứ 13. | Source định nghĩa MAX_TICKS = 12; chưa chạy runtime trên APK. | NOT RUN | Chưa có | Chưa ghi |
| RULE-02 — WAIT tiêu tốn một tick | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Bấm WAIT một lần trong gameplay. | Tick tăng 1; vị trí Player không đổi. | Chưa chạy trên APK. | NOT RUN | Chưa có | Chưa ghi |
| RULE-03 — Di chuyển bị chặn tiêu tốn tick | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Bấm hướng vào tường/biên/cửa đang đóng. | Player không đổi ô; action bị chặn vẫn tiêu tốn một tick. | Chưa chạy trên APK. | NOT RUN | Chưa có | Chưa ghi |
| RULE-04 — Kết thúc vòng sớm đệm WAIT | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Thực hiện ít hơn 12 tick rồi bấm ENDLOOP. | Các tick còn thiếu được bổ sung WAIT để bản ghi đủ 12 action; sang vòng mới theo luật. | Source TimeLoopManager có vòng đệm WAIT; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| ECHO-01 — Echo xuất hiện đúng vòng | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Kết thúc vòng 1 rồi vòng 2; quan sát actor. | Vòng 2 có Echo 1; vòng 3 có Echo 1 và Echo 2. | Source có logic spawn tối đa 2 Echo; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| ECHO-02 — Không tạo Echo thứ ba | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Hoàn tất hai lần tạo Echo rồi kết thúc vòng tiếp theo khi chưa thắng. | Không xuất hiện Echo thứ ba; run thất bại theo luật sau vòng cuối. | Source hằng MAX_ECHOES = 2; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| ECHO-03 — Replay xác định | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Chạy lại cùng chuỗi action trên cùng level nhiều lần; so sánh thứ tự di chuyển và kết quả. | Echo phát lại cùng chuỗi hành động; kết quả mô phỏng không phụ thuộc tốc độ animation. | Có replay regression/F6 suite trong source và kết quả cũ được ghi ở docs; Android run chưa có. | NOT RUN | Chưa có | Chưa ghi |
| ECHO-04 — Echo không thể tự thắng | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Đặt Echo trên Exit trong khi Player chưa tới Exit. | Không hiện Level Complete; chỉ Player hiện tại tới Exit mới thắng. | Source/contract quy định Player-only win; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| PUZZLE-01 — Door snapshot đầu tick | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Cho Echo rời Switch trong cùng tick Player bước vào Door; tiếp tục bước ra. | Di chuyển dùng trạng thái Door ở đầu tick; thay đổi Switch/Door sau khi actor di chuyển không làm kẹt Player đã đứng trong Door. | Có lời giải/tài liệu kiểm tra trong source; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| GAME-01 — Restart từ Gameplay | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Thực hiện vài tick, tạo Echo nếu có thể, bấm RESTART. | Màn hiện tại được tải lại; tick, Echo, action history và trạng thái puzzle reset; save unlock/audio không bị xóa. | Source gọi mở lại Gameplay; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| PAUSE-01 — Pause và Resume | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Bấm PAUSE, quan sát HUD; bấm RESUME. | Input bị khóa trong Pause; tick không tự tăng; Resume trả lại trạng thái input phù hợp. | Source có các handler khóa HUD/input; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| PAUSE-02 — Pause về Main Menu | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Mở Pause rồi chọn MAIN MENU; vào lại bằng New Game. | Quay về Main Menu; bắt đầu lại level sạch, không phục hồi vòng đang chơi dở. | Source có signal và handler; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| RESULT-01 — Level Complete – Next Level | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Thắng Level 01–04 và bấm NEXT LEVEL. | Chuyển đúng level tiếp theo đã mở khóa. | Source có luồng Next và kiểm tra unlock; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| RESULT-02 — Level Complete – Replay/Level Select | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Từ màn hoàn thành lần lượt thử REPLAY và LEVEL SELECT. | Replay nạp lại level hiện tại; Level Select mở danh sách level được mở khóa. | Source có hai signal/handler; chưa chạy APK. | NOT RUN | Chưa có | Chưa ghi |
| SAVE-01 — Lưu mở khóa sau khi thắng | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Thắng một level và ghi nhận `unlocked_level` tăng; thoát app hoàn toàn. | Tiến trình mở khóa được lưu cục bộ, không giảm mức đã mở. | Code SaveManager/GameManager có đường lưu; persistence trên Android chưa chạy. | NOT RUN | Chưa có | Chưa ghi |
| SAVE-02 — Khôi phục tiến trình sau khi mở lại | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Đóng hẳn app, mở lại, chọn Continue. | Level Select hiển thị đúng những level đã mở; không khôi phục tick/Echo/lượt chơi dở. | Chưa chạy trên APK. | NOT RUN | Chưa có | Chưa ghi |
| AUDIO-01 — Điều khiển Sound ON/OFF từ UI | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Tìm Settings/Sound trong các màn hình và bật/tắt âm thanh. | Người chơi có lối thao tác rõ ràng để bật/tắt âm thanh. | Source audit không tìm thấy Settings scene/control hoặc UI caller của `GameManager.set_sound_enabled`; xem KI-01. | BLOCKED | Chưa có | Chưa ghi |
| AUDIO-02 — Lưu và khôi phục Sound preference | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Chuyển Sound ON/OFF qua UI, đóng hẳn app, mở lại và thử hiệu ứng. | Trạng thái Sound được khôi phục; OFF không phát âm thanh, ON cho phép phát. | GameManager có code load/save preference; chưa thể hoàn tất end-to-end vì UI toggle chưa thấy và chưa có APK. | BLOCKED | Chưa có | Chưa ghi |
| DEVICE-01 — Landscape trên thiết bị thật | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Cài APK trên thiết bị Android; xác nhận app mở và giữ layout landscape. | Gameplay hiển thị ngang đúng; không bị cắt HUD/nội dung quan trọng. | Android guide yêu cầu landscape; project.godot không ghi orientation; export preset cục bộ chưa có trong ZIP. | NOT RUN | Chưa có | Chưa ghi |
| DEVICE-02 — Tỷ lệ màn hình khác nhau | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Chạy APK ở ít nhất hai tỷ lệ/kích thước màn hình Android; kiểm tra Menu, HUD, Pause, Result. | Không chồng lấn, che nút, cắt chữ hoặc mất khả năng thao tác. | Chưa có thiết bị và APK để kiểm tra. | NOT RUN | Chưa có | Chưa ghi |
| TOUCH-01 — D-pad / WAIT / ENDLOOP / RESTART | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Thực hiện đủ 4 hướng, WAIT, ENDLOOP và RESTART bằng cảm ứng. | Mỗi lần chạm phát đúng action; các nút không bị che hoặc khó chạm. | Chưa chạy trên Android thật. | NOT RUN | Chưa có | Chưa ghi |
| TOUCH-02 — Chạm nhanh / double input | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Chạm liên tục nút di chuyển trong khi nhân vật đang tween/đang xử lý tick. | Không phát sinh double tick, mất đồng bộ Player/Echo hoặc thao tác ngoài ý muốn. | Chưa chạy trên Android thật. | NOT RUN | Chưa có | Chưa ghi |
| PERM-01 — Quyền ứng dụng / prompt | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Cài APK; ghi lại các quyền Android hiển thị và thời điểm xin quyền. | Chỉ xin quyền cần thiết, thông báo quyền đúng mục đích; không yêu cầu quyền không cần cho game offline. | Không có APK/manifest candidate để kiểm tra. | NOT RUN | Chưa có | Chưa ghi |
| CLONE-01 — Clone sạch và F5 | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Clone đúng commit release vào thư mục mới; Import project.godot bằng Godot 4.7.2; chạy F5. | Không phụ thuộc cache `.godot/` hay file local bị bỏ qua; F5 mở game được. | Chưa chạy clone sạch trong lượt rà soát này; Godot CLI/GUI không có trong môi trường thực hiện. | NOT RUN | Chưa có | Chưa ghi |
| SEC-01 — Quét artifact/secret trong source | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Kiểm tra file tracked và nội dung source; sau đó Leader review Git history/secret scan trên GitHub. | Không commit APK/AAB/keystore/password/private key/credential; không có secret trong lịch sử. | Trong working tree hiện tại không thấy file APK/AAB/keystore/JKS/P12/PFX/PEM/export_presets tracked; scan pattern giới hạn trong working tree không có hit. Chưa quét toàn bộ lịch sử Git/remote. | BLOCKED | Chưa có | Chưa ghi |
| DOC-01 — Tài liệu khớp APK cuối | Chưa có — APK candidate chưa được cung cấp | Chưa có | Chưa chạy / chưa ghi | Đối chiếu user guide, tên nút và luồng thực tế sau khi APK candidate được chốt. | Tài liệu không hướng dẫn tính năng không tồn tại; mọi khác biệt được ghi ở known issues. | Guide draft dựa trên source hiện tại; cần so sánh lại trên APK final. | NOT RUN | Chưa có | Chưa ghi |

## 5. Cách chạy và cập nhật ma trận

1. Lấy `main` mới nhất sau khi Leader merge candidate tích hợp; ghi SHA đầy đủ của commit.
2. Leader cung cấp APK candidate được build từ đúng commit đó. Cài lên Android thật và tính SHA-256 cho file APK; không lấy hash từ tên file.
3. Ghi mẫu thiết bị, phiên bản Android, ngày/giờ, người chạy và đường dẫn evidence.
4. Thực hiện các bước theo từng case. Chỉ chọn `PASS` khi actual khớp expected và có ảnh/video/log hoặc evidence link có thể mở.
5. Khi source hoặc APK thay đổi, tạo run/build record mới; không mang PASS cũ sang SHA mới.
6. Nếu phát hiện bug ngoài phạm vi TV5, ghi actual/evidence, gán đúng owner và mở Issue/PR riêng; TV5 không sửa code module đó.

## 6. Run record cho APK candidate (điền khi nhận APK)

| Trường | Giá trị |
|---|---|
| APK filename / version | Chưa có |
| Build commit full SHA | Chưa có |
| APK SHA-256 | Chưa có |
| Godot version / export template | Chưa xác nhận trên máy build |
| Build date/time | Chưa có |
| Device model | Chưa có |
| Android version / API level | Chưa có |
| Screen resolution / aspect ratio | Chưa có |
| Tester(s) | Chưa có |
| Evidence folder/link | Chưa có |
| Final result | NOT RUN |

## 7. Gate hiện tại

**Chưa đạt nghiệm thu Android.** Các test Android chưa chạy vì chưa có APK candidate, commit build, APK SHA-256 và thiết bị/OS trong evidence record. AUDIO-01/AUDIO-02 còn BLOCKED ở source/UI vì chưa thấy điều khiển Sound trong giao diện production. Chỉ Leader mới có thể chốt release gate sau khi các owner hoàn thành phần mình và evidence được review.
