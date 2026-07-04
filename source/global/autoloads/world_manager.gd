extends Node

signal world_entites_data_updated

var client_cur_world_name := ""
var client_cur_world_data := {}
var client_cur_world_node: Node2D


## Make sure that the world it tries to change is different
func ask_server_for_world_change(world_name: String, pos := Vector2.ZERO):
	if client_cur_world_name == world_name: return
	
	await WorldManager.client_unspawn_old_world()
	WorldManager._server_world_change.rpc_id(
				1,
				world_name,
				pos
			)


@rpc("any_peer")
func _server_world_change(world_name: String, pos := Vector2.ZERO):
	if !multiplayer.is_server(): return
	var peer_id := multiplayer.get_remote_sender_id()
	
	if !Worlds.is_valid_world_name(world_name): return
	
	EntityManager.put_player_in_world(peer_id, world_name, pos)


@rpc("authority")
func client_spawn_world_with_data(world_name: String, data: Dictionary):
	if client_cur_world_name == "":  # No world spawned yet
		client_cur_world_data = data
		client_cur_world_name = world_name
		
		var world_scene = Worlds.get_world_scene(world_name).instantiate()
		get_tree().current_scene.add_child(world_scene, true)
		client_cur_world_node = world_scene
		print("[CLIENT]: spawned ", world_name)
		return
	elif client_cur_world_name != world_name:  # Different world name
		client_unspawn_old_world()
		
		client_cur_world_data = {}
		client_cur_world_data = data
		client_cur_world_name = world_name
		
		var world_scene = Worlds.get_world_scene(world_name).instantiate()
		get_tree().current_scene.add_child(world_scene, true)
		client_cur_world_node = world_scene
		print("[CLIENT]: spawned ", world_name)
		return
	# Else just do nothing. Just sync the data
	client_cur_world_data = data


@rpc
func sync_this_world_data_across_client(data: Dictionary):
	if multiplayer.is_server(): return
	if client_cur_world_name == "": return
	if !data.has(client_cur_world_name): return
	
	var all_peers_data: Dictionary = data[client_cur_world_name]
	for peer_data: Dictionary in all_peers_data.values():
		if peer_data["peer_id"] == multiplayer.get_unique_id():
			continue
		
		var _p_id = peer_data["peer_id"]
		client_cur_world_data[client_cur_world_name][_p_id] = peer_data
	
	world_entites_data_updated.emit()


@rpc
func client_sync_this_world_data(data: Dictionary):
	client_cur_world_data = data


func client_unspawn_old_world():
	if client_cur_world_node == null: return
	
	client_cur_world_node.call_deferred("queue_free")
	await client_cur_world_node.tree_exited
	
	client_cur_world_name = ""
	client_cur_world_data = {}
	client_cur_world_node = null
	
	return
	
