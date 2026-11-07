extends Control

signal back_requested

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	back_requested.emit()
	print("Tutorial: Back button pressed")
