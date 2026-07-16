class_name ClientMain
extends Node

const SUBWINDOW_TEXT = preload("uid://bcqxa5hqmpes3")

@onready var login_ui: LoginUi = $LoginRegisterUi/LoginUi
@onready var register_ui: RegisterUI = $LoginRegisterUi/RegisterUi
@onready var subwindows_container: Control = %SubwindowsContainer


#func _input(event: InputEvent) -> void:
	#if not UserManager.client_is_logged_in: return
	#
	#var rand_pos = Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
	#if AgilHelper.key_just_pressed(event, KEY_1):
		#WorldManager.ask_server_for_world_change(Worlds.TEST_WORLD, rand_pos)
	#elif AgilHelper.key_just_pressed(event, KEY_2):
		#WorldManager.ask_server_for_world_change(Worlds.TEST_WORLD_2, rand_pos)
	#elif AgilHelper.key_just_pressed(event, KEY_3):
		#WorldManager.ask_server_for_world_change(Worlds.TEST_WORLD_3, rand_pos)


func _ready() -> void:
	ClientManager.client_main_ui = %ClientMainUI
	
	login_ui.on_login_button_pressed.connect(
		func(data):
			_client_login(
				data["username"],
				data["password"]
			)
	)
	
	login_ui.register_button.pressed.connect(
		func():
			register_ui.show()
			login_ui.hide()
	)
	
	register_ui.back_button.pressed.connect(
		func():
			register_ui.hide()
			login_ui.show()
	)
	
	register_ui.on_registering.connect(
		func(_data):
			UserManager.register_user.rpc_id(1, _data["username"], _data["password"])
			var win: SubwindowText = SUBWINDOW_TEXT.instantiate()
			subwindows_container.add_child(win)
			win.title_text = "Register Success"
			win.window_text = "Register Successful!\nPlease Login."
			win.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			
			register_ui.hide()
			login_ui.show()
	)
	
	UserManager.client_logged_in.connect(
		func(result, _data):
			print("[Client %d]: %s" % [multiplayer.get_unique_id(), UserManager.LogInResult.keys()[result]])
			if result != UserManager.LogInResult.OK: return
			
			$LoginRegisterUi.queue_free()
			
			# Enter world
			WorldManager.ask_server_for_world_change(Worlds.OVERWORLD)
			%ClientMainUI.show()
	)


func _client_login(_username: String, _password: String):
	UserManager.login_user.rpc_id(1, _username, _password)
