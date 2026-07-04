extends Node


signal client_logged_in(result: LogInResult, other_data: Dictionary)

enum LogInResult {OK, FAILED_NO_USER_FOUND, FAILED_WRONG_PASSWORD, FAILED_ALREADY_LOGGED_IN,FAILED_UNDEFINED}

var client_cur_username := ""
var client_is_logged_in := false


@rpc("any_peer")
func register_user(username: String, password: String):
	if !multiplayer.is_server(): return
	
	var insert_user_data = {
		"username" : username,
		"password" : password.sha256_text(),
	}
	
	DatabaseManager.database.insert_row("users", insert_user_data)


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
	
	var session_hash = SessionManager.server_create_session(_sender_id, _username)
	SessionManager.set_peer_client_session_hash.rpc_id(_sender_id, session_hash)
	call_client_logged_in.rpc_id(_sender_id, LogInResult.OK)
	client_set_user_data.rpc_id(_sender_id, _get_data["username"])


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
func client_set_user_data(username):
	client_cur_username = username


func _get_data_from_username(_username: String) -> Dictionary:
	var user_with_name := DatabaseManager.database.select_rows(
		"users", "username = '%s'" % _username, ["*"])
	
	if len(user_with_name) == 0: return {}
	
	return user_with_name[0]
