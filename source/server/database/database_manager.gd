extends Node

var database: SQLite


func _ready() -> void:
	if !OS.has_feature("server"): return
	
	_create_database()
	_create_users_table()
	
	if !OS.has_feature("production"):
		# Create test users
		UserManager.register_user("test1", "test1")
		UserManager.register_user("test2", "test2")
		UserManager.register_user("test3", "test3")


func _create_database():
	database = SQLite.new()
	
	if OS.has_feature("production"):
		if not DirAccess.dir_exists_absolute("user://database"):
			DirAccess.make_dir_absolute("user://database")
		
		database.path = "user://database/game_db.db"
		database.open_db()
	else:
		# Test enviroment
		if not DirAccess.dir_exists_absolute("user://database"):
			DirAccess.make_dir_absolute("user://database")
		
		# Delete DB and reset basically
		if OS.has_feature("clear_db"):
			if FileAccess.file_exists("user://database/test_db.db"):
				DirAccess.remove_absolute("user://database/test_db.db")
	
		database.path = "user://database/test_db.db"
		database.open_db()


func _create_users_table():
	var users_table = {
		"id" = {"data_type":"int", "primary_key": true},
		"username" = {"data_type":"char(50)", "not_null": true, "unique": true},
		"password" = {"data_type":"char(255)", "not_null": true},
		"data_kelas" = {"data_type":"text", "not_null": false},
		"point" = {"data_type":"int", "not_null": false},
		"total_point" = {"data_type":"int", "not_null": false}
	}
	
	database.create_table("users", users_table)
