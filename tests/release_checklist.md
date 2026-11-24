# S05-TV5 — Release Checklist

**Issue:** #30  
**Owner duy nhất:** TV5  
**Reviewer:** Leader  
**Trạng thái:** DRAFT — chưa phải xác nhận phát hành.

> Checklist này không thay thế test matrix. Không đánh dấu hoàn tất nếu không có record/evidence gắn với đúng commit và APK SHA-256.

## A. Source và branch

- [ ] Xác nhận `main` trên GitHub mới nhất; fetch/pull trước khi tạo branch.
- [ ] Tạo branch `feature/EL-S05-TV5` từ `main` mới nhất.
- [ ] Kiểm tra `git status`; không đưa các thay đổi cục bộ không thuộc Issue vào PR.
- [ ] Xác nhận PR chỉ chứa 5 tài liệu được Issue #30 giao; không sửa game logic, config, scene, `project.godot` hoặc assets.
- [ ] Ghi full commit SHA của source dùng để build APK.
- [ ] Leader review mọi thay đổi tài liệu có ảnh hưởng đến contract hoặc release instructions.

## B. Android export readiness (Leader / máy build)

- [ ] Mở project bằng Godot 4.7.2 stable theo tài liệu `docs/android_export_guide.md`.
- [ ] Cài đúng export templates tương ứng với Godot version.
- [ ] Kiểm tra Android SDK, JDK/Java SDK và đường dẫn trong Editor Settings.
- [ ] Kiểm tra Android export preset cục bộ: package identifier đã được nhóm duyệt.
- [ ] Kiểm tra App Name, launcher icon, splash, version/version code và architecture.
- [ ] Xác nhận orientation landscape trên preset thực tế; không suy ra từ `project.godot` vì file này chưa ghi orientation.
- [ ] Xác nhận renderer mobile đang dùng GL Compatibility như project configuration.
- [ ] Kiểm tra permission/manifest và chỉ giữ quyền cần thiết.
- [ ] Kiểm tra signing: Debug dùng debug signing; Release dùng keystore được Leader phê duyệt.
- [ ] Không commit `export_presets.cfg` nếu có thông tin nhạy cảm; không commit keystore, password, private key, APK/AAB hoặc file build.

## C. Build candidate và lưu release evidence

- [ ] Export APK candidate ra ngoài repository (`builds/`/`dist/` đang bị ignore, hoặc thư mục external do Leader chọn).
- [ ] Cài APK candidate lên ít nhất một thiết bị Android thật.
- [ ] Ghi source commit SHA đầy đủ.
- [ ] Ghi SHA-256 thực tế của đúng file APK đã cài/test.
- [ ] Ghi APK filename, version, build date/time và Godot/export-template version.
- [ ] Ghi device model, Android version/API level, resolution/aspect ratio và tester.
- [ ] Tạo thư mục/link evidence; đặt tên ảnh/video gắn với test case ID.
- [ ] Nếu code hoặc APK đổi, build lại, tính lại SHA-256 và chạy lại các test bị ảnh hưởng.

## D. Smoke test trên thiết bị thật

