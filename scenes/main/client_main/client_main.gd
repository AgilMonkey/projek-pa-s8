extends Node


var peer: WebSocketMultiplayerPeer


func _ready() -> void:
	#var network_base := NetworkingBase.new()
	#network_base.create(NetworkingBase.Role.CLIENT, "127.0.0.1", 42069) 
	multiplayer.connected_to_server.connect(func():
		print("CLIENT %d: Connected to server!" % multiplayer.get_unique_id())
		)
	
	await get_tree().create_timer(0.5).timeout
	
	peer = WebSocketMultiplayerPeer.new()
	
	var error: Error
	var url = "%s://%s:%d" % ["ws", "127.0.0.1", 42069]
	error = peer.create_client(url)

	if error != OK:
		printerr("Error while creating peer: %s" % error_string(error))

	multiplayer.multiplayer_peer = peer
