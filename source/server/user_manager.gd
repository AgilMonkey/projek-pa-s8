extends Node


signal on_dapat_data_kelas(data: Dictionary)

signal client_logged_in(result: LogInResult, other_data: Dictionary)
signal on_registering(resutl: RegisterResult)

enum LogInResult {OK, FAILED_NO_USER_FOUND, FAILED_WRONG_PASSWORD, FAILED_ALREADY_LOGGED_IN,FAILED_UNDEFINED}
enum RegisterResult {OK, FAILED_USER_ALREADY_EXIST}

var client_cur_username := ""
var client_is_logged_in := false


@rpc("any_peer")
func register_user(username: String, password: String):
	if !multiplayer.is_server(): return
	
	var insert_user_data = {
		"username": username,
		"password": password.sha256_text(),
		"data_kelas": JSON.stringify(PenyimpananKelasManager.to_save_dict())
	}
	
	var peer_caller_id = multiplayer.get_remote_sender_id()
	if !_get_data_from_username(username).is_empty():
		_call_client_registering.rpc_id(peer_caller_id, RegisterResult.FAILED_USER_ALREADY_EXIST)
		return
	
	DatabaseManager.database.insert_row("users", insert_user_data)
	_call_client_registering.rpc_id(peer_caller_id, RegisterResult.OK)


@rpc("any_peer")
func login_user(_username: String, _password: String):
	if !multiplayer.is_server(): return
	var _sender_id := multiplayer.get_remote_sender_id()
	
	var _get_data: Dictionary = _get_data_from_username(_username)
	if _get_data.is_empty():
		call_client_logged_in.rpc_id(_sender_id, LogInResult.FAILED_NO_USER_FOUND, {"username": _username})
		return
	
	if _get_data["password"] != _password.sha256_text():
		call_client_logged_in.rpc_id(_sender_id, LogInResult.FAILED_WRONG_PASSWORD)
		return
	
	if _check_if_there_is_a_session_with_username(_username):
		var peer_id_to_dc: int = SessionManager.get_session_info_of_username(_username)["peer_id"]
		_server_a_client_already_logged_in(peer_id_to_dc)
	
	var session_hash = SessionManager.server_create_session(_sender_id, _username)
	SessionManager.set_peer_client_session_hash.rpc_id(_sender_id, session_hash)
	client_set_user_data.rpc_id(_sender_id, _get_data["username"])
	call_client_logged_in.rpc_id(_sender_id, LogInResult.OK)


func server_logout_user(_username: String):
	var all_sessions = SessionManager.server_sessions
	for ses in all_sessions:
		if all_sessions[ses]["username"] == _username:
			all_sessions.erase(ses)
			return
	
	assert("Couldn't find username:%s to erase in sessions list!" % _username)


@rpc
func call_client_logged_in(result: LogInResult, other_data: Dictionary = {}):
	client_is_logged_in = result == LogInResult.OK
	client_logged_in.emit(result, other_data)


@rpc
func _call_client_registering(result):
	on_registering.emit(result)


@rpc
func client_set_user_data(username):
	client_cur_username = username


@rpc("any_peer")
func minta_data_kelas_ke_server(username: String):
	if !multiplayer.is_server(): return
	var data := _get_data_from_username(username)
	var data_kelas: Dictionary = JSON.parse_string(data["data_kelas"])
	dapat_data_kelas.rpc_id(multiplayer.get_remote_sender_id(), data_kelas)


@rpc
func dapat_data_kelas(data: Dictionary):
	on_dapat_data_kelas.emit(data)


@rpc("any_peer")
func save_data_kelas_to_database(username: String, data_kelas: Dictionary):
	if !multiplayer.is_server(): return
	
	DatabaseManager.database.query_with_bindings(
		"UPDATE users SET data_kelas = ? WHERE username = ?",
		[JSON.stringify(data_kelas), username]
	)
	
	print(data_kelas)


func _get_data_from_username(_username: String) -> Dictionary:
	var user_with_name := DatabaseManager.database.select_rows(
		"users", "username = '%s'" % _username, ["*"])
	
	if len(user_with_name) == 0: return {}
	
	return user_with_name[0]


func _check_if_there_is_a_session_with_username(_username: String) -> bool:
	for key in SessionManager.server_sessions:
		if SessionManager.server_sessions[key]["username"] == _username: return true
	return false


func _server_a_client_already_logged_in(_peer_id_old: int):
	_log_off_and_disconnect_this_client.rpc_id(_peer_id_old)


@rpc
func _log_off_and_disconnect_this_client():
	multiplayer.multiplayer_peer.close()
	WorldManager.client_clear_and_remove_all_world_stuff()
	SystemSubwindow.spawn_subwindow_notice("Disconnected. Ada klien lain yang login")
