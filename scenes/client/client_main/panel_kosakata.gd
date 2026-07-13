extends PanelContainer


@onready var kosakata_h_flow_container: HFlowContainer = %KosakataHFlowContainer


func _can_drop_data(_position, _data_word):
	return _data_word is GrabableWord


func _drop_data(_at_position: Vector2, _data_word: Variant) -> void:
	if not _data_word is GrabableWord: return
	_data_word.reparent(kosakata_h_flow_container)
