class_name PanelJawaban
extends PanelContainer


signal kata_dropped(_kata: GrabableWord)
signal ada_jawaban(_jawaban_full_text: String)
signal something_grabbed(_word: GrabableWord)

var jawaban_full_text: String

@onready var panel_jawaban_h_flow_container: HFlowContainer = %PanelJawabanHFlowContainer
@onready var label_panel_jawaban: RichTextLabel = %LabelPanelJawaban


func _ready() -> void:
	panel_jawaban_h_flow_container.child_order_changed.connect(_panel_jawaban_h_flow_container_child_order_changed)
	_set_up_kosakata()


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


func spawn_kata(_word: GrabableWord) -> GrabableWord:
	var w_dup := _word.duplicate()
	panel_jawaban_h_flow_container.add_child(
		w_dup
	)
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
	return _data_word is GrabableWord


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	
	kata_dropped.emit(_data_word)


func _panel_jawaban_h_flow_container_child_order_changed():
	label_panel_jawaban.visible = !panel_jawaban_h_flow_container.get_children().size() > 0
