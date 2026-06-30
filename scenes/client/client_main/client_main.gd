class_name ClientMain
extends Node

const SUBWINDOW_TEXT = preload("uid://0awrc1elwyes")

@onready var login_ui: LoginUi = $LoginRegisterUi/LoginUi
@onready var register_ui: RegisterUI = $LoginRegisterUi/RegisterUi
@onready var subwindows_container: Control = %SubwindowsContainer


func _ready() -> void:
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
			win.window_title.text = "Register Success"
			win.main_text.text = "Register Successful!\nPlease Login."
			win.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			
			register_ui.hide()
			login_ui.show()
	)
	
	UserManager.client_logged_in.connect(
		func():
			$LoginRegisterUi.queue_free()
			$QuickLogInCheck.show()
	)


func _client_login(_username: String, _password: String):
	UserManager.login_user.rpc_id(1, _username, _password)
