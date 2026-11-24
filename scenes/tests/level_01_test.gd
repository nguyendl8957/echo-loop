extends Node2D

func _ready() -> void:
	var level := LevelManager.load_level(1)
	var passed := false
	if level != null:
		var portal := preload("res://scenes/puzzle/exit_portal.tscn").instantiate() as ExitPortal
		$LevelPreview/InteractiveObjects.add_child(portal)
		portal.grid_position = level.exit_position
		passed = (
			level.level_name == "The First Memory"
			and level.switch_positions.size() == 1
			and level.door_configs.size() == 1
			and level.door_configs[0]["switch_indices"] == [0]
			and not portal.check_player_reached(level.player_start)
			and portal.position == Vector2(level.exit_position * 48 + Vector2i(24, 24))
			and portal.check_player_reached(level.exit_position)
		)

	var summary := "LEVEL 01 FIXTURE: " + ("PASS" if passed else "FAIL")
	$CanvasLayer/StatusLabel.text = summary
	print(summary)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if passed else 1)
