extends Node2D

## Suite kiểm thử và xác thực dữ liệu Level 02–05 cho TV3 (Issue #23)
## Kiểm tra toàn vẹn Resource, quy tắc lưới, liên kết Switch/Door và mô phỏng lời giải đầy đủ 7 bước

var passed_count: int = 0
var failed_count: int = 0

@onready var fixture_node: Node2D = $LevelFixture
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var results_label: Label = $CanvasLayer/ResultsLabel

const DIR_MAP: Dictionary = {
	"UP": Vector2i(0, -1),
	"DOWN": Vector2i(0, 1),
	"LEFT": Vector2i(-1, 0),
	"RIGHT": Vector2i(1, 0),
	"WAIT": Vector2i(0, 0)
}

func _ready() -> void:
	print("==================================================")
	print("STARTING LEVELS VALIDATION SUITE (LEVELS 02 - 05)")
	print("==================================================")
	run_all_validations()

	var summary := "LEVELS VALIDATION: %d PASSED | %d FAILED" % [passed_count, failed_count]
	print(summary)
	print("==================================================")

	if status_label:
		status_label.text = "LEVELS VALIDATION COMPLETE"
	if results_label:
		results_label.text = summary
		results_label.modulate = Color.GREEN if failed_count == 0 else Color.RED

	# Thiết lập fixture preview cho Level 02 để hiển thị trực quan khi chạy F6
	var l2 := ResourceLoader.load("res://data/levels/level_02.tres") as LevelData
	if l2:
		_setup_fixture_preview(l2)

	# Nếu chạy ở chế độ headless (CI / CLI), tự động thoát với mã lỗi tương ứng
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if failed_count == 0 else 1)


func _setup_fixture_preview(lvl: LevelData) -> void:
	if not fixture_node:
		return
	for c in fixture_node.get_children():
		c.queue_free()

	const SWITCH_SCENE: PackedScene = preload("res://scenes/puzzle/pressure_switch.tscn")
	for sw_pos in lvl.switch_positions:
		var sw := SWITCH_SCENE.instantiate() as PressureSwitch
		fixture_node.add_child(sw)
		sw.grid_position = sw_pos
		sw.position = Vector2(sw_pos * 48) + Vector2(24, 24)

	const DOOR_SCENE: PackedScene = preload("res://scenes/puzzle/door.tscn")
	for cfg in lvl.door_configs:
		var d := DOOR_SCENE.instantiate() as Door
		fixture_node.add_child(d)
		var dpos: Vector2i = cfg.get("position", Vector2i.ZERO)
		d.grid_position = dpos
		d.position = Vector2(dpos * 48) + Vector2(24, 24)

	const EXIT_SCENE: PackedScene = preload("res://scenes/puzzle/exit_portal.tscn")
	var exit := EXIT_SCENE.instantiate() as ExitPortal
	fixture_node.add_child(exit)
	exit.grid_position = lvl.exit_position
	exit.position = Vector2(lvl.exit_position * 48) + Vector2(24, 24)


func check(condition: bool, description: String) -> void:
	if condition:
		passed_count += 1
		print("  [PASS] ", description)
	else:
		failed_count += 1
		push_error("  [FAIL] " + description)


func run_all_validations() -> void:
	# 1. Kiểm tra tĩnh dữ liệu 4 màn chơi
	for lvl_id in range(2, 6):
		var path := "res://data/levels/level_%02d.tres" % lvl_id
		validate_level_resource(lvl_id, path)

	# 2. Mô phỏng lời giải hoàn chỉnh theo 7 bước chuẩn của từng màn
	test_level_02_solution()
	test_level_03_solution()
	test_level_04_solution()
	test_level_05_solution()


