extends Node2D

const MAIN_MENU_PATH = "res://scenes/menus/main_menu.tscn"

@onready var back_button: Button = $HUD/HUDRoot/CenterContainer/GameContent/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	GameManager.back_to_menu()