- [ ] Cài mới và mở ứng dụng; kiểm tra splash → Main Menu.
- [ ] Thử New Game, Continue/Level Select, How to play, Exit.
- [ ] Hoàn thành luồng Main Menu → New Game → Level 01 → win → Next → Level 05.
- [ ] Kiểm tra lời giải của cả 5 level; không crash, softlock hoặc kẹt cửa.
- [ ] Xác minh đúng 12 tick/vòng, WAIT và bước bị chặn vẫn tốn tick, ENDLOOP sớm đệm WAIT.
- [ ] Xác minh tối đa 2 Echo, Echo phát lại đúng và chỉ Player tại EXIT mới thắng.
- [ ] Kiểm tra snapshot Door đầu tick và cập nhật Switch/Door sau khi actor di chuyển.
- [ ] Kiểm tra Pause/Resume, Restart, Main Menu, Replay, Level Select và Next Level.
- [ ] Kiểm tra lưu mở khóa sau khi đóng/mở lại ứng dụng; không phục hồi tick/Echo/lượt đang giải dở.
- [ ] Kiểm tra Sound ON/OFF và restore preference sau khi có UI điều khiển hoặc phương thức thao tác được Leader duyệt.
- [ ] Kiểm tra landscape trên thiết bị thật; thử thêm tỷ lệ màn hình khác nếu có.
- [ ] Kiểm tra vùng chạm D-pad/WAIT/ENDLOOP/RESTART, không che map/HUD, không double-input khi chạm nhanh.
- [ ] Kiểm tra offline; ghi lại mọi permission prompt.
- [ ] Ghi crash, warning, lỗi hiển thị và FPS nếu đo được; không tự ghi “mượt” nếu chưa đo.

## E. Source clone sạch và bảo mật

- [ ] Clone repo vào thư mục mới, không clone đè project đang làm.
- [ ] Import `project.godot` bằng Godot 4.7.2; đợi import asset xong.
- [ ] Chạy F5 từ Main Menu trên clone sạch; ghi log/debugger.
- [ ] Xác nhận không phụ thuộc cache `.godot/` hay file import cục bộ chưa commit.
- [ ] Quét working tree và Git history/repository secret scanning; kiểm tra không lộ token, password, private key hoặc signing material.
- [ ] Kiểm tra APK/AAB/keystore/password/export credential không nằm trong Git index hoặc commit history.
- [ ] Kiểm tra `docs/`, `tests/` và đường dẫn evidence tồn tại đúng trên `main`.

## F. Tài liệu và nghiệm thu

- [ ] `tests/android_test_matrix.md` có case ID, build SHA, APK SHA-256, device/OS, steps, expected, actual, status, evidence link và tester cho từng dòng.
- [ ] Không có `NOT RUN` nào bị tính thành PASS; mọi BLOCKED/FAIL có owner và hướng xử lý.
- [ ] `tests/final_qa_report.md` tổng hợp đúng kết quả từ tất cả owners; tester xác nhận/ký báo cáo.
- [ ] `docs/known_issues.md` trung thực, phân loại mức độ và không giấu lỗi đã biết.
- [ ] `docs/user_guide_vi.md` khớp tên nút, màn hình và thao tác của APK cuối.
- [ ] README chỉ được cập nhật link evidence sau khi Leader review/đồng ý theo Issue #30.
- [ ] Leader phê duyệt release gate; có APK ổn định và source commit tương ứng để nộp.

## G. Trạng thái rà soát ban đầu của TV5 (2026-11-23)

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| Source ZIP đã kiểm tra | DONE — static review | HEAD trong ZIP: `b1b48b027bb5714e3c58832ed51d0f30563bacb4`; working tree có thay đổi cục bộ sẵn |
| 5 LevelData resources | FOUND — static review | Có Level 01–05; chưa thay thế kiểm thử gameplay trên APK |
| SaveManager / AudioManager | REVIEWED — source | Save chỉ có `unlocked_level`, `sound_enabled`; GameManager có load/save Sound |
| Sound setting UI | BLOCKED | Chưa thấy UI control/caller trong source; cần owner xác nhận/bổ sung qua Issue riêng |
| Android export preset / APK | NOT RUN | Không có candidate APK trong ZIP; export preset local bị ignore |
| Android real-device matrix | NOT RUN | Chưa có device/OS/evidence |
| README change | NOT STARTED | Chờ Leader review; TV5 không tự sửa |
| Release approval | BLOCKED | Chờ APK SHA, test thật, sign-off của testers và Leader |

**Quyền sở hữu:** TV5 là owner duy nhất của file `tests/release_checklist.md`; Leader review, không tạo file checklist trùng lặp.
