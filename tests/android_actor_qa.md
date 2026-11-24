# S05 — Android Player/Echo QA — Issue #27

## Trạng thái

Chưa chạy kiểm thử Android thực tế.
Người phụ trách hiện chỉ có iPhone, chưa có thiết bị Android.
Cần phối hợp thành viên có Android để chạy APK và cung cấp minh chứng.
Chưa có xác nhận gate S04 từ Leader.

## Thông tin bản kiểm thử

APK: EchoLoop-S05-Debug.apk
Commit build: Chưa xác nhận
SHA-256 APK: Chưa ghi nhận
Thiết bị Android: Chưa có
Phiên bản Android: Chưa ghi nhận
Hướng màn hình: Chưa kiểm tra
Người thực hiện trên Android: Chưa xác nhận
Ngày kiểm thử: Chưa chạy

## Các trường hợp kiểm thử

| ID | Thao tác | Kết quả mong đợi | Kết quả thực tế | Evidence |
| --- | --- | --- | --- | --- |
| A01 | Dùng d-pad di chuyển đủ bốn hướng | Hướng di chuyển khớp nút bấm, nhân vật đúng ô | NOT RUN | Chưa có |
| A02 | Chạm nhanh liên tiếp các nút hướng | Không lệch ô hoặc tick, không kẹt animation | NOT RUN | Chưa có |
| A03 | Di chuyển vào ô bị chặn | Không xuyên vật cản, thao tác vẫn tiêu tốn tick | NOT RUN | Chưa có |
| A04 | Chạy hết vòng và kết thúc vòng sớm | Giữ luật 12 tick; kết thúc sớm được đệm WAIT | NOT RUN | Chưa có |
| A05 | Tạo và phát lại Echo qua nhiều vòng | Tối đa 2 Echo, phát lại đúng chuỗi hành động | NOT RUN | Chưa có |
| A06 | Cho Player và Echo đứng cùng ô | Không lỗi hiển thị, không kẹt animation | NOT RUN | Chưa có |
| A07 | Restart rồi tiếp tục chơi | Trạng thái được đặt lại đúng, không crash | NOT RUN | Chưa có |
| A08 | Đưa ứng dụng xuống nền rồi quay lại | Không crash, không lệch trạng thái ô/tick | NOT RUN | Chưa có |
| A09 | Chơi khi pin yếu hoặc bật tiết kiệm pin | Ghi nhận lỗi thực tế nếu có, không suy đoán hiệu năng | NOT RUN | Chưa có |
| A10 | Quan sát Player/Echo trên nền môi trường | Phân biệt được Player, Echo 1 và Echo 2 | NOT RUN | Chưa có |

## Hiệu năng

NOT MEASURED — chưa đo trên thiết bị Android.

## Lỗi và kiểm tra lại

Chưa có kết quả kiểm thử để xác nhận lỗi.
Mỗi lỗi cần bước tái hiện, kết quả mong đợi, kết quả thực tế
và minh chứng gắn với bản APK.

Nếu có sửa lỗi, ghi commit sửa, kết quả F6 actor test
và kiểm tra lại APK mới do Leader cung cấp.
Ghi SHA-256 của APK được dùng khi kiểm tra lại.

## Kết luận

Chưa đủ điều kiện nghiệm thu Issue #27.
Đang chuẩn bị báo cáo và chờ phối hợp kiểm thử Android thực tế.