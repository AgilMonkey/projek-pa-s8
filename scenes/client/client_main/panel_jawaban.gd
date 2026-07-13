class_name PanelJawaban
extends PanelContainer


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


func _set_up_kosakata() -> void:
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			n.grabbed.connect(_this_word_grabbed)


func _this_word_grabbed(_word: GrabableWord):
	something_grabbed.emit(_word)


func disable_mouse_for_all_grab_word():
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enable_mouse_for_all_grab_word():
	for n in panel_jawaban_h_flow_container.get_children():
		if n is GrabableWord:
			n.mouse_filter = Control.MOUSE_FILTER_STOP


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	_data_word.reparent(panel_jawaban_h_flow_container)
	set_jawaban_full_text()


func _panel_jawaban_h_flow_container_child_order_changed():
	label_panel_jawaban.visible = !panel_jawaban_h_flow_container.get_children().size() > 0
