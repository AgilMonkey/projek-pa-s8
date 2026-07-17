@icon("res://addons/at-icons/node2d/push_button.svg")
class_name WorldInteractButton
extends Area2D


signal button_pressed

## A quick reminder that button texture best perform at 32x32
@export var button_icon: Texture2D

@onready var world_button: WorldButton = $WorldButton
@onready var button_sprite: Sprite2D = %ButtonSprite

func _ready() -> void:
	button_sprite.texture = button_icon
	
	world_button.pressed.connect(func(): button_pressed.emit())
	
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _this_player_client_entered(_body: CharacterBody2D):
	world_button.modulate.a = 0.0
	world_button.position.y = 20.0
	
	var _tween := create_tween()
	_tween.tween_property(world_button, "modulate:a", 1.0, 0.1)
	_tween.parallel().tween_property(world_button, "position:y", 0.0, 0.1)
	
	world_button.show()


func _this_player_client_exited(_body: CharacterBody2D):
	var _tween := create_tween()
	_tween.tween_property(world_button, "modulate:a", 0.0, 0.1)
	_tween.parallel().tween_property(world_button, "position:y", 20.0, 0.1)
	
	_tween.tween_callback(world_button.hide)


func _body_entered(body: Node2D):
	if body.is_in_group("player") and body.is_multiplayer_authority() and body is CharacterBody2D:
		_this_player_client_entered(body)


func _body_exited(body: Node2D):
	if body.is_in_group("player") and body.is_multiplayer_authority():
		_this_player_client_exited(body)