## Kiểm tra tính hợp lệ về cấu trúc dữ liệu của file .tres
func validate_level_resource(expected_id: int, path: String) -> void:
	print("\n--- Validating Resource: %s ---" % path)
	check(ResourceLoader.exists(path), "%s exists on disk" % path)
	var res := ResourceLoader.load(path) as LevelData
	check(res != null, "%s loads as LevelData Resource" % path)
	if res == null:
		return

	check(res.level_id == expected_id, "level_id is %d" % expected_id)
	check(not res.level_name.is_empty(), "level_name is '%s'" % res.level_name)
	check(res.grid_width >= 5 and res.grid_width <= 9, "grid_width %d is in range [5, 9]" % res.grid_width)
	check(res.grid_height >= 5 and res.grid_height <= 9, "grid_height %d is in range [5, 9]" % res.grid_height)

	var schema_errors := res.validate_level()
	check(schema_errors.is_empty(), "schema validate_level() has 0 errors: %s" % str(schema_errors))

	# Kiểm tra Start và Exit không trùng nhau
	check(res.player_start != res.exit_position, "player_start != exit_position")

	# Kiểm tra công tắc
	check(not res.switch_positions.is_empty(), "Level has at least 1 switch")
	for i in range(res.switch_positions.size()):
		var sw: Vector2i = res.switch_positions[i]
		check(res.is_in_bounds(sw), "Switch %d at %s is in bounds" % [i, str(sw)])
		check(not res.wall_cells.has(sw), "Switch %d at %s does not overlap wall" % [i, str(sw)])
		check(sw != res.player_start, "Switch %d does not overlap player_start" % i)
		check(sw != res.exit_position, "Switch %d does not overlap exit_position" % i)

	# Kiểm tra cửa
	check(not res.door_configs.is_empty(), "Level has at least 1 door config")
	var door_positions: Array[Vector2i] = []
	for i in range(res.door_configs.size()):
		var cfg: Dictionary = res.door_configs[i]
		check(cfg.has("position") and cfg.has("switch_indices"), "Door config %d has position and switch_indices" % i)
		var dpos: Vector2i = cfg.get("position", Vector2i(-1, -1))
		check(res.is_in_bounds(dpos), "Door %d at %s is in bounds" % [i, str(dpos)])
		check(not res.wall_cells.has(dpos), "Door %d at %s does not overlap wall" % [i, str(dpos)])
		check(not door_positions.has(dpos), "Door %d at %s is not duplicate" % [i, str(dpos)])
		door_positions.append(dpos)

		var indices: Array = cfg.get("switch_indices", [])
		check(indices.size() >= 1 and indices.size() <= 2, "Door %d links to 1 or 2 switches" % i)
		for idx in indices:
			check(idx >= 0 and idx < res.switch_positions.size(), "Door %d switch index %d is valid" % [i, idx])


## ====================================================================
## BỘ MÔ PHỎNG GIẢI ĐỐ 7 BƯỚC CHUẨN (AGENTS.md Mục 2.6)
## ====================================================================
class PuzzleSimulator:
	var level: LevelData
	var player_pos: Vector2i
	var echo_positions: Array[Vector2i] = []
	var echo_recordings: Array[Array] = [] # Mảng chứa chuỗi 12 lệnh của từng Echo
	var current_recording: Array[String] = [] # Chuỗi lệnh đang ghi của Player
	var switch_states: Array[bool] = []
	var door_states: Array[bool] = []
	var level_won: bool = false
	var current_tick: int = 0

	func _init(p_level: LevelData) -> void:
		level = p_level
		reset_world()

	func reset_world() -> void:
		player_pos = level.player_start
		echo_positions.clear()
		for i in range(echo_recordings.size()):
			echo_positions.append(level.player_start)
		current_recording.clear()
		current_tick = 0
		level_won = false

		switch_states.clear()
		for sw in level.switch_positions:
			switch_states.append(false)

		door_states.clear()
		for cfg in level.door_configs:
			door_states.append(false)
		update_switches_and_doors()

	func get_all_actors() -> Array[Vector2i]:
		var actors: Array[Vector2i] = [player_pos]
		for ep in echo_positions:
			actors.append(ep)
		return actors

	func update_switches_and_doors() -> void:
		var actors := get_all_actors()
		# Cập nhật switch
		for i in range(level.switch_positions.size()):
			var sw_cell: Vector2i = level.switch_positions[i]
			switch_states[i] = actors.has(sw_cell)

		# Cập nhật door (AND logic cho các switch_indices liên kết)
		for i in range(level.door_configs.size()):
			var cfg: Dictionary = level.door_configs[i]
			var indices: Array = cfg.get("switch_indices", [])
			var all_active := true
			if indices.is_empty():
				all_active = false
			for idx in indices:
				if not switch_states[idx]:
					all_active = false
					break
			door_states[i] = all_active

	func can_enter_cell(current_cell: Vector2i, target_cell: Vector2i, door_snapshots: Array[bool]) -> bool:
		# Biên bản đồ
		if not level.is_in_bounds(target_cell):
			return false
		# Tường
		if level.wall_cells.has(target_cell):
			return false
		# Cửa: kiểm tra theo snapshot đầu tick
		for i in range(level.door_configs.size()):
			var dpos: Vector2i = level.door_configs[i]["position"]
			if target_cell == dpos:
				# Nếu đang đứng trên ô cửa, luôn được phép bước ra
				if current_cell == dpos:
					return true
				# Nếu bước vào từ ngoài, phải dựa vào snapshot đầu tick
				if not door_snapshots[i]:
					return false
		return true

	## Thực hiện 1 tick theo đúng 7 bước chuẩn
	func step_tick(player_action: String) -> void:
		assert(current_tick < 12, "Vuot qua 12 tick trong 1 loop!")

		# [Bước 1]: Chụp snapshot cửa đầu tick & Nhận lệnh Player
		var door_snapshots := door_states.duplicate()
		current_recording.append(player_action)

		# [Bước 2]: Lấy lệnh tương ứng của từng Echo
		var echo_actions: Array[String] = []
		for e_idx in range(echo_recordings.size()):
			var rec: Array = echo_recordings[e_idx]
			if current_tick < rec.size():
				echo_actions.append(rec[current_tick])
			else:
				echo_actions.append("WAIT")

		# [Bước 3 & 4]: Kiểm tra di chuyển & Cập nhật vị trí cùng lúc
		var p_dir: Vector2i = DIR_MAP.get(player_action, Vector2i.ZERO)
		var p_target := player_pos + p_dir
		if can_enter_cell(player_pos, p_target, door_snapshots):
			player_pos = p_target

		for e_idx in range(echo_positions.size()):
			var e_act: String = echo_actions[e_idx]
			var e_dir: Vector2i = DIR_MAP.get(e_act, Vector2i.ZERO)
			var e_target := echo_positions[e_idx] + e_dir
			if can_enter_cell(echo_positions[e_idx], e_target, door_snapshots):
				echo_positions[e_idx] = e_target

		# [Bước 5]: Cập nhật công tắc và cửa ở cuối tick
		update_switches_and_doors()

		# [Bước 6]: Kiểm tra thắng màn (CHỈ Player bước lên ExitPortal)
		if player_pos == level.exit_position:
			level_won = true

		# [Bước 7]: Tăng tick
		current_tick += 1

	## Kết thúc vòng lặp hiện tại, đệm WAIT và tạo Echo
	func finalize_loop() -> void:
		while current_recording.size() < 12:
			current_recording.append("WAIT")
		echo_recordings.append(current_recording.duplicate())
		reset_world()


