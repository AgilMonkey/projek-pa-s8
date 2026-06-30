extends Node

var database: SQLite


func _ready() -> void:
	if !OS.has_feature("server"): return
	
	_create_database()
	_create_users_table()


func _create_database():
	database = SQLite.new()
	
	if OS.has_feature("production"):
		# Production enviroment
		pass
	else:
		# Test enviroment
		if not DirAccess.dir_exists_absolute("res://database"):
			DirAccess.make_dir_absolute("res://database")
		
		# Delete DB and reset basically
		if OS.has_feature("clear_db"):
			if FileAccess.file_exists("res://database/test_db.db"):
				DirAccess.remove_absolute("res://database/test_db.db")
	
		database.path = "res://database/test_db.db"
		database.open_db()


func _create_users_table():
	var users_table = {
		"id" = {"data_type":"int", "primary_key": true},
		"username" = {"data_type":"char(50)", "not_null": true, "unique": true},
		"password" = {"data_type":"char(255)", "not_null": true},
	}
	
	database.create_table("users", users_table)
