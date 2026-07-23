extends Node


signal got_leaderboard_data(data)
signal on_get_point_server(_point: int)
signal point_updated(_cur_point: int)

var cur_point := 0


func _ready() -> void:
	UserManager.client_logged_in.connect(_logged_in)
	point_updated.connect(_point_updated)


func add_point(value_add: int):
	cur_point += value_add
	point_updated.emit(cur_point)
	_update_total_point.rpc_id(1, UserManager.client_cur_username, value_add)


func decrease_point(value_decrease: int):
	cur_point -= value_decrease
	point_updated.emit(cur_point)


func _logged_in(_result: UserManager.LogInResult, _other_data: Dictionary):
	if _result == UserManager.LogInResult.OK:
		_get_point_server_db.rpc_id(1, UserManager.client_cur_username)
		cur_point = await on_get_point_server
		point_updated.emit(cur_point)


func _point_updated(_cur_point):
	_update_point_server.rpc_id(1, UserManager.client_cur_username, cur_point)


@rpc("any_peer")
func _get_point_server_db(username: String):
	var data := _get_data_from_username(username)
	var point: int = data["point"]
	_emit_get_point_server.rpc_id(multiplayer.get_remote_sender_id(), point)


@rpc
func _emit_get_point_server(point):
	on_get_point_server.emit(point)


func _get_data_from_username(_username: String) -> Dictionary:
	var user_with_name := DatabaseManager.database.select_rows(
		"users", "username = '%s'" % _username, ["*"])
	
	if len(user_with_name) == 0: return {}
	
	return user_with_name[0]


@rpc("any_peer")
func _update_point_server(username: String, point: int):
	if !multiplayer.is_server(): return
	
	DatabaseManager.database.query_with_bindings(
		"UPDATE users SET point = ? WHERE username = ?",
		[point, username]
	)


@rpc("any_peer")
func _update_total_point(username: String, _point_added: int):
	var data := _get_data_from_username(username)
	var total_point = data["total_point"] + _point_added
	
	DatabaseManager.database.query_with_bindings(
		"UPDATE users SET total_point = ? WHERE username = ?",
		[total_point, username]
	)




@rpc("any_peer")
func get_leaderboard_data():
	var leaderboard_data := DatabaseManager.database.select_rows(
		"users",
		"total_point IS NOT NULL ORDER BY total_point DESC",
		["username", "total_point"]
	)
	
	_emit_leaderboard_data.rpc_id(multiplayer.get_remote_sender_id(), leaderboard_data)


@rpc
func _emit_leaderboard_data(data):
	got_leaderboard_data.emit(data)
