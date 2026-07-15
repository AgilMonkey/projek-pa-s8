extends Node


func _ready() -> void:
	if OS.has_feature("server"):
		_start_server()
	elif OS.has_feature("client"):
		_start_client()


func _start_server():
	Networking.create(NetworkingBase.Role.SERVER, "*", Config.server_port)
	
	print("Server started at port: ", Config.server_port)
	
	print(ASCII.orin_ascii)
	print("I love Rin Kaenbyou from Touhou <3")
	
	%MainControl.queue_free()


func _start_client():
	_client_connect_to_server()


func _client_connect_to_server():
	var _err = await Networking.create(
	NetworkingBase.Role.CLIENT, 
	Config.server_ip, 
	Config.server_port)
	
	if _err == Networking.ConnectError.OK:
		_when_connected_to_server()
	else:
		print("Error: %d" % _err)


func _when_connected_to_server():
	UserManager.login_user.rpc_id(1, "test1", "test1")
	await UserManager.client_logged_in
	
	var course := preload("uid://bftacsjn6ivgg")
	CourseManager.client_enter_course(Vector2.ZERO, course)
	await CourseManager.course_data_ready
	
	%QuickDebugLabel.setup()
