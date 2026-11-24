# Echo Loop — Lời giải và kiểm chứng Level Design V2

Dữ liệu trên nhánh `feature/EL-FINAL-polish` dựa trên baseline Sprint 05 `5aed183`. Tọa độ bắt đầu từ (0,0) ở góc trái trên, X sang phải, Y xuống dưới. `#` là vật cản, `.` là sàn, S là Start, E là Exit, A–C là công tắc và 1–3 là cửa. Lệnh U/D/L/R/W lần lượt là lên/xuống/trái/phải/WAIT. Sau khi bấm END LOOP, mọi tick còn thiếu trong bản ghi được đệm W. P là Player, E1/E2 là các Echo.

| Màn | Tên | Echo tối thiểu | Loop thắng | Tick thắng |
|---:|---|---:|---:|---:|
| 1 | The First Memory | 1 | 2 | 6 |
| 2 | Dual Protocol | 2 | 3 | 9 |
| 3 | Memory Relay | 2 | 3 | 10 |
| 4 | The Waiting Game | 2 | 3 | 11 |
| 5 | Temporal Paradox | 2 | 3 | 12 |

## 01 The First Memory

```text
#############
#......#....#
#.A.#..#.#..#
#......#....#
#..S...1.E..#
#......#....#
#.#..#.#..#.#
#......#....#
#############
```

Start (3,4), Exit (9,4). A (2,2). Cửa 1 (7,4) cần A.

- Loop 1 `U U L`, sau đó **END LOOP**.
- Loop 2 `R R R R R R`.

Cuối tick 3, Echo 1 kích hoạt A và mở cửa 1. Player vào cửa ở tick 4, chạm Exit ở tick 6.

| Tick loop cuối | Lệnh E1 / P | Vị trí E1 / P | Switch cuối tick | Cửa mở đầu → cuối |
|---:|---|---|---|---|
| 1 | U / R | (3,3) / (4,4) | — | — → — |
| 2 | U / R | (3,2) / (5,4) | — | — → — |
| 3 | L / R | (2,2) / (6,4) | A | — → 1 |
| 4 | W / R | (2,2) / (7,4) | A | 1 → 1 |
| 5 | W / R | (2,2) / (8,4) | A | 1 → 1 |
| 6 | W / R | (2,2) / (9,4) | A | 1 → 1 |

## 02 Dual Protocol

```text
#############
#...#...#...#
#.....S.....#
#.A.#...#...#
#...#...#.B.#
######1######
#.#.......#.#
#...#.E.#...#
#############
```

Start (6,2), Exit (6,7). A (2,3) ở cánh trái, B (10,4) ở cánh phải. Cửa 1 (6,5) mở về phía nam khi A+B cùng hoạt động.

- Loop 1 `L L L L D`, sau đó **END LOOP**.
- Loop 2 `R R R R D D`, sau đó **END LOOP**.
- Loop 3 `D D W W W W D D D`.

Echo 1 đến A ở tick 5. Echo 2 đến B ở tick 6. Player đợi từ tuyến giữa rồi đi qua cửa ở tick 7, sau đó đi thẳng xuống cổng ở tick 9.

| Tick loop cuối | Lệnh E1 / E2 / P | Vị trí E1 / E2 / P | Switch cuối tick | Cửa mở đầu → cuối |
|---:|---|---|---|---|
| 1 | L / R / D | (5,2) / (7,2) / (6,3) | — | — → — |
| 2 | L / R / D | (4,2) / (8,2) / (6,4) | — | — → — |
| 3 | L / R / W | (3,2) / (9,2) / (6,4) | — | — → — |
| 4 | L / R / W | (2,2) / (10,2) / (6,4) | — | — → — |
| 5 | D / D / W | (2,3) / (10,3) / (6,4) | A | — → — |
| 6 | W / D / W | (2,3) / (10,4) / (6,4) | AB | — → 1 |
| 7 | W / W / D | (2,3) / (10,4) / (6,5) | AB | 1 → 1 |
| 8 | W / W / D | (2,3) / (10,4) / (6,6) | AB | 1 → 1 |
| 9 | W / W / D | (2,3) / (10,4) / (6,7) | AB | 1 → 1 |

## 03 Memory Relay

```text
#############
#...#.#...#.#
#.A...1.B...#
#.....#######
#..S....#...#
#.......2.E.#
#.#..#..#...#
#.......#.#.#
#############
```

