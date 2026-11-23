# Echo Loop — Known Issues & Release Risks

**Issue:** #30 — S05-TV5  
**Owner tài liệu:** TV5  
**Ngày rà soát source:** 2026-11-23  
**Baseline:** `main` trong `echo-loop(8).zip`, commit `b1b48b027bb5714e3c58832ed51d0f30563bacb4`  
**Nguyên tắc:** Phân biệt defect đã tái hiện với khoảng trống kiểm thử/thiết lập. Không gọi một mục là bug runtime nếu chưa tái hiện.

## 1. Danh sách hiện tại

| ID | Mức độ | Phân loại | Mô tả / bằng chứng source | Ảnh hưởng | Owner đề xuất | Trạng thái |
|---|---|---|---|---|---|---|
| KI-01 | High — release acceptance | Source-observed UI gap | Có `GameManager.set_sound_enabled()` và `is_sound_enabled()`, đồng thời load preference trong `_initialize_audio()`. Tuy nhiên source audit không tìm thấy Settings scene, CheckButton hoặc UI caller cho phương thức bật/tắt âm thanh. | Người chơi chưa có lối thao tác bật/tắt Sound được thấy trong UI; test Sound ON/OFF từ góc nhìn người chơi chưa thể thực hiện. | Leader xác nhận API/ownership; TV4 nếu cần UI control. TV5 chỉ retest. | BLOCKED — cần owner xác nhận hoặc mở Issue riêng. |
| KI-02 | High — release configuration | Verification gap | `docs/android_export_guide.md` yêu cầu Android landscape; `project.godot` trong snapshot không khai báo orientation rõ ràng; `export_presets.cfg` bị `.gitignore` loại khỏi repo. | Không thể kết luận APK giữ landscape nếu chưa kiểm tra Android export preset và thiết bị thật. | Leader / người build APK. | NOT RUN — chờ APK/preset thực tế. |
| KI-03 | Blocker — release evidence | Missing input | Source ZIP không có APK candidate; chưa có build commit SHA, APK SHA-256, version hoặc ngày build. | Không thể ràng buộc test result với đúng artifact; không thể ký final QA report. | Leader cung cấp APK candidate và metadata. | BLOCKED. |
| KI-04 | High — mobile QA | Verification gap | Chưa có evidence thiết bị Android về cài đặt, launch, tỷ lệ màn hình, vùng chạm, double-input, offline và permission. | Chưa thể chấp nhận release Android dù F5/F6 trên PC đã được báo cáo trước đó. | TV5 tổng hợp; TV2/TV3/TV4 xử lý lỗi theo module; Leader chốt. | NOT RUN. |
| KI-05 | Medium — repository hygiene | Verification gap | ZIP có working tree dirty: ba `.import` tracked thay đổi, `tests/test_matrix.md` modified và ba `.uid` untracked. `feature/EL-S05-TV5` chưa có trong refs của ZIP. | Có nguy cơ stage/commit nhầm thay đổi không thuộc Issue nếu dùng `git add .`; branch cần tạo từ `main` mới nhất sau khi fetch. | TV5 giữ phạm vi; Leader hỗ trợ merge/base. | OPEN — phải xử lý trước PR. |
| KI-06 | Medium — documentation sync | Documentation follow-up | README hiện còn phần mô tả Skeleton lịch sử ở đầu file và đã có ghi chú nói phần đó không còn phản ánh đầy đủ trạng thái hiện tại. | Người đọc mới có thể nhầm trạng thái nếu không đọc ghi chú Sprint 04. | Leader review; TV5 chỉ cập nhật link evidence nếu được duyệt. | WAIT — không sửa README trước Leader review. |
| KI-07 | Low — evidence completeness | Verification gap | Android export guide hiện ghi APK export, physical install/launch và full gameplay Android regression là NOT RUN; mục cuối còn nhắc Issue #26 trong khi nhiệm vụ QA hiện tại là Issue #30. | Hướng dẫn export chưa phải release evidence; cần cập nhật sau khi có kết quả mới. | Leader owner Android export; TV5 phối hợp update docs nếu được giao. | OPEN — chờ build/evidence. |
| KI-08 | High — release gate | Verification gap | Các kết quả F5/F6 được ghi trong `tests/sprint_04_regression.md` là reported integration results trên PC; chưa có Android matrix gắn với APK SHA. | Không được dùng PASS của F5/F6 cũ thay cho QA APK Sprint 05. | TV5 và tất cả owners; Leader phê duyệt. | BLOCKED. |

## 2. Phân loại rõ ràng

### 2.1. Source-observed item

- **KI-01** là khoảng trống có thể quan sát qua source: tồn tại API lưu và khôi phục Sound preference, nhưng chưa thấy đường đi từ UI production tới API điều khiển. Đây chưa phải lỗi âm thanh phát sai; cần xác nhận thiết kế UI và ownership.

### 2.2. Release / environment items chưa kiểm chứng

- **KI-02–KI-04, KI-07–KI-08** hiện là thiếu metadata, cấu hình export hoặc bằng chứng Android. Không được mô tả là bug đã tái hiện nếu chưa chạy APK.
- Nếu kiểm thử phát hiện crash, sai bố cục, input sai hoặc mất save, TV5 ghi case ID + Actual + evidence + build SHA và giao đúng owner bằng Issue riêng.

### 2.3. Repository collaboration item

- **KI-05:** giữ nguyên những thay đổi cục bộ có sẵn trong ZIP. Không xóa/reset/commit thay đổi của thành viên khác. Khi tạo PR TV5, chỉ stage 5 file Issue #30 giao.
- **KI-06:** không cập nhật README khi chưa có review của Leader, đúng điều kiện Issue #30.

## 3. Khi nào được đóng issue

Một mục chỉ được chuyển RESOLVED/CLOSED khi có tất cả thông tin phù hợp:

1. Owner xử lý hoặc xác nhận quyết định kỹ thuật.
2. Có PR/commit chứa thay đổi nếu cần sửa code/tài liệu.
3. Có retest trên đúng build; ghi full source commit SHA và APK SHA-256 nếu là APK-related.
4. Có expected/actual, status và evidence link.
5. Leader review các thay đổi ảnh hưởng release configuration, API hoặc release gate.

## 4. Ghi chú release

- APK, AAB, keystore, signing password, private key, export credentials không được commit vào repository.
- Scan pattern giới hạn trên working tree của ZIP không phát hiện private-key header hoặc một số token/API-key pattern phổ biến; chưa thực hiện full-history/remote secret scan.
- Danh sách known issues phải được cập nhật lần cuối sau khi test trên APK release candidate; không xóa mục chỉ vì không còn tái hiện trên PC.
