extends PanelContainer


@onready var panel_jawaban_h_flow_container: HFlowContainer = %PanelJawabanHFlowContainer


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord


func _drop_data(at_position: Vector2, data_word: Variant) -> void:
	if not data_word is GrabableWord: return
	data_word.reparent(panel_jawaban_h_flow_container)
