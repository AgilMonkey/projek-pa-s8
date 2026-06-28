extends Node


var peer: WebSocketMultiplayerPeer


func _ready() -> void:
	#var network_base := NetworkingBase.new()
	#network_base.create(NetworkingBase.Role.SERVER, "127.0.0.1", 42069)
	
	peer = WebSocketMultiplayerPeer.new()
	
	var error: Error
	error = peer.create_server(42069)

	if error != OK:
		printerr("Error while creating peer: %s" % error_string(error))

	multiplayer.multiplayer_peer = peer
	
	print("SERVER: Server created!")
	
	multiplayer.peer_connected.connect(
		func(id):
			print("%d connected" % id)
	)
