class_name LevelManager
extends RefCounted

const MIN_LEVEL: int = 1
const MAX_LEVEL: int = 5
const LEVEL_DIRECTORY: String = "res://data/levels/"


static func load_level(level_id: int) -> LevelData:
	if level_id < MIN_LEVEL or level_id > MAX_LEVEL:
		push_error("Invalid level ID: " + str(level_id))
		return null

	var level_path: String = (
		LEVEL_DIRECTORY + "level_%02d.tres" % level_id
	)

	var resource: Resource = ResourceLoader.load(level_path)

	if not resource is LevelData:
		push_error("Cannot load LevelData: " + level_path)
		return null

	var data: LevelData = resource as LevelData
	var errors: Array = data.validate_level()

	if not errors.is_empty():
		push_error("Invalid LevelData: " + str(errors))
		return null

	return data
