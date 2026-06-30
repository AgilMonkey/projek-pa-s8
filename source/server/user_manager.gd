extends Node


signal client_logged_in


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
	if _get_data.is_empty(): return
	
	if _get_data["password"] == _password.sha256_text():
		var session_hash = SessionManager.server_create_session(_username)
		SessionManager.set_peer_client_session_hash.rpc_id(_sender_id, session_hash)
		call_client_logged_in.rpc_id(_sender_id)
	else:
		print("Nope")


@rpc
func call_client_logged_in():
	client_logged_in.emit()


func _get_data_from_username(_username: String) -> Dictionary:
	var user_with_name := DatabaseManager.database.select_rows(
		"users", "username = '%s'" % _username, ["*"])
	
	if len(user_with_name) == 0: return {}
	
	return user_with_name[0]
