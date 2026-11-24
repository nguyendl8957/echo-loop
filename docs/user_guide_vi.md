# Echo Loop — Hướng dẫn sử dụng (Tiếng Việt)

- **Phiên bản tài liệu** Level Design V2 và Final Polish
- **Đối chiếu source** `feature/EL-FINAL-polish`

**Lưu ý:** Cần đối chiếu lại tên nút, bố cục và thao tác trên APK release trước khi phát hành tài liệu này.

## 1. Giới thiệu

Echo Loop là game giải đố 2D theo lượt trên lưới. Người chơi điều khiển nhân vật chính qua các ô, ghi lại hành động trong từng vòng thời gian và sử dụng Echo để tái hiện hành động ở các vòng sau. Mục tiêu là phối hợp Player và Echo kích hoạt công tắc, mở cửa và đưa Player tới cổng thoát.

Game được thiết kế để chơi offline. Tiến trình mở khóa level và tùy chọn âm thanh được lưu cục bộ trên thiết bị.

## 2. Main Menu

Khi mở trò chơi, Main Menu hiện các nút:

- **New Game:** bắt đầu từ Level 01 – The First Memory.
- **Continue:** mở màn hình Level Select để chọn một màn đã mở khóa. Nút này không tiếp tục lại vị trí/tick của một lượt đang chơi dở.
- **How to play:** mở hướng dẫn; chọn **BACK** để quay về Main Menu.
- **Sound: ON/OFF:** bật hoặc tắt âm thanh.
- **Exit:** đóng ứng dụng.

## 3. Cách chơi và điều khiển

### 3.1. Di chuyển theo lưới

Trong Gameplay, sử dụng cụm nút trên màn hình:

| Nút | Tác dụng |
|---|---|
| UP | Di chuyển lên một ô |
| DOWN | Di chuyển xuống một ô |
| LEFT | Di chuyển sang trái một ô |
| RIGHT | Di chuyển sang phải một ô |
| WAIT | Đứng yên trong một tick |
| END LOOP | Kết thúc vòng hiện tại sớm và tạo Echo nếu còn lượt Echo |
| RESTART | Khởi động lại màn hiện tại |
| ⏸ | Mở Pause Menu |

Mỗi action hợp lệ tiêu tốn một tick. WAIT và hành động di chuyển bị chặn cũng tiêu tốn một tick, dù Player không đổi vị trí.

### 3.2. Tick và Time Loop

- Mỗi vòng có tối đa **12 tick**.
- Khi đủ 12 tick, vòng được kết thúc theo luật game.
- Người chơi có thể bấm **END LOOP** trước tick thứ 12. Các tick còn thiếu được hệ thống bổ sung bằng WAIT cho bản ghi của vòng.
- Khi sang vòng tiếp theo, thế giới được reset về vị trí/ trạng thái đầu vòng; lịch sử hành động của Echo đã tạo được giữ để phát lại.

### 3.3. Echo

- Vòng đầu chỉ có Player.
- Sau khi kết thúc vòng đầu, vòng tiếp theo có Echo 1 phát lại chuỗi hành động trước đó.
- Có tối đa **2 Echo**. Khi có đủ hai Echo, không thể tạo Echo thứ ba.
- Player và Echo có thể đứng cùng một ô/đi xuyên qua nhau.
- Echo không thể điều khiển trực tiếp và không thể tự hoàn thành màn.

### 3.4. Switch, Door và Exit

- Đứng trên Pressure Switch để kích hoạt công tắc.
- Door liên kết mở khi tất cả công tắc cần thiết đang được kích hoạt.
- Chữ trên cửa cho biết công tắc nào cần giữ. Ví dụ, A+B yêu cầu hai công tắc A và B cùng hoạt động.
- Mọi actor trong một tick dùng trạng thái Door được chụp ở đầu tick để kiểm tra di chuyển. Switch/Door được cập nhật sau khi các actor hoàn tất hành động trong tick đó.
- Chỉ **Player hiện tại** đến Exit khi đường đi hợp lệ mới hoàn thành màn. Echo đứng tại Exit không được tính là thắng.

