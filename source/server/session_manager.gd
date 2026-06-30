extends Node


var server_sessions: Array[String]

var cur_client_session: String


func server_create_session(username: String):
	var _session_identity := (
		(
			username + str(len(server_sessions))
		).sha256_text()
		)
	
	server_sessions.append(_session_identity)
	
	return _session_identity


@rpc("authority")
func set_peer_client_session_hash(_hash: String):
	cur_client_session = _hash
	
	print("%d: %s" % [multiplayer.get_unique_id(), cur_client_session])
