class_name WorldButton
extends Area2D


signal pressed

const VALUE_ON_HOVER := 0.7
const VALUE_ON_PRESSED := 0.3

var is_hovered := false

@onready var button: Panel = $Button
@onready var button_sprite: Sprite2D = $ButtonSprite


func _mouse_enter() -> void:
	button.modulate.v = VALUE_ON_HOVER
	button_sprite.modulate.v = VALUE_ON_HOVER
	
	is_hovered = true


func _mouse_exit() -> void:
	button.modulate.v = 1.0
	button_sprite.modulate.v = 1.0
	
	is_hovered = false


func _input_event(_viewport: Viewport, _event: InputEvent, _shape_idx: int) -> void:
	if _event is InputEventMouseButton:
		if _event.button_index == 1 and _event.is_pressed():
			button.modulate.v = VALUE_ON_PRESSED
			button_sprite.modulate.v = VALUE_ON_PRESSED
			pressed.emit()
		else:
			if is_hovered:
				button.modulate.v = VALUE_ON_HOVER
				button_sprite.modulate.v = VALUE_ON_HOVER
			else:
				button.modulate.v = 1.0
				button_sprite.modulate.v = 1.0
