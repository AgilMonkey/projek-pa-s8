class_name NetworkingBase
extends Node


signal connection_result(success: bool)

enum Role {
	CLIENT,
	SERVER
}

var peer: WebSocketMultiplayerPeer
var _timeout_timer: Timer


func _ready() -> void:
	multiplayer.connected_to_server.connect(func(): connection_result.emit(true))
	multiplayer.connection_failed.connect(func(): connection_result.emit(false))
	
	_timeout_timer = AgilHelper.create_timer_on_current_node(
		self,
		false,
		false,
		false
	)

## Create as client or server.
## TLS usefull for wss (WebSocket Secure) unless you have anything else taking care of it like Caddy.
func create(role: Role, address: String, port: int, tls_options: TLSOptions = null) -> Error:
	# Create the kind of peer we want.
	peer = WebSocketMultiplayerPeer.new()
	
	var error: Error
	
	match role:
		Role.CLIENT:
			# `address` may be either:
			#   (a) a bare host like "127.0.0.1" — build a URL from scheme + port
			#   (b) a full URL like "wss://ws.example.com/world/1" — use as-is
			# (b) is what production deploys behind a reverse proxy (Caddy/nginx)
			# send, because the path discriminates which world and the port is
			# part of the proxy's public binding.
			var url: String
			if address.contains("://"):
				url = address
			else:
				var scheme: String = "ws" if tls_options == null or tls_options.is_unsafe_client() else "wss"
				url = "%s://%s:%d" % [scheme, address, port]
			error = peer.create_client(url, tls_options)
		Role.SERVER:
			var bind_address: String = "*" if address.is_empty() else address
			error = peer.create_server(port, bind_address, tls_options)
		_:
			return Error.FAILED

	if error != OK:
		printerr("Error while creating peer: %s" % error_string(error))
		return error

	multiplayer.multiplayer_peer = peer
	
	if role == Role.CLIENT: 
		var conn_success: bool = await connection_result
		if !conn_success:
			error = Error.ERR_CANT_CONNECT
			return error

	return Error.OK


func _connect_with_timeout(address: String, port: int, timeout_sec := 5.0):
	pass
