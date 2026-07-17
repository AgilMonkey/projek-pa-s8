@icon("res://addons/at-icons/node2d/push_button.svg")
class_name WorldInteractButton
extends Area2D


signal button_pressed

@export var button_icon: Texture2D

@onready var world_button: WorldButton = $WorldButton
@onready var button_sprite: Sprite2D = %ButtonSprite

func _ready() -> void:
	button_sprite.texture = button_icon
	
	world_button.pressed.connect(func(): button_pressed.emit())
	
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _this_player_client_entered(body: CharacterBody2D):
	world_button.show()


func _this_player_client_exited(body: CharacterBody2D):
	world_button.hide()


func _body_entered(body: Node2D):
	if body.is_in_group("player") and body.is_multiplayer_authority() and body is CharacterBody2D:
		_this_player_client_entered(body)


func _body_exited(body: Node2D):
	if body.is_in_group("player") and body.is_multiplayer_authority():
		_this_player_client_exited(body)
