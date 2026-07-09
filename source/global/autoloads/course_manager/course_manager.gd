extends Node


signal course_data_ready

## Data structure: server_courses_sessions :{
##		course_name: {
##			course_resource: CourseResource
##			sessions: {
##				0: {
##					course_data: dict that haves all the data to send back
##					all_peer_id: [int]
##				}
##			}
##		}
## }
var server_courses_sessions := {}

## Data for client curent course session
var client_course_name := ""
var client_course_id := -1
var client_course_all_peers := []

var client_total_question := -1
var client_cur_question_count := -1
var client_cur_question := ""
var client_cur_answer := ""

var client_return_world_name := ""
var client_return_world_pos := Vector2()


func client_enter_course(_return_pos: Vector2, _course: CourseResource):
	client_return_world_name = WorldManager.client_cur_world_name
	client_return_world_pos = _return_pos
	
	var old_world_name := WorldManager.client_cur_world_name
	WorldManager.client_unspawn_old_world()
	ClientManager.set_main_game_ui_visibility(false)
	
	_server_move_peer_to_course.rpc_id(1, old_world_name, _course.resource_path)
	await course_data_ready
	
	ClientManager.set_client_course_ui_visibility(true)
	client_set_up_course_ui()


func client_set_up_course_ui():
	var client_course_ui := ClientManager.client_main_ui.client_course_ui
	client_course_ui.exit_button.pressed.connect(
		_client_exit_this_course,
		ConnectFlags.CONNECT_ONE_SHOT
	)


func _client_exit_this_course():
	client_total_question = -1
	client_cur_question_count = -1
	client_cur_question = ""
	client_cur_answer = ""
	
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
func _server_move_peer_to_course(old_world_name: String, _course_file_path: String):
	if !multiplayer.is_server(): return
	
	var player_peer_id := multiplayer.get_remote_sender_id()
	EntityManager.remove_peer_from_world_entities_data(player_peer_id)
	var new_data := { old_world_name: EntityManager.worlds_entities_data[old_world_name]}
	WorldManager.sync_this_world_data_across_client.rpc(new_data)
	
	_server_create_course(_course_file_path, player_peer_id)


func _server_create_course(_course_file_path: String, _peer_id_that_created_it: int):
	var _course_resource: CourseResource = load(_course_file_path)
	var _course_name := _course_resource.resource_name
	
	var _course_id = 0
	if server_courses_sessions.has(_course_name):
		_course_id = server_courses_sessions[_course_name].size()
		
		server_courses_sessions[_course_name]["sessions"][_course_id] = {
			"all_peer_id": [_peer_id_that_created_it]
		}
	else:
		server_courses_sessions[_course_name] = {
			"course_resource": _course_resource,
			"sessions": {}
		}
		server_courses_sessions[_course_name]["sessions"][_course_id] = {
			"all_peer_id": [_peer_id_that_created_it]
		}
	
	_set_client_course_main_data.rpc_id(
		_peer_id_that_created_it,
		_course_name,
		_course_id,
		server_courses_sessions[_course_name]["sessions"][_course_id]["all_peer_id"]
	)
	
	_call_client_course_data_ready_signal.rpc_id(_peer_id_that_created_it)


@rpc
func _set_client_course_main_data(course_name: String, course_id: int, all_peers: Array):
	client_course_name = course_name
	client_course_id = course_id
	client_course_all_peers = all_peers


@rpc("any_peer")
func _server_remove_peer_from_this_session(_course_name: String, _course_id: int):
	if !multiplayer.is_server(): return
	
	var _peer_id := multiplayer.get_remote_sender_id()
	var _all_peer_id: Array = server_courses_sessions[_course_name]["sessions"][_course_id]["all_peer_id"]
	_all_peer_id.erase(_peer_id)
	
	# Erase the course id
	if _all_peer_id.is_empty():
		server_courses_sessions[_course_name]["sessions"].erase(_course_id)
	
	# Erase the course itself
	if server_courses_sessions[_course_name]["sessions"].is_empty():
		server_courses_sessions.erase(_course_name)


func _server_update_course_data_for_peer(_course_name: String, _course_id: int, _peer_id: int):
	var _data: Dictionary = server_courses_sessions[_course_name]["sessions"][_course_id]["course_data"]
	var _course_resource: CourseResource = server_courses_sessions[_course_name]["course_resource"]


@rpc
func _call_client_course_data_ready_signal():
	course_data_ready.emit()
