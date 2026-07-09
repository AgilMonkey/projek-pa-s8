extends Node


var client_main_ui: ClientMainUI


func set_main_game_ui_visibility(_visible: bool):
	client_main_ui.main_game_ui.visible = _visible


func set_client_course_ui_visibility(_visible: bool):
	client_main_ui.client_course_ui.visible = _visible
