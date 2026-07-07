class_name MainGameUIController
extends Node


@onready var client_chat_ui: ClientChatUI = $"../ClientChatUi"


func _ready() -> void:
	client_chat_ui.client_chat_send_msg.connect(
		func(msg: String):
			var username := UserManager.client_cur_username
			ChatManager.send_msg_to_server.rpc_id(1, username, msg)
	)
	
	ChatManager.on_new_msg.connect(
		func():
			client_chat_ui.set_chat_bot_text(ChatManager.all_chat_logs)
	)