## 4. HUD trong Gameplay

HUD hiển thị các thông tin chính:

- **LEVEL:** số, tên và gợi ý cho màn hiện tại.
- **TICK:** số tick đã dùng trên tổng 12 tick.
- **LOOP:** vòng hiện tại.
- **ECHO:** số Echo đã tạo trên tối đa 2.

Các nút điều khiển nằm ở vùng dưới màn hình. Bố cục và kích thước chạm thực tế cần được xác minh lại trên APK landscape của nhóm.

## 5. Pause, Restart và kết quả màn chơi

### 5.1. Pause Menu

Bấm biểu tượng **⏸** ở góc trên bên phải để mở Pause Menu.

- **RESUME:** tiếp tục màn hiện tại.
- **RESTART:** tải lại màn hiện tại và bắt đầu run mới.
- **MAIN MENU:** quay về Main Menu.

Khi Pause, input gameplay bị khóa; tick không được tăng do thao tác chơi trong lúc đang dừng.

### 5.2. Restart

Bấm **RESTART** trong HUD hoặc chọn **RESTART** ở Pause Menu để bắt đầu lại màn hiện tại. Run, tick và Echo của lần thử trước được reset. Tiến trình mở khóa đã lưu không bị xóa.

### 5.3. Level Complete

Khi Player tới Exit hợp lệ, màn hình **LEVEL COMPLETE** xuất hiện.

- **NEXT LEVEL:** chuyển sang màn kế tiếp nếu đã mở khóa; ở Level 05 nút này bị vô hiệu hóa.
- **REPLAY:** chơi lại level vừa hoàn thành.
- **LEVEL SELECT:** mở danh sách level.

## 6. Lưu tiến trình và Continue

Game lưu cục bộ hai thông tin:

- `unlocked_level`: level cao nhất đã mở khóa.
- `sound_enabled`: trạng thái bật/tắt âm thanh.

Game không lưu tick hiện tại, vị trí Player/Echo, action history hoặc lượt chơi dở. Vì vậy sau khi thoát và mở lại, người chơi chọn **Continue** để vào Level Select chứ không tiếp tục đúng tick đã dừng.

Nếu chưa có file save, mặc định là Level 01 đã mở và `sound_enabled = true`.

## 7. Âm thanh

Chọn **Sound: ON/OFF** trong Main Menu để đổi trạng thái. Game lưu lựa chọn và khôi phục khi mở lại.

## 8. Các level hiện có trong source

| Level | Tên | Trọng tâm puzzle theo tài liệu nhóm |
|---|---|---|
| 01 | The First Memory | Một Echo giữ công tắc A để Player qua cửa |
| 02 | Dual Protocol | Hai Echo cùng giữ hai công tắc |
| 03 | Memory Relay | Echo 1 mở lối cho Echo 2 |
| 04 | The Waiting Game | Chờ đúng nhịp để chuyển từ A sang B khi C đang được giữ |
| 05 | Temporal Paradox | Kết hợp mở đường cho Echo 2 và chuyển công tắc trong 12 tick |

Các mô tả này là tóm tắt mục tiêu thiết kế. Hướng dẫn chính thức cần được kiểm tra lại với gameplay và bản APK được phát hành.

## 9. Chơi offline và hỗ trợ

Game được thiết kế không cần đăng nhập hoặc máy chủ. Nếu gặp crash, nút không phản hồi hoặc bố cục bị che trên thiết bị, hãy ghi lại:

- Tên thiết bị và phiên bản Android.
- Level và thao tác ngay trước khi lỗi xuất hiện.
- Ảnh/video hoặc log nếu có.
- Phiên bản APK/build hoặc release tag.

Báo lỗi cho nhóm phát triển kèm các thông tin trên. Không chia sẻ file keystore, mật khẩu hoặc thông tin ký ứng dụng.

---

**Trạng thái tài liệu:** Đã cập nhật theo bản Windows. Cần đối chiếu trên APK cuối trước khi phát hành.
