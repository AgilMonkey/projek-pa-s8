class_name PanelKosakata
extends PanelContainer


signal something_grabbed(_word: GrabableWord)

const GRABABLE_WORD = preload("uid://bcrdknddarcc7")

@onready var kosakata_h_flow_container: HFlowContainer = %KosakataHFlowContainer


func _this_word_grabbed(_word: GrabableWord):
	something_grabbed.emit(_word)


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
		var n_word: GrabableWord = GRABABLE_WORD.instantiate()
		n_word.word = k
		kosakata_h_flow_container.add_child(n_word)
	
	_all_kosakata_ready()


func cleanup():
	for w in kosakata_h_flow_container.get_children():
		if w is GrabableWord:
			w.queue_free()


func _all_kosakata_ready():
	for n in kosakata_h_flow_container.get_children():
		if n is GrabableWord:
			if n.grabbed.is_connected(_this_word_grabbed):
				continue
			n.grabbed.connect(_this_word_grabbed)


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	_data_word.reparent(kosakata_h_flow_container)
