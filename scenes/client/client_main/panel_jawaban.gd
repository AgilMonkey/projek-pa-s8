class_name PanelJawaban
extends PanelContainer


const DUMMY_GRABABLE_WORD = preload("uid://cl22ov2287fb2")

signal kata_dropped(_kata: GrabableWord, idx: int)
signal ada_jawaban(_jawaban_full_text: String)
signal something_grabbed(_word: GrabableWord)

var jawaban_full_text: String
var cur_dummy_k: DummyGrabableWord
var is_mouse_entered := false

@onready var panel_jawaban_h_flow_container: HFlowContainer = %PanelJawabanHFlowContainer
@onready var label_panel_jawaban: RichTextLabel = %LabelPanelJawaban


func _ready() -> void:
	panel_jawaban_h_flow_container.child_order_changed.connect(_panel_jawaban_h_flow_container_child_order_changed)
	_set_up_kosakata()
	
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func set_jawaban_full_text():
	jawaban_full_text = ""
	for _jwb in panel_jawaban_h_flow_container.get_children():
		if _jwb is GrabableWord:
			jawaban_full_text += _jwb.word + " "
	ada_jawaban.emit(jawaban_full_text)


func cleanup():
	for w in panel_jawaban_h_flow_container.get_children():
		if w is GrabableWord:
			w.queue_free()


func spawn_kata(_word: GrabableWord, _move_idx: int) -> GrabableWord:
	var w_dup := _word.duplicate()
	panel_jawaban_h_flow_container.add_child(
		w_dup
	)
	panel_jawaban_h_flow_container.move_child(w_dup, _move_idx)
	
	_set_up_kosakata()
	set_jawaban_full_text()
	
	return w_dup


func unspawn_kata(_kata: GrabableWord):
	_kata.free()


func disable_mouse_for_all_grab_word():
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enable_mouse_for_all_grab_word():
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_STOP


func _set_up_kosakata() -> void:
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			if !n.grabbed.is_connected(_this_word_grabbed):
				n.grabbed.connect(_this_word_grabbed)


func _this_word_grabbed(_word: GrabableWord):
	something_grabbed.emit(_word)


func _can_drop_data(_position, _data_word):
	if _data_word.get_parent() == panel_jawaban_h_flow_container: return false
	if not _data_word is GrabableWord: return false
	if cur_dummy_k != null:
		var _move_dum_idx := -1
		for c: Control in panel_jawaban_h_flow_container.get_children():
			if get_global_mouse_position().x < c.global_position.x:
				_move_dum_idx = c.get_index() - 1
		panel_jawaban_h_flow_container.move_child(cur_dummy_k, _move_dum_idx)
	
	if _data_word is GrabableWord and cur_dummy_k == null:
		cur_dummy_k = DUMMY_GRABABLE_WORD.instantiate()
		cur_dummy_k.word = _data_word.word
		panel_jawaban_h_flow_container.add_child(cur_dummy_k)
		var _move_dum_idx := -1
		for c: Control in panel_jawaban_h_flow_container.get_children():
			if get_global_mouse_position().x < c.global_position.x:
				_move_dum_idx = c.get_index() - 1
		panel_jawaban_h_flow_container.move_child(cur_dummy_k, _move_dum_idx)
	return true


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	var _move_idx := -1
	for c: Control in panel_jawaban_h_flow_container.get_children():
		if get_global_mouse_position().x < c.global_position.x:
			_move_idx = c.get_index() - 1
	
	if cur_dummy_k != null: cur_dummy_k.free()
	
	kata_dropped.emit(_data_word, _move_idx)


func _panel_jawaban_h_flow_container_child_order_changed():
	label_panel_jawaban.visible = !panel_jawaban_h_flow_container.get_children().size() > 0


func _mouse_entered():
	is_mouse_entered = true


func _mouse_exited():
	is_mouse_entered = false
	if cur_dummy_k != null: cur_dummy_k.queue_free()
