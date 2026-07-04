## This is an autoload that handle basic web socket connection
## Depend on NetworkingBase
extends NetworkingBase


func _ready() -> void:
	super._ready()
	
	if !OS.has_feature("server"): return
	
	multiplayer.peer_connected.connect(
		func(id: int):
			print("[Server]: Peer {%d} connected" % id)
	)
	
	multiplayer.peer_disconnected.connect(
		func(id: int):
			print("[Server]: Peer {%d} disconnected" % id)
	)


#func _input(_event: InputEvent) -> void:
	#if Input.is_anything_pressed():
		#if !multiplayer.is_server():
			#_hi.rpc()
#
#
#@rpc("any_peer", "call_local")
#func _hi():
	#print("{%d} :Hi" % multiplayer.get_unique_id())
