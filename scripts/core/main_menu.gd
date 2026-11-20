extends Control

const TUTORIAL_SCENE: PackedScene = preload(
	"res://scenes/ui/tutorial.tscn"
)

@onready var new_game_button: Button = (
	$CenterContainer/MenuContent/NewGameButton
)

@onready var continue_button: Button = (
	$CenterContainer/MenuContent/ContinueButton
)

@onready var tutorial_button: Button = (
	$CenterContainer/MenuContent/TutorialButton
)

@onready var exit_button: Button = (
	$CenterContainer/MenuContent/ExitButton
)

var tutorial_instance: Control = null


func _ready() -> void:
	new_game_button.pressed.connect(
		_on_new_game_pressed
	)

	continue_button.pressed.connect(
		_on_continue_pressed
	)

	tutorial_button.pressed.connect(
		_on_tutorial_pressed
	)

	exit_button.pressed.connect(
		_on_exit_pressed
	)

	continue_button.disabled = false
	tutorial_button.disabled = false


func _on_new_game_pressed() -> void:
	GameManager.start_new_game()


func _on_continue_pressed() -> void:
	GameManager.open_level_select()


func _on_tutorial_pressed() -> void:
	if is_instance_valid(tutorial_instance):
		return

	tutorial_instance = (
		TUTORIAL_SCENE.instantiate() as Control
	)

	if tutorial_instance == null:
		push_error("Cannot instantiate Tutorial.")
		return

	add_child(tutorial_instance)

	tutorial_instance.connect(
		"back_requested",
		Callable(self, "_on_tutorial_back_requested")
	)


func _on_tutorial_back_requested() -> void:
	if is_instance_valid(tutorial_instance):
		tutorial_instance.queue_free()

	tutorial_instance = null


func _on_exit_pressed() -> void:
	get_tree().quit()
