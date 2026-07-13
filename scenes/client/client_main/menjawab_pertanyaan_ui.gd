class_name MenjawabPertanyaanUI
extends VBoxContainer


var full_text_jawaban: String

var _something_is_being_grabbed := false

@onready var panel_jawaban: PanelJawaban = %PanelJawaban
@onready var panel_kosakata: PanelKosakata = %PanelKosakata
@onready var jawab_button: Button = %JawabButton


func _ready() -> void:
	panel_kosakata.something_grabbed.connect(_something_grabbed)
	panel_jawaban.something_grabbed.connect(_something_grabbed)
	panel_jawaban.ada_jawaban.connect(_panel_jawaban_ada_jawaban)


func set_up_kosakata(_all_kosakata: Array[String]):
	clean_up_kosakata()
	panel_kosakata.set_up_kosakata(_all_kosakata)
	jawab_button.disabled = true


func clean_up_kosakata():
	panel_kosakata.cleanup()
	panel_jawaban.cleanup()


func _something_grabbed(_word: GrabableWord):
	panel_jawaban.disable_mouse_for_all_grab_word()
	panel_kosakata.disable_mouse_for_all_grab_word()
	_something_is_being_grabbed = true


func _something_dropped():
	panel_jawaban.enable_mouse_for_all_grab_word()
	panel_kosakata.enable_mouse_for_all_grab_word()
	
	panel_jawaban.set_jawaban_full_text()
	
	_something_is_being_grabbed = false


func _panel_jawaban_ada_jawaban(_full_text: String):
	jawab_button.disabled = _full_text.is_empty()
	full_text_jawaban = _full_text


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_released() and _something_is_being_grabbed:
			call_deferred("_something_dropped")