## ====================================================================
## XÁC THỰC LỜI GIẢI CỦA 4 MÀN CHƠI
## ====================================================================

func test_level_02_solution() -> void:
	print("\n--- Testing Level 02: Hold the Door Solution ---")
	var lvl := ResourceLoader.load("res://data/levels/level_02.tres") as LevelData
	var sim := PuzzleSimulator.new(lvl)

	# VÒNG 1: Player đi lên Switch 0 tại (2, 1) và giữ công tắc
	var l1_actions: Array[String] = ["UP", "RIGHT", "WAIT"]
	for act in l1_actions:
		sim.step_tick(act)
	check(sim.player_pos == Vector2i(2, 1), "Level 02 - L1: Player reaches switch (2, 1)")
	check(sim.switch_states[0] == true, "Level 02 - L1: Switch 0 is active")
	check(sim.door_states[0] == true, "Level 02 - L1: Door is open at end of tick 2")
	sim.finalize_loop()
	check(sim.echo_recordings.size() == 1, "Level 02: Echo 1 recorded with 12 ticks")

	# VÒNG 2: Echo 1 giữ Switch 0, Player đi qua Door (4, 2) về đích (5, 2)
	# Tick 1: Player -> (2, 2). Echo -> (1, 1). Door closed đầu tick.
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(2, 2), "Level 02 - L2 Tick 1: Player at (2, 2)")
	check(sim.door_states[0] == false, "Level 02 - L2 Tick 1: Door closed while Echo in transit")

	# Tick 2: Player -> (3, 2). Echo -> (2, 1) (lên switch!). Cuối tick Door mở!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(3, 2), "Level 02 - L2 Tick 2: Player at (3, 2)")
	check(sim.echo_positions[0] == Vector2i(2, 1), "Level 02 - L2 Tick 2: Echo reaches switch (2, 1)")
	check(sim.door_states[0] == true, "Level 02 - L2 Tick 2: Door opens at tick end")

	# Tick 3: Snapshot đầu tick mở -> Player bước vào Door (4, 2)
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(4, 2), "Level 02 - L2 Tick 3: Player steps into open Door (4, 2)")

	# Tick 4: Player bước về đích ExitPortal (5, 2) -> THẮNG!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(5, 2), "Level 02 - L2 Tick 4: Player reaches ExitPortal (5, 2)")
	check(sim.level_won == true, "Level 02 - L2: Level 02 WON in 4 ticks of Loop 2!")