Start (3,4), Exit (10,5). A (2,2), B (8,2). Cửa 1 (6,2) cần A, 2 (8,5) cần A+B.

- Loop 1 `U U L`, sau đó **END LOOP**.
- Loop 2 `U U R R R R R`, sau đó **END LOOP**.
- Loop 3 `D R R R R W R R R R`.

Echo 1 tới A ở tick 3. Ở loop 2 và loop 3, người đi tuyến B qua cửa 1 ở tick 5 và tới B ở tick 7. Cửa 2 mở cuối tick 7. Player thử vào cửa ngay tick 7 vẫn bị chặn, rồi vào được ở tick 8.

| Tick loop cuối | Lệnh E1 / E2 / P | Vị trí E1 / E2 / P | Switch cuối tick | Cửa mở đầu → cuối |
|---:|---|---|---|---|
| 1 | U / U / D | (3,3) / (3,3) / (3,5) | — | — → — |
| 2 | U / U / R | (3,2) / (3,2) / (4,5) | — | — → — |
| 3 | L / R / R | (2,2) / (4,2) / (5,5) | A | — → 1 |
| 4 | W / R / R | (2,2) / (5,2) / (6,5) | A | 1 → 1 |
| 5 | W / R / R | (2,2) / (6,2) / (7,5) | A | 1 → 1 |
| 6 | W / R / W | (2,2) / (7,2) / (7,5) | A | 1 → 1 |
| 7 | W / R / R | (2,2) / (8,2) / (7,5) | AB | 1 → 12 |
| 8 | W / W / R | (2,2) / (8,2) / (8,5) | AB | 12 → 12 |
| 9 | W / W / R | (2,2) / (8,2) / (9,5) | AB | 12 → 12 |
| 10 | W / W / R | (2,2) / (8,2) / (10,5) | AB | 12 → 12 |

## 04 The Waiting Game

```text
#############
#.C....#.#..#
#....#.#.#..#
#..#...#.#.##
#....#.#.#..#
#.B....#.#..#
#.A.S..1.2E.#
#..#...#.#..#
#############
```

Start (4,6), Exit (10,6). A (2,6), B (2,5), C (2,1). Cửa 1 (7,6) cần A+C, 2 (9,6) cần B+C.

- Loop 1 `L L W W W W W U`, sau đó **END LOOP**.
- Loop 2 `U U U U U L L`, sau đó **END LOOP**.
- Loop 3 `R R W W W W W R R R R`.

Echo 1 giữ A từ cuối tick 2 đến hết tick 7. Echo 2 đến C ở tick 7. Trong tick 8, Player vào cửa 1 theo snapshot A+C trong khi Echo 1 chuyển sang B. Cuối tick đó cửa 1 đóng và cửa 2 mở. Player rời ô cửa đóng ở tick 9, qua cửa 2 ở tick 10 và tới Exit ở tick 11.

| Tick loop cuối | Lệnh E1 / E2 / P | Vị trí E1 / E2 / P | Switch cuối tick | Cửa mở đầu → cuối |
|---:|---|---|---|---|
| 1 | L / U / R | (3,6) / (4,5) / (5,6) | — | — → — |
| 2 | L / U / R | (2,6) / (4,4) / (6,6) | A | — → — |
| 3 | W / U / W | (2,6) / (4,3) / (6,6) | A | — → — |
| 4 | W / U / W | (2,6) / (4,2) / (6,6) | A | — → — |
| 5 | W / U / W | (2,6) / (4,1) / (6,6) | A | — → — |
| 6 | W / L / W | (2,6) / (3,1) / (6,6) | A | — → — |
| 7 | W / L / W | (2,6) / (2,1) / (6,6) | AC | — → 1 |
| 8 | U / W / R | (2,5) / (2,1) / (7,6) | BC | 1 → 2 |
| 9 | W / W / R | (2,5) / (2,1) / (8,6) | BC | 2 → 2 |
| 10 | W / W / R | (2,5) / (2,1) / (9,6) | BC | 2 → 2 |
| 11 | W / W / R | (2,5) / (2,1) / (10,6) | BC | 2 → 2 |

## 05 Temporal Paradox

```text
#############
#....#..#...#
#.A..1.C#...#
#.B..########
#..S..2..3.E#
#.....#..#..#
#.#.#.#..##.#
#.....#..#..#
#############
```

