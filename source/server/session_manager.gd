extends Node


## peer_id: { username, hash_id }
var server_sessions: Dictionary

var cur_client_session: String


func _ready() -> void:
	multiplayer.server_disconnected.connect(func(): cur_client_session = "")
	multiplayer.peer_disconnected.connect(delete_this_peer_session)


func server_create_session(peer_id: int, username: String):
	var _session_hash := (
		(
			username + str(len(server_sessions))
		).sha256_text()
		)
	
	var session_data ={
		"username" = username,
		"hash" = _session_hash
	}
	server_sessions[peer_id] = session_data
	
	update_all_client_sessions_data.rpc(server_sessions)
	
	return _session_hash


@rpc
func set_peer_client_session_hash(_hash: String):
	cur_client_session = _hash
	
	print("%d: %s" % [multiplayer.get_unique_id(), cur_client_session])


func delete_this_peer_session(_peer_id: int):
	if !multiplayer.is_server(): return
	
	server_sessions.erase(_peer_id)
	update_all_client_sessions_data.rpc(server_sessions)


@rpc
func update_all_client_sessions_data(_new_sessions_data):
	if multiplayer.is_server(): return
	
	server_sessions = _new_sessions_data


## { peer_id, username, hash_id }
func get_session_info_of_username(_username) -> Dictionary:
	var info := {}
	for key in SessionManager.server_sessions:
		if SessionManager.server_sessions[key]["username"] == _username:
			info = {
				"peer_id": key,
				"username": _username,
				"hash_id": SessionManager.server_sessions[key]["hash"]
			}
	return info
