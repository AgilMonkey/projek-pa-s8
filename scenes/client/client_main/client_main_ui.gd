class_name ClientMainUI
extends CanvasLayer


@onready var main_game_ui: Control = %MainGameUI
@onready var client_course_ui: ClientCourseUI = %ClientCourseUI


func _ready() -> void:
	multiplayer.server_disconnected.connect(_server_disconnected)


func _server_disconnected():
	client_course_ui.hide()
