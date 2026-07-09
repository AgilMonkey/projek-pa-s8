extends Node


## Here what I think the data structure will be:
## CoursesName -> SessionsId -> AllThePeersInsideIt
var server_courses_sessions := {}

## Data for client curent course session
var client_course_name := ""
var client_course_id := -1
var client_course_all_peers := []


## This will only enter the course test stuff yk like idk its very hardcoded until I make it easy
## to create courses
func client_enter_course_test():
	var old_world_name := WorldManager.client_cur_world_name
	WorldManager.client_unspawn_old_world()
	ClientManager.set_main_game_ui_visibility(false)
	ClientManager.set_client_course_ui_visibility(true)
	
	_server_move_peer_to_course_test.rpc_id(1, old_world_name)


@rpc("any_peer")
func _server_move_peer_to_course_test(old_world_name: String):
	if !multiplayer.is_server(): return
	
	var player_peer_id := multiplayer.get_remote_sender_id()
	EntityManager.remove_peer_from_world_entities_data(player_peer_id)
	var new_data := { old_world_name: EntityManager.worlds_entities_data[old_world_name]}
	WorldManager.sync_this_world_data_across_client(new_data)
	
	_server_create_course("course_test", player_peer_id)


func _server_create_course(course_name: String, peer_id_that_created_it: int):
	var course_id = 0
	if server_courses_sessions.has(course_name):
		course_id = server_courses_sessions[course_name].size()
	else: server_courses_sessions[course_name] = {}
	
	server_courses_sessions[course_name][course_id] = {"all_peer_id": [peer_id_that_created_it]}
	
	var all_peers: Array = server_courses_sessions[course_name][course_id]["all_peer_id"]
	_set_client_course_data.rpc_id(peer_id_that_created_it, course_name, course_id, all_peers)


@rpc
func _set_client_course_data(course_name: String, course_id: int, all_peers: Array):
	client_course_name = course_name
	client_course_id = course_id
	client_course_all_peers = all_peers
