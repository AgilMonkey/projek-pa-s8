class_name NetworkingBase
extends Node


signal connection_result(error: ConnectError)

enum Role {
	CLIENT,
	SERVER
}

enum ConnectError {
	OK,
	SETUP_FAILED,   # create_client() didn't return OK — local problem
	TIMEOUT,        # our timer won the race
	REFUSED,        # connection_failed fired
	CANCELLED,
}

var peer: WebSocketMultiplayerPeer
var _is_connecting := false

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)

## Create as client or server.
## TLS usefull for wss (WebSocket Secure) unless you have anything else taking care of it like Caddy.
func create(role: Role, address: String, port: int, tls_options: TLSOptions = null) -> ConnectError:
	# Create the kind of peer we want.
	peer = WebSocketMultiplayerPeer.new()
	
	var error: ConnectError
	
	match role:
		Role.CLIENT:
			## `address` may be either:
			##   (a) a bare host like "127.0.0.1" — build a URL from scheme + port
			##   (b) a full URL like "wss://ws.example.com/world/1" — use as-is
			## (b) is what production deploys behind a reverse proxy (Caddy/nginx)
			## send, because the path discriminates which world and the port is
			## part of the proxy's public binding.
			#var url: String
			#if address.contains("://"):
				#url = address
			#else:
				#var scheme: String = "ws" if tls_options == null or tls_options.is_unsafe_client() else "wss"
				#url = "%s://%s:%d" % [scheme, address, port]
			#error = peer.create_client(url, tls_options)
			error = await _connect_with_timeout(address, port)
		Role.SERVER:
			var bind_address: String = "*" if address.is_empty() else address
			var _err = peer.create_server(port, bind_address, tls_options)
			if _err != OK: error = ConnectError.SETUP_FAILED
			else: error = ConnectError.OK
			multiplayer.multiplayer_peer = peer
		_:
			error = ConnectError.SETUP_FAILED
	return error
	#if error != OK:
		#printerr("Error while creating peer: %s" % error_string(error))
		#return ConnectError
#
	#multiplayer.multiplayer_peer = peer
	#
	#if role == Role.CLIENT: 
		#var conn_success: bool = await connection_result
		#if !conn_success:
			#error = Error.ERR_CANT_CONNECT
			#return error
#
	#return Error.OK


func _connect_with_timeout(address: String, port: int, timeout_sec := 5.0, tls_options: TLSOptions = null) -> ConnectError:
	var error: Error
	var url: String
	
	if address.contains("://"):
		url = address
	else:
		var scheme: String = "ws" if tls_options == null or tls_options.is_unsafe_client() else "wss"
		url = "%s://%s:%d" % [scheme, address, port]
	
	error = peer.create_client(url, tls_options)
	
	if error != OK:
		printerr("Error while creating peer: %s" % error_string(error))
		return ConnectError.SETUP_FAILED

	multiplayer.multiplayer_peer = peer
	_is_connecting = true
	
	var timer = get_tree().create_timer(timeout_sec)
	timer.timeout.connect(_on_conn_timeout)
	
	var result: ConnectError = await connection_result
	_is_connecting = false
	return result


func _on_connected():
	if _is_connecting:
		connection_result.emit(ConnectError.OK)


func _on_failed():
	if _is_connecting:
		connection_result.emit(ConnectError.REFUSED)


func _on_conn_timeout():
	if _is_connecting:
		_cleanup()
		connection_result.emit(ConnectError.TIMEOUT)


func _cleanup():
	multiplayer.multiplayer_peer = null   # tear down the half-open connection
