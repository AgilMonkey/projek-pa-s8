class_name MenjawabPertanyaanUI
extends VBoxContainer


var _something_is_being_grabbed := false

@onready var panel_jawaban: PanelJawaban = %PanelJawaban
@onready var panel_kosakata: PanelKosakata = %PanelKosakata


func _ready() -> void:
	panel_kosakata.something_grabbed.connect(_something_grabbed)
	panel_jawaban.something_grabbed.connect(_something_grabbed)


func _something_grabbed(_word: GrabableWord):
	panel_jawaban.disable_mouse_for_all_grab_word()
	panel_kosakata.disable_mouse_for_all_grab_word()
	_something_is_being_grabbed = true


func _something_dropped():
	panel_jawaban.enable_mouse_for_all_grab_word()
	panel_kosakata.enable_mouse_for_all_grab_word()
	_something_is_being_grabbed = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_released() and _something_is_being_grabbed:
			_something_dropped()
