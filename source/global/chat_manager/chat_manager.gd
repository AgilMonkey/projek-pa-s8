extends Node


signal on_new_msg

## Array with a dict like this {username, msg}
var all_chat_logs: Array[Dictionary]


func _ready() -> void:
	
	on_new_msg.connect(
		func():
			if multiplayer.is_server(): return
			print(all_chat_logs)
	)


@rpc("any_peer", "call_remote", "reliable", Global.NetworkChannel.CHAT)
func send_msg_to_server(username: String, msg: String):
	var new_msg := {
		"username": username,
		"msg": msg
	}
	all_chat_logs.append(new_msg)
	
	sync_chat_logs_to_all_client.rpc(all_chat_logs)


@rpc("authority", "call_remote", "reliable", Global.NetworkChannel.CHAT)
func sync_chat_logs_to_all_client(new_chat_logs: Array[Dictionary]):
	all_chat_logs = new_chat_logs
	on_new_msg.emit()
