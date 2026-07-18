class_name PanelKonsep
extends PanelContainer


@onready var panel_konsep_exit_button: TextureButton = $PanelKonsepMarginContainer/MarginContainer/PanelKonsepExitButton


func _ready() -> void:
	panel_konsep_exit_button.pressed.connect(_exit_button_pressed)


func _exit_button_pressed():
	hide()
