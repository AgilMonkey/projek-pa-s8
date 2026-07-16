extends Node


signal on_new_msg_by_who(peer_who: int, msg: String)
signal on_new_msg
signal client_is_chatting(is_chatting: bool)

## Array with a dict like this {username, msg}
var all_chat_logs: Array[Dictionary]


@rpc("any_peer", "call_remote", "reliable", Global.NetworkChannel.CHAT)
func send_msg_to_server(username: String, msg: String):
	var new_msg := {
		"username": username,
		"msg": msg
	}
	all_chat_logs.append(new_msg)
	
	sync_chat_logs_to_all_client.rpc(all_chat_logs)
	
	var _peer_sender = multiplayer.get_remote_sender_id()
	emit_to_client_on_new_msg_by_who.rpc(_peer_sender, msg)


@rpc("authority", "call_remote", "reliable", Global.NetworkChannel.CHAT)
func sync_chat_logs_to_all_client(new_chat_logs: Array[Dictionary]):
	all_chat_logs = new_chat_logs
	on_new_msg.emit()


@rpc("any_peer")
func refresh_this_peer_chat_logs():
	if !multiplayer.is_server(): return
	
	var peer_id = multiplayer.get_remote_sender_id()
	sync_chat_logs_to_all_client.rpc_id(peer_id, all_chat_logs)


@rpc
func emit_to_client_on_new_msg_by_who(_peer_who: int, _msg: String):
	on_new_msg_by_who.emit(_peer_who, _msg)
