class_name PanelKonsep
extends PanelContainer


@onready var panel_konsep_exit_button: TextureButton = $PanelKonsepMarginContainer/MarginContainer/PanelKonsepExitButton
@onready var konsep_container: MarginContainer = $"PanelKonsepMarginContainer/KonsepContainer"


func _ready() -> void:
	panel_konsep_exit_button.pressed.connect(_exit_button_pressed)


func show_konsep(konsep_scene: PackedScene):
	for n in konsep_container.get_children():
		n.queue_free()
	
	var _konsep: Control = konsep_scene.instantiate()
	konsep_container.add_child(_konsep)
	show()


func _exit_button_pressed():
	hide()
