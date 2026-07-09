extends Node


## This will only enter the course test stuff yk like idk its very hardcoded until I make it easy
## to create courses
func client_enter_course_test():
	var old_world_name := WorldManager.client_cur_world_name
	WorldManager.client_unspawn_old_world()
	ClientManager.set_main_game_ui_visibility(false)
	
	server_move_peer_to_course_test.rpc_id(1, old_world_name)


@rpc("any_peer")
func server_move_peer_to_course_test(old_world_name: String):
	if !multiplayer.is_server(): return
	
	var player_peer_id := multiplayer.get_remote_sender_id()
	EntityManager.remove_peer_from_world_entities_data(player_peer_id)
	var new_data := { old_world_name: EntityManager.worlds_entities_data[old_world_name]}
	WorldManager.sync_this_world_data_across_client(new_data)
