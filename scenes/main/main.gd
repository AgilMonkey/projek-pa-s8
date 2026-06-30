extends Node


const START_MENU_UI = preload("uid://c7o0k4lx31wtl")
const CLIENT_MAIN = preload("uid://x0ori5xud1bs")

var client_main: ClientMain


func _ready() -> void:
	if OS.has_feature("server"):
		_start_server()
	elif OS.has_feature("client"):
		_start_client()
	else:
		printerr("Current run don't have client or a server tag!")
	
	if OS.has_feature("production"):
		print("Production build")
	elif OS.has_feature("test"):
		print("Test build")
	else:
		print("No build tag; Using test build")


func _start_server():
	Networking.create(NetworkingBase.Role.SERVER, "*", Config.server_port)
	
	print("Server started at port: ", Config.server_port)


func _start_client():
	var start_menu_ui: StartMenuUI = START_MENU_UI.instantiate()
	start_menu_ui.start_button_pressed.connect(
		func():
			start_menu_ui.connecting_panel.show()
			
			var _err = await Networking.create(
				NetworkingBase.Role.CLIENT, 
				Config.server_ip, 
				Config.server_port)
			
			if _err == OK:
				start_menu_ui.queue_free()
				_client_connected_to_server()
			else:
				print("Error: %d" % _err)
	)
	add_child(start_menu_ui)


func _client_connected_to_server():
	client_main = CLIENT_MAIN.instantiate()
	add_child(client_main)
