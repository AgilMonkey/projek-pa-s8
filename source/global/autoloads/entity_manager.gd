extends Node

## world_name: { peer_id: { data } }
var worlds_entities_data := {}

var client_cur_entity_spawner: EntitySpawner


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func put_player_in_world(peer_id: int, world_name: String, pos: Vector2):
	for world in worlds_entities_data:
		if worlds_entities_data.has(world):
			if worlds_entities_data[world].has(peer_id):
				worlds_entities_data[world].erase(peer_id)
	
	var p_data := {
		world_name: {
			peer_id: {
				"peer_id": peer_id,
				"position": pos
			}
		}
	}
	
	if worlds_entities_data.has(world_name):
		worlds_entities_data[world_name][peer_id] = p_data[world_name][peer_id]
	else:
		worlds_entities_data[world_name] = p_data[world_name]
	
	var data = { world_name: worlds_entities_data[world_name]}
	WorldManager.client_spawn_world_with_data.rpc_id(
		peer_id,
		world_name,
		data
	)
	
	WorldManager.sync_this_world_data_across_client.rpc(data)


@rpc("any_peer")
func update_this_peer_player(world_name: String, peer_id:int, data: Dictionary):
	worlds_entities_data[world_name][peer_id] = data
	
	var new_data = { world_name: worlds_entities_data[world_name]}
	WorldManager.client_sync_this_world_data.rpc_id(
		peer_id,
		new_data
	)
	
	WorldManager.sync_this_world_data_across_client.rpc(new_data)


func _on_peer_disconnected(peer_id: int):
	for w in worlds_entities_data:
		worlds_entities_data[w].erase(peer_id)
		if !worlds_entities_data[w].has(peer_id): continue
		update_this_peer_player.rpc_id(peer_id, w, peer_id, worlds_entities_data[w])
