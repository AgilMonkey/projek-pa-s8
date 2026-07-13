extends PanelContainer


@onready var panel_jawaban_h_flow_container: HFlowContainer = %PanelJawabanHFlowContainer
@onready var label_panel_jawaban: RichTextLabel = %LabelPanelJawaban


func _ready() -> void:
	panel_jawaban_h_flow_container.child_order_changed.connect(_panel_jawaban_h_flow_container_child_order_changed)


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	_data_word.reparent(panel_jawaban_h_flow_container)


func _panel_jawaban_h_flow_container_child_order_changed():
	label_panel_jawaban.visible = !panel_jawaban_h_flow_container.get_children().size() > 0
