
extends Control

signal pause_resume_requested
signal pause_restart_requested
signal pause_menu_requested

@onready var resume_button: Button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PausePanel/VBoxContainer/RestartButton
@onready var menu_button: Button = $PausePanel/VBoxContainer/MenuButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	pause_resume_requested.emit()
	print("Resume requested")

func _on_restart_pressed() -> void:
	pause_restart_requested.emit()
	print("Restart requested")

func _on_menu_pressed() -> void:
	pause_menu_requested.emit()
	print("Menu requested")