func test_level_03_solution() -> void:
	print("\n--- Testing Level 03: Echo Memory Solution ---")
	var lvl := ResourceLoader.load("res://data/levels/level_03.tres") as LevelData
	var sim := PuzzleSimulator.new(lvl)

	# VÒNG 1: Echo đi qua Switch 0 tại (3, 1) ở tick 3, sau đó bước xuống (3, 2) ở tick 4
	var l1_actions: Array[String] = ["UP", "RIGHT", "RIGHT", "DOWN", "WAIT"]
	for act in l1_actions:
		sim.step_tick(act)
	check(sim.echo_recordings.is_empty(), "Level 03: Recording loop 1")
	sim.finalize_loop()
	check(sim.echo_recordings.size() == 1, "Level 03: Echo 1 recorded")

	# VÒNG 2: Player căn nhịp: WAIT ở tick 1, di chuyển đến trước cửa đúng tick 3, bước qua cửa ở tick 4
	# Tick 1: Player WAIT tại (1, 2). Echo -> (1, 1). Door closed.
	sim.step_tick("WAIT")
	check(sim.player_pos == Vector2i(1, 2), "Level 03 - L2 Tick 1: Player waits at (1, 2)")

	# Tick 2: Player -> (2, 2). Echo -> (2, 1). Door closed.
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(2, 2), "Level 03 - L2 Tick 2: Player moves to (2, 2)")

	# Tick 3: Player -> (3, 2). Echo -> (3, 1) (đạp switch!). Cuối tick 3 Door mở!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(3, 2), "Level 03 - L2 Tick 3: Player at (3, 2)")
	check(sim.echo_positions[0] == Vector2i(3, 1), "Level 03 - L2 Tick 3: Echo 1 steps on Switch 0")
	check(sim.door_states[0] == true, "Level 03 - L2 Tick 3: Door (4, 2) opens at end of tick 3")

	# Tick 4: Snapshot đầu tick mở -> Player bước vào Door (4, 2)!
	# Cùng tick này, Echo rời switch xuống (3, 2) -> cuối tick cửa đóng nhưng Player đã ở trong!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(4, 2), "Level 03 - L2 Tick 4: Player enters Door (4, 2) while snapshot was open")
	check(sim.echo_positions[0] == Vector2i(3, 2), "Level 03 - L2 Tick 4: Echo stepped off switch")
	check(sim.door_states[0] == false, "Level 03 - L2 Tick 4: Door closed after Echo left")

	# Tick 5: Player bước ra khỏi cửa về ExitPortal (5, 2) -> THẮNG!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(5, 2), "Level 03 - L2 Tick 5: Player steps out to ExitPortal (5, 2)")
	check(sim.level_won == true, "Level 03 - L2: Level 03 WON in 5 ticks of Loop 2!")


func test_level_04_solution() -> void:
	print("\n--- Testing Level 04: Two Paths Solution ---")
	var lvl := ResourceLoader.load("res://data/levels/level_04.tres") as LevelData
	var sim := PuzzleSimulator.new(lvl)

	# VÒNG 1: Player đi theo Tuyến Bắc lên Switch 0 tại (5, 1)
	var l1_actions: Array[String] = ["UP", "UP", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "WAIT"]
	for act in l1_actions:
		sim.step_tick(act)
	check(sim.player_pos == Vector2i(5, 1), "Level 04 - L1: Player reaches North Switch (5, 1)")
	check(sim.door_states[0] == true, "Level 04 - L1: South Door (4, 5) opens")
	sim.finalize_loop()

	# VÒNG 2: Echo 1 đi Tuyến Bắc, Player đi Tuyến Nam
	# Ticks 1-4: Player đi xuống (1, 4) -> (1, 5) -> (2, 5) -> (3, 5)
	sim.step_tick("DOWN") # Tick 1 -> (1, 4)
	sim.step_tick("DOWN") # Tick 2 -> (1, 5)
	sim.step_tick("RIGHT") # Tick 3 -> (2, 5)
	sim.step_tick("RIGHT") # Tick 4 -> (3, 5)
	check(sim.player_pos == Vector2i(3, 5), "Level 04 - L2 Tick 4: Player reaches (3, 5)")
	check(sim.door_states[0] == false, "Level 04 - L2 Tick 4: Door still closed")

	# Ticks 5-6: Player WAIT ở (3, 5) chờ Echo đến Switch ở tick 6
	sim.step_tick("WAIT") # Tick 5
	sim.step_tick("WAIT") # Tick 6 -> Echo đạp switch tại (5, 1)!
	check(sim.echo_positions[0] == Vector2i(5, 1), "Level 04 - L2 Tick 6: Echo reaches Switch 0 (5, 1)")
	check(sim.door_states[0] == true, "Level 04 - L2 Tick 6: Door (4, 5) opens at end of tick 6")

	# Tick 7: Snapshot mở -> Player bước vào Door (4, 5)
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(4, 5), "Level 04 - L2 Tick 7: Player enters Door (4, 5)")

	# Tick 8: Player bước về đích (5, 5) -> THẮNG!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(5, 5), "Level 04 - L2 Tick 8: Player reaches ExitPortal (5, 5)")
	check(sim.level_won == true, "Level 04 - L2: Level 04 WON in 8 ticks of Loop 2!")


