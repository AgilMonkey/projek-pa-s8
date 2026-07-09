extends Node


signal course_data_updated
signal course_data_ready

@onready var server_courses_sessions := ServerCourseSessionsData.new()

## Data for client curent course session
var client_course_name := ""
var client_course_id := -1
var client_course_all_peers_data: Array[ServerCourseSessionsData.CourseSessionData]

var client_jawaban_benar: Array[int]
var client_jawaban_salah: Array[int]
var client_total_question := -1
var client_cur_question_count := -1
var client_cur_question := ""
var client_cur_answer := ""

var client_return_world_name := ""
var client_return_world_pos := Vector2()

var is_pertanyaan_habis: bool :
	get:
		return (client_total_question - client_cur_question_count) - 1 == 0


func client_enter_course(_return_pos: Vector2, _course: CourseResource):
	client_jawaban_benar = []
	client_jawaban_salah = []
	client_total_question = -1
	client_cur_question_count = -1
	client_cur_question = ""
	client_cur_answer = ""
	
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
	await course_data_updated
	var client_course_ui := ClientManager.client_main_ui.client_course_ui
	client_course_ui.exit_button.pressed.connect(
		_client_exit_this_course,
		ConnectFlags.CONNECT_ONE_SHOT
	)
	
	client_course_ui.update_ui_pertanyaan_baru(
		client_cur_question_count,
		client_total_question,
		client_cur_question
	)


func client_cek_jawaban(_jawaban: String) -> bool:
	if _jawaban == client_cur_answer.to_lower():
		client_jawaban_benar.append(client_cur_question_count)
		return true
	client_jawaban_salah.append(client_cur_question_count)
	return false


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
	var _course_name := _course_file_path.get_file().get_basename()
	
	var _course_id = 0
	var _find_course := server_courses_sessions.find_course(_course_name)
	if _find_course != null:
		_course_id = _find_course.course_sessions.size()
		
		var _new_course_session := ServerCourseSessionsData.CourseSession.new()
		_new_course_session.session_id = _course_id
		
		var _new_course_session_data := ServerCourseSessionsData.CourseSessionData.new()
		_new_course_session_data.peer_id = _peer_id_that_created_it
		_new_course_session_data.course_cur_question_count = 0
		_new_course_session_data.course_total_question = _course_resource.questions_list.size()
		_new_course_session_data.course_question = (
			_course_resource
			.questions_list[_new_course_session_data.course_cur_question_count]
			.question
		)
		_new_course_session_data.course_answer = (
			_course_resource
			.questions_list[_new_course_session_data.course_cur_question_count]
			.answer
		)
		
		_new_course_session.course_data.append(_new_course_session_data)
		_find_course.course_sessions.append(_new_course_session)
	else:
		var _new_course := ServerCourseSessionsData.ServerCourse.new()
		_new_course.course_name = _course_name
		_new_course.course_resource = _course_resource
		
		var _new_course_session := ServerCourseSessionsData.CourseSession.new()
		_new_course_session.session_id = _course_id
		
		var _new_course_session_data := ServerCourseSessionsData.CourseSessionData.new()
		_new_course_session_data.peer_id = _peer_id_that_created_it
		_new_course_session_data.course_cur_question_count = 0
		_new_course_session_data.course_total_question = _course_resource.questions_list.size()
		_new_course_session_data.course_question = (
			_course_resource
			.questions_list[_new_course_session_data.course_cur_question_count]
			.question
		)
		_new_course_session_data.course_answer = (
			_course_resource
			.questions_list[_new_course_session_data.course_cur_question_count]
			.answer
		)
		
		_new_course_session.course_data.append(_new_course_session_data)
		_new_course.course_sessions.append(_new_course_session)
		server_courses_sessions.server_courses.append(_new_course)
	
	_set_client_course_main_data.rpc_id(
		_peer_id_that_created_it,
		_course_name,
		_course_id,
		server_courses_sessions.find_course_session(_course_name, _course_id).to_dict()
	)
	
	_call_client_course_data_ready_signal.rpc_id(_peer_id_that_created_it)
	
	var _peer_data := (
		server_courses_sessions.find_course_session(_course_name, _course_id)
		.find_course_session_data(
			_peer_id_that_created_it
			)
	)
	_client_update_course_data.rpc_id(_peer_id_that_created_it, _peer_data.to_dict())


@rpc
func _set_client_course_main_data(course_name: String, course_id: int, all_peers_data: Dictionary):
	client_course_name = course_name
	client_course_id = course_id
	
	var new_peer_data := ServerCourseSessionsData.CourseSession.from_dict(all_peers_data)
	client_course_all_peers_data = new_peer_data.course_data


@rpc("any_peer")
func _server_remove_peer_from_this_session(_course_name: String, _course_id: int):
	if !multiplayer.is_server(): return
	
	var _peer_id := multiplayer.get_remote_sender_id()
	var _find_server_course_session := server_courses_sessions.find_course_session(
		_course_name,
		_course_id
	)
	
	_find_server_course_session.remove_course_session_data(_peer_id)
	
	# Erase course session id if nobody there
	var _find_server_course := server_courses_sessions.find_course(_course_name)
	if _find_server_course_session.course_data.is_empty():
		_find_server_course.course_sessions.erase(_find_server_course_session)
	
	# Erase course itself if there's no sessions
	if _find_server_course.course_sessions.is_empty():
		server_courses_sessions.server_courses.erase(_find_server_course)


@rpc("any_peer")
func _ask_server_for_next_question(_course_name: String, _course_id: int):
	if !multiplayer.is_server(): return
	
	var _peer_id := multiplayer.get_remote_sender_id()
	var _cur_resource := server_courses_sessions.find_course(_course_name).course_resource
	var _peer_data := (
		server_courses_sessions.find_course_session(_course_name, _course_id)
		.find_course_session_data(
			_peer_id
			)
	)
	
	_peer_data.course_total_question = _cur_resource.questions_list.size()
	_peer_data.course_cur_question_count += 1
	_peer_data.course_question = _cur_resource.questions_list[_peer_data.course_cur_question_count].question
	_peer_data.course_answer = _cur_resource.questions_list[_peer_data.course_cur_question_count].answer
	
	_client_update_course_data.rpc_id(_peer_id, _peer_data.to_dict())


@rpc
func _call_client_course_data_ready_signal():
	course_data_ready.emit()


@rpc
func _client_update_course_data(_data: Dictionary):
	var _peer_data := ServerCourseSessionsData.CourseSessionData.from_dict(_data)
	client_total_question = _peer_data.course_total_question
	client_cur_question_count = _peer_data.course_cur_question_count
	client_cur_question = _peer_data.course_question
	client_cur_answer = _peer_data.course_answer
	
	course_data_updated.emit()
