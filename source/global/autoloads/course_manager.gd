extends Node


signal course_data_ready

## Here what I think the data structure will be:
## CoursesName -> SessionsId -> AllThePeersInsideIt
var server_courses_sessions := {}

## Data for client curent course session
var client_course_name := ""
var client_course_id := -1
var client_course_all_peers := []

var client_return_world_name := ""
var client_return_world_pos := Vector2()

## This will only enter the course test stuff yk like idk its very hardcoded until I make it easy
## to create courses
func client_enter_course_test(_return_pos: Vector2):
	client_return_world_name = WorldManager.client_cur_world_name
	client_return_world_pos = _return_pos
	
	var old_world_name := WorldManager.client_cur_world_name
	WorldManager.client_unspawn_old_world()
	ClientManager.set_main_game_ui_visibility(false)
	
	_server_move_peer_to_course_test.rpc_id(1, old_world_name)
	await course_data_ready
	
	ClientManager.set_client_course_ui_visibility(true)
	client_set_up_course_ui()


func client_set_up_course_ui():
	var client_course_ui := ClientManager.client_main_ui.client_course_ui
	client_course_ui.return_button.pressed.connect(
		_client_exit_this_course,
		ConnectFlags.CONNECT_ONE_SHOT
	)


func _client_exit_this_course():
	_server_remove_peer_from_this_session.rpc_id(
		1,
		client_course_name,
		client_course_id
	)
	_client_return_to_old_world()

func _client_return_to_old_world():
	ClientManager.set_main_game_ui_visibility(true)
	ClientManager.set_client_course_ui_visibility(false)
	
	WorldManager.ask_server_for_world_change(
		client_return_world_name,
		client_return_world_pos
		)


@rpc("any_peer")
func _server_move_peer_to_course_test(old_world_name: String):
	if !multiplayer.is_server(): return
	
	var player_peer_id := multiplayer.get_remote_sender_id()
	EntityManager.remove_peer_from_world_entities_data(player_peer_id)
	var new_data := { old_world_name: EntityManager.worlds_entities_data[old_world_name]}
	WorldManager.sync_this_world_data_across_client.rpc(new_data)
	
	_server_create_course("course_test", player_peer_id)


func _server_create_course(course_name: String, peer_id_that_created_it: int):
	var course_id = 0
	if server_courses_sessions.has(course_name):
		course_id = server_courses_sessions[course_name].size()
	else: server_courses_sessions[course_name] = {}
	
	server_courses_sessions[course_name][course_id] = {"all_peer_id": [peer_id_that_created_it]}
	
	var all_peers: Array = server_courses_sessions[course_name][course_id]["all_peer_id"]
	_set_client_course_data.rpc_id(peer_id_that_created_it, course_name, course_id, all_peers)
	_call_client_course_data_ready_signal.rpc_id(peer_id_that_created_it)


@rpc
func _set_client_course_data(course_name: String, course_id: int, all_peers: Array):
	client_course_name = course_name
	client_course_id = course_id
	client_course_all_peers = all_peers


@rpc("any_peer")
func _server_remove_peer_from_this_session(_course_name: String, _course_id: int):
	if !multiplayer.is_server(): return
	
	var _peer_id := multiplayer.get_remote_sender_id()
	var _all_peer_id: Array = server_courses_sessions[_course_name][_course_id]["all_peer_id"]
	_all_peer_id.erase(_peer_id)
	
	# Erase the course id
	if _all_peer_id.is_empty():
		server_courses_sessions[_course_name].erase(_course_id)
	
	# Erase the course itself
	if server_courses_sessions[_course_name].is_empty():
		server_courses_sessions.erase(_course_name)


@rpc
func _call_client_course_data_ready_signal():
	course_data_ready.emit()
