class_name ClientMain
extends Node

const SUBWINDOW_TEXT = preload("uid://bcqxa5hqmpes3")

@onready var login_ui: LoginUi = $LoginRegisterUi/LoginUi
@onready var register_ui: RegisterUI = $LoginRegisterUi/RegisterUi
@onready var subwindows_container: Control = %SubwindowsContainer


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
			
			var register_result: UserManager.RegisterResult = await UserManager.on_registering
			
			if register_result != UserManager.RegisterResult.OK:
				match register_result:
					UserManager.RegisterResult.FAILED_USER_ALREADY_EXIST:
						SystemSubwindow.spawn_subwindow_notice(
							"Failed registering: User already exist"
						)
				return
			
			## Register is OK
			var win: SubwindowText = SUBWINDOW_TEXT.instantiate()
			subwindows_container.add_child(win)
			win.title_text = "Register Success"
			win.window_text = "Register Successful!\nPlease Login."
			win.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			
			register_ui.hide()
			login_ui.show()
	)
	
	UserManager.client_logged_in.connect(
		func(result: UserManager.LogInResult, _data):
			print("[Client %d]: %s" % [multiplayer.get_unique_id(), UserManager.LogInResult.keys()[result]])
			if result != UserManager.LogInResult.OK:
				_client_log_in_other_result(result)
				return
			
			$LoginRegisterUi.hide()
			
			# Enter world
			WorldManager.ask_server_for_world_change(Worlds.OVERWORLD)
			%ClientMainUI.show()
	)
	
	multiplayer.server_disconnected.connect(_server_disconnected)


func _client_login(_username: String, _password: String):
	UserManager.login_user.rpc_id(1, _username, _password)


func _client_log_in_other_result(result: UserManager.LogInResult):
	match result:
		UserManager.LogInResult.FAILED_NO_USER_FOUND:
			SystemSubwindow.spawn_subwindow_notice("Tidak ada username itu")
		UserManager.LogInResult.FAILED_WRONG_PASSWORD:
			SystemSubwindow.spawn_subwindow_notice("Password salah")
		UserManager.LogInResult.FAILED_UNDEFINED:
			SystemSubwindow.spawn_subwindow_notice("Kalau kau lihat ini. Jungkir balik")


func _server_disconnected():
	pass