func test_level_05_solution() -> void:
	print("\n--- Testing Level 05: Double Echo Solution ---")
	var lvl := ResourceLoader.load("res://data/levels/level_05.tres") as LevelData
	var sim := PuzzleSimulator.new(lvl)

	# VÒNG 1: Player đi phòng trên đến Switch 0 tại (3, 1) và giữ
	var l1_actions: Array[String] = ["UP", "UP", "RIGHT", "RIGHT", "WAIT"]
	for act in l1_actions:
		sim.step_tick(act)
	check(sim.player_pos == Vector2i(3, 1), "Level 05 - L1: Player reaches Top Switch (3, 1)")
	check(sim.switch_states[0] == true, "Level 05 - L1: Switch 0 active")
	check(sim.door_states[0] == false, "Level 05 - L1: Door remains closed (needs Switch 1 as well)")
	sim.finalize_loop()
	check(sim.echo_recordings.size() == 1, "Level 05: Echo 1 recorded")

	# VÒNG 2: Player đi phòng dưới đến Switch 1 tại (3, 5) và giữ
	var l2_actions: Array[String] = ["DOWN", "DOWN", "RIGHT", "RIGHT", "WAIT"]
	for act in l2_actions:
		sim.step_tick(act)
	check(sim.player_pos == Vector2i(3, 5), "Level 05 - L2: Player reaches Bottom Switch (3, 5)")
	check(sim.switch_states[1] == true, "Level 05 - L2: Switch 1 active")
	# Ở tick 4 này, cả Echo 1 (trên) và Player (dưới) đều trên switch -> Door mở!
	check(sim.door_states[0] == true, "Level 05 - L2: Door opened with both switches held")
	sim.finalize_loop()
	check(sim.echo_recordings.size() == 2, "Level 05: Echo 2 recorded")

	# VÒNG 3: Cả Echo 1 và Echo 2 cùng giữ 2 switch, Player đi hành lang giữa về đích
	# Tick 1: Player WAIT tại (1, 3)
	sim.step_tick("WAIT")
	check(sim.player_pos == Vector2i(1, 3), "Level 05 - L3 Tick 1: Player at (1, 3)")

	# Ticks 2-4: Player đi thẳng (2, 3) -> (3, 3) -> (4, 3)
	sim.step_tick("RIGHT") # Tick 2 -> (2, 3)
	sim.step_tick("RIGHT") # Tick 3 -> (3, 3)
	sim.step_tick("RIGHT") # Tick 4 -> (4, 3)
	check(sim.player_pos == Vector2i(4, 3), "Level 05 - L3 Tick 4: Player in front of Door at (4, 3)")
	check(sim.echo_positions[0] == Vector2i(3, 1), "Level 05 - L3 Tick 4: Echo 1 on Top Switch (3, 1)")
	check(sim.echo_positions[1] == Vector2i(3, 5), "Level 05 - L3 Tick 4: Echo 2 on Bottom Switch (3, 5)")
	check(sim.door_states[0] == true, "Level 05 - L3 Tick 4: Both switches held -> Door opens!")

	# Tick 5: Snapshot mở -> Player bước vào Door (5, 3)
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(5, 3), "Level 05 - L3 Tick 5: Player enters Door (5, 3)")

	# Tick 6: Player bước về đích ExitPortal (6, 3) -> THẮNG HOÀN TOÀN LEVEL 05!
	sim.step_tick("RIGHT")
	check(sim.player_pos == Vector2i(6, 3), "Level 05 - L3 Tick 6: Player reaches ExitPortal (6, 3)")
	check(sim.level_won == true, "Level 05 - L3: Level 05 WON in 6 ticks of Loop 3 with 2 Echoes!")
