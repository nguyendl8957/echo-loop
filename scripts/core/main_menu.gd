extends Control

const GAMEPLAY_PATH = "res://scenes/gameplay/gameplay.tscn"

@onready var new_game_button: Button = $CenterContainer/MenuContent/NewGameButton
@onready var continue_button: Button = $CenterContainer/MenuContent/ContinueButton
@onready var tutorial_button: Button = $CenterContainer/MenuContent/TutorialButton
@onready var exit_button: Button = $CenterContainer/MenuContent/ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	continue_button.disabled = false
	tutorial_button.disabled = true

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed() -> void:
	GameManager.open_level_select()
