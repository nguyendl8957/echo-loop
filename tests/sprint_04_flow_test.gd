extends Node

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== SPRINT 04 - LEVEL MANAGER TEST ===")

	for level_id in range(1, 6):
		_test_level(level_id)
		_test_level_access()

	print(
		"SPRINT 04 LEVEL LOADING: ",
		passed, " PASS | ", failed, " FAIL"
	)


func _test_level(level_id: int) -> void:
	var data: LevelData = LevelManager.load_level(level_id)

	if data == null:
		_check(false, "Level %02d loads" % level_id)
		return

	_check(true, "Level %02d loads" % level_id)

	_check(
		data.level_id == level_id,
		"Level %02d has correct ID" % level_id
	)

	_check(
		data.grid_width > 0 and data.grid_height > 0,
		"Level %02d has valid dimensions" % level_id
	)

	_check(
		data.is_in_bounds(data.player_start)
		and data.is_in_bounds(data.exit_position),
		"Level %02d has valid start and exit" % level_id
	)


func _check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("[PASS] ", description)
	else:
		failed += 1
		push_error("[FAIL] " + description)


func _test_level_access() -> void:
	print("\n--- LEVEL ACCESS TEST ---")

	var unlocked: int = GameManager.get_unlocked_level()

	_check(
		unlocked >= 1 and unlocked <= 5,
		"Unlocked level is within 1-5"
	)

	_check(
		GameManager.can_play_level(1),
		"Level 01 is always playable"
	)

	_check(
		GameManager.can_play_level(unlocked),
		"Highest unlocked level is playable"
	)

	_check(
		not GameManager.can_play_level(0),
		"Level 00 is rejected"
	)

	_check(
		not GameManager.can_play_level(6),
		"Level 06 is rejected"
	)

	if unlocked < 5:
		_check(
			not GameManager.can_play_level(unlocked + 1),
			"Next locked level is rejected"
		)
