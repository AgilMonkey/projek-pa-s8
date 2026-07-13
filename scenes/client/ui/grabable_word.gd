class_name GrabableWord
extends PanelContainer


@export var word := "Testing":
	set(val):
		word = val

@onready var panel_container: PanelContainer = $PanelContainer
@onready var word_label: RichTextLabel = %WordLabel


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	word_label.text = word


func _get_drag_data(at_position: Vector2) -> Variant:
	return self


func _mouse_entered():
	z_index = 100
	var _tween := create_tween()
	_tween.tween_property(panel_container, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)


func _mouse_exited():
	z_index = 0
	var _tween := create_tween()
	_tween.tween_property(panel_container, "offset_transform_scale", Vector2(1.0, 1.0), 0.1)