Start (3,4), Exit (11,4). A (2,2), B (2,3), C (7,2). Cửa 1 (5,2) cần A, 2 (6,4) cần A+C, 3 (9,4) cần B+C.

- Loop 1 `U U L W W W D`, sau đó **END LOOP**.
- Loop 2 `U U R R R R`, sau đó **END LOOP**.
- Loop 3 `R R W W W W R R R R R R`.

Cuối tick 3, A mở cửa relay 1. Echo 2 qua cửa này ở tick 4 và tới C ở tick 6. Player vào cửa 2 ở tick 7 trong lúc Echo 1 chuyển A → B. Cửa 2 đóng và cửa 3 mở cuối tick 7. Player rời cửa 2 ở tick 8, vào cửa 3 ở tick 10 và thắng ở tick 12. C cách Start ít nhất 6 bước. Cửa 2 bắt buộc và cần C từ đầu tick, nên tick 7 là mốc vào cửa sớm nhất. Cổng còn cách cửa 2 năm bước.

| Tick loop cuối | Lệnh E1 / E2 / P | Vị trí E1 / E2 / P | Switch cuối tick | Cửa mở đầu → cuối |
|---:|---|---|---|---|
| 1 | U / U / R | (3,3) / (3,3) / (4,4) | — | — → — |
| 2 | U / U / R | (3,2) / (3,2) / (5,4) | — | — → — |
| 3 | L / R / W | (2,2) / (4,2) / (5,4) | A | — → 1 |
| 4 | W / R / W | (2,2) / (5,2) / (5,4) | A | 1 → 1 |
| 5 | W / R / W | (2,2) / (6,2) / (5,4) | A | 1 → 1 |
| 6 | W / R / W | (2,2) / (7,2) / (5,4) | AC | 1 → 12 |
| 7 | D / W / R | (2,3) / (7,2) / (6,4) | BC | 12 → 3 |
| 8 | W / W / R | (2,3) / (7,2) / (7,4) | BC | 3 → 3 |
| 9 | W / W / R | (2,3) / (7,2) / (8,4) | BC | 3 → 3 |
| 10 | W / W / R | (2,3) / (7,2) / (9,4) | BC | 3 → 3 |
| 11 | W / W / R | (2,3) / (7,2) / (10,4) | BC | 3 → 3 |
| 12 | W / W / R | (2,3) / (7,2) / (11,4) | BC | 3 → 3 |

## Kiểm chứng số Echo tối thiểu

`scenes/tests/levels_validation_test.tscn` duyệt theo từng tick từ 1 đến 12. Mỗi trạng thái lưu ô Player và ô Echo nếu có. Cửa bắt đầu đóng và ở các tick sau được suy ra từ vị trí cuối tick trước. Bộ kiểm chứng cho Echo tự chọn mọi action mỗi tick, bao gồm cả các lịch trình mà một bản ghi thật có thể không tạo được. Nếu Player vẫn không tới Exit với quyền rộng hơn này, một lịch sử phát lại hợp lệ cũng không thể thắng với cùng số Echo.

| Màn | Trạng thái ở tick 12 với 0 Echo | Trạng thái ở tick 12 với 1 Echo |
|---:|---:|---:|
| 1 | 39 | Đã có lời giải |
| 2 | 38 | 1444 |
| 3 | 40 | 2340 |
| 4 | 38 | 1444 |
| 5 | 30 | 1200 |

Bộ test cũng duyệt toàn bộ các ô có thể đến khi đóng riêng từng cửa. Với cửa relay ở Level 03 và 05, ô đích của phép duyệt là công tắc bên trong buồng relay. Với các cửa còn lại, ô đích là Exit. Cách này kiểm tra cấu trúc lối đi ngay cả khi giả định tất cả cửa khác luôn mở.

Lời giải chạy qua HUD và Gameplay thật. Bài test đối chiếu tọa độ từng actor, căn ô 48 px, trạng thái từng công tắc và cửa sau mỗi tick, điều kiện thắng và giới hạn Next Level. Fixture vô hiệu hóa ghi tiến trình trong lúc phát lại lời giải.

Xem [bằng chứng Android trên baseline Sprint 05](evidence/level_solutions.md) và [báo cáo QA của bản polish](final_qa_report.md).
