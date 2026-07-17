extends Node2D


@export var world_button: WorldInteractButton
@export var to_world: String
@export var teleport_position := Vector2.ZERO

var can_teleport := false


func _ready() -> void:
	world_button.button_pressed.connect(_change_world)


func _change_world():
	WorldManager.ask_server_for_world_change(to_world, teleport_position)
