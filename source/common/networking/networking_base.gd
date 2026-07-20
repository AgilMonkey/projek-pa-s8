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
var _should_retry := false


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
			error = await _connect_with_retries(address, port)
		Role.SERVER:
			var bind_address: String = "*" if address.is_empty() else address
			var _err
			if OS.has_feature("production"):
				_err = peer.create_server(port, "127.0.0.1")
			else:
				_err = peer.create_server(port, bind_address, tls_options)
			if _err != OK: error = ConnectError.SETUP_FAILED
			else: error = ConnectError.OK
			multiplayer.multiplayer_peer = peer
		_:
			error = ConnectError.SETUP_FAILED
	return error


func _connect_with_retries(address: String, port: int, max_attempts := 5):
	_should_retry = true
	var attempt := 0
	
	while _should_retry and (max_attempts <= 0 or attempt < max_attempts):
		attempt += 1
		print("Connection attempt %d..." % attempt)
		
		var result := await _connect_with_timeout(address, port, 5.0)
		if result == ConnectError.OK:
			return result
		
		if not _should_retry:
			# user cancelled mid-attempt
			return ConnectError.CANCELLED
		
		# exponential backoff, capped
		var wait: float = min(1.0 * pow(2, attempt - 1), 30.0)
		print("Retrying in %.1fs" % wait)
		await get_tree().create_timer(wait).timeout
	
	return ConnectError.TIMEOUT


func _connect_with_timeout(address: String, port: int, timeout_sec := 5.0, tls_options: TLSOptions = null) -> ConnectError:
	## `address` may be either:
	##   (a) a bare host like "127.0.0.1" — build a URL from scheme + port
	##   (b) a full URL like "wss://ws.example.com/world/1" — use as-is
	## (b) is what production deploys behind a reverse proxy (Caddy/nginx)
	## send, because the path discriminates which world and the port is
	## part of the proxy's public binding.
	
	var error: Error
	var url: String
	
	if address.contains("://"):
		url = address
	else:
		var scheme: String = "ws" if tls_options == null or tls_options.is_unsafe_client() else "wss"
		url = "%s://%s:%d" % [scheme, address, port]
	
	if OS.has_feature("production") and OS.has_feature("client"):  ## Very bad and quick shit
		error = peer.create_client("wss://poliban-english-verse.duckdns.org/ws")
	else:
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
