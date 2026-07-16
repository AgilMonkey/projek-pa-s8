extends Area2D


@export var to_world: String
@export var teleport_position := Vector2.ZERO

var can_teleport := false


func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _input(_event: InputEvent) -> void:
	if can_teleport and Input.is_action_just_pressed("interact"):
		var _world_name
		WorldManager.ask_server_for_world_change(to_world, teleport_position)


func _body_entered(_body: Node2D):
	if _body is PlayerCharacter:
		if _body.is_multiplayer_authority():
			can_teleport = true


func _body_exited(_body: Node2D):
	if _body is PlayerCharacter:
		if _body.is_multiplayer_authority():
			can_teleport = false
