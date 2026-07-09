class_name PlayerEntitySyncer
extends Node


var this_peer_id: int
var entity_data := {
	"position": Vector2.ZERO
}

func _ready() -> void:
	entity_data["position"] = get_parent().global_position


func _physics_process(_delta: float) -> void:
	if this_peer_id != multiplayer.get_unique_id():
		_get_this_entity_data()
		return
	
	var new_data := {
		"peer_id": this_peer_id,
		"position": get_parent().global_position,
	}
	
	EntityManager.update_this_peer_player.rpc_id(
		1,
		WorldManager.client_cur_world_name,
		this_peer_id,
		new_data
	)


func _get_this_entity_data():
	var cur_w_data: Dictionary = WorldManager.client_cur_world_data[WorldManager.client_cur_world_name]
	if !cur_w_data.has(this_peer_id): return
	
	entity_data = WorldManager.client_cur_world_data[WorldManager.client_cur_world_name][this_peer_id]
