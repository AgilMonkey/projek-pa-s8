extends Node2D

var database: SQLite

@onready var username_line: LineEdit = %UsernameLine
@onready var password_line: LineEdit = %PasswordLine
@onready var insert_button: Button = %InsertButton

@onready var list_button: Button = %ListButton
@onready var text_panel_output: RichTextLabel = %TextPanelOutput

@onready var search_user_button: Button = %SearchUserButton
@onready var search_username_line: LineEdit = %SearchUsernameLine


func _ready() -> void:
	database = SQLite.new()
	
	if not DirAccess.dir_exists_absolute("res://database"):
		DirAccess.make_dir_absolute("res://database")
	
	#if FileAccess.file_exists("res://database/test_db.db"):
		#DirAccess.remove_absolute("res://database/test_db.db")
	
	database.path = "res://database/test_db.db"
	database.open_db()
	
	create_users_table()
	
	insert_button.pressed.connect(insert_user_table)
	list_button.pressed.connect(list_all_users_table)
	search_user_button.pressed.connect(search_username_in_users_table)
	%UpdateUserButton.pressed.connect(update_username_password)
	%DeleteUserButton.pressed.connect(delete_user)
	%LoginUserButton.pressed.connect(login_user)


func create_users_table():
	var users_table = {
		"id" = {"data_type":"int", "primary_key": true},
		"username" = {"data_type":"char(50)", "not_null": true, "unique": true},
		"password" = {"data_type":"char(255)", "not_null": true},
	}
	
	database.create_table("users", users_table)


func insert_user_table():
	var insert_user_data = {
		"username" : %UsernameLine.text,
		"password" : %PasswordLine.text.sha256_text(),
	}
	
	if str(%UsernameLine.text).strip_edges().is_empty(): return
	
	database.insert_row("users", insert_user_data)
	
	%UsernameLine.text = ""
	%PasswordLine.text = ""


func list_all_users_table():
	var all_users_data := database.select_rows("users", "", ["*"])
	text_panel_output.text = str(JSON.stringify(all_users_data, "\t"))


func search_username_in_users_table():
	var search_name := search_username_line.text
	var user_with_name := database.select_rows("users", "username = '%s'" % search_name, ["*"])
	text_panel_output.text = str(JSON.stringify(user_with_name, "\t"))


func update_username_password():
	database.update_rows(
		"users",
		"username='%s'" % [%UpdateUsernameLine.text],
		{"password": %UpdatePasswordLine.text.sha256_text()}
	)
	
	var user_with_name := database.select_rows(
		"users",
		"username = '%s'" % %UpdateUsernameLine.text,
		["*"]
	)
	text_panel_output.text = "Updated!\n"
	text_panel_output.text += str(JSON.stringify(user_with_name, "\t"))


func delete_user():
	database.delete_rows(
		"users",
		"username='%s'" % [%DeleteUsernameLine.text]
	)
	
	text_panel_output.text = "Deleted %s!" % %DeleteUsernameLine.text


func login_user():
	var user: Array[Dictionary] = database.select_rows(
		"users",
		"username = '%s'" % %LoginUsernameLine.text,
		["*"]
	)
	
	if user.is_empty():
		text_panel_output.text = "We didn't find that user"
		return
	elif len(user) > 1:
		text_panel_output.text = "Why the fuck is there two user with the same name!?"
		return
	else:
		var user_data := user[0]
		if user_data["password"] == %LoginPasswordLine.text.sha256_text():
			text_panel_output.text = "Login sucessful!"
		else:
			text_panel_output.text = "Wrong password!"
