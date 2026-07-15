class_name PanelKosakata
extends PanelContainer


signal kosakata_pressed_when_dissabled(_kosakata: GrabableWord)
signal kata_dropped(_kata: GrabableWord)
signal something_grabbed(_word: GrabableWord)

const GRABABLE_WORD = preload("uid://bcrdknddarcc7")
const DUMMY_GRABABLE_WORD = preload("uid://cl22ov2287fb2")

@onready var kosakata_h_flow_container: HFlowContainer = %KosakataHFlowContainer


func disable_mouse_for_all_grab_word():
	for n in kosakata_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enable_mouse_for_all_grab_word():
	for n in kosakata_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_STOP


func set_up_kosakata(_all_kosakata: Array[String]):
	for k in _all_kosakata:
		_spawn_tambah_kata(k)
	_all_kosakata_ready()


func dissable_kata(_kata: GrabableWord):
	_kata.dissabled = true


func enable_kata_ini(_kata: String):
	for _w in kosakata_h_flow_container.get_children():
		if _w is GrabableWord:
			if _w.word == _kata:
				_w.dissabled = false


func _spawn_tambah_kata(_text_kata: String):
	var n_word: GrabableWord = GRABABLE_WORD.instantiate()
	n_word.word = _text_kata
	kosakata_h_flow_container.add_child(n_word)


func cleanup():
	for w in kosakata_h_flow_container.get_children():
		if w is GrabableWord:
			w.queue_free()


func _all_kosakata_ready():
	for n in kosakata_h_flow_container.get_children():
		if n is GrabableWord:
			if !n.grabbed.is_connected(_this_word_grabbed):
				n.grabbed.connect(_this_word_grabbed)
			if !n.pressed_when_dissabled.is_connected(_kosakata_pressed.bind(n)):
				n.pressed_when_dissabled.connect(_kosakata_pressed.bind(n))


func _this_word_grabbed(_word: GrabableWord):
	something_grabbed.emit(_word)


func _kosakata_pressed(_kata: GrabableWord):
	kosakata_pressed_when_dissabled.emit(_kata)


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord and not (_data_word.get_parent() == kosakata_h_flow_container)


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	kata_dropped.emit(_data_word)
