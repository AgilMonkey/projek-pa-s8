class_name MainGameUIController
extends Node


@onready var client_chat_ui: ClientChatUI = $"../ClientChatUi"
@onready var main_game_window_spawner: KeepInMarginControl = $"../MainGameWindowSpawner"


func _ready() -> void:
	client_chat_ui.client_chat_send_msg.connect(
		func(msg: String):
			var username := UserManager.client_cur_username
			ChatManager.send_msg_to_server.rpc_id(1, username, msg)
	)
	
	client_chat_ui.client_is_chatting.connect(
		func (_is_chatting):
			ChatManager.client_is_chatting.emit(_is_chatting)
	)
	
	ChatManager.on_new_msg.connect(
		func():
			client_chat_ui.set_chat_bot_text(ChatManager.all_chat_logs)
	)
	
	ChatManager.refresh_this_peer_chat_logs.rpc_id(1)
	
	
	MainGameWindowManager.set_main_game_window_spawner(main_game_window_spawner)
