@tool
class_name GrabableWord
extends PanelContainer


signal grabbed(_word_node: GrabableWord)
signal pressed_when_dissabled

const GRABABLE_WORD = preload("uid://bcrdknddarcc7")

@export var word := "Testing":
	set(val):
		word = val
		if word_label == null: return
		word_label.text = word

@export var dissabled := false:
	set(val):
		dissabled = val
		if panel_container == null or word_label == null: return
		panel_container.theme_type_variation = "" if !dissabled else "DissabledPanel"
		word_label.theme_type_variation = "" if !dissabled else "DissabledRichText"

var is_mouse_entered := false
var being_returned := false

@onready var panel_container: PanelContainer = $PanelContainer
@onready var word_label: RichTextLabel = %WordLabel


func _ready() -> void:
	word_label.text = word
	if Engine.is_editor_hint(): return
	
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _input(event: InputEvent) -> void:
	if is_mouse_entered and dissabled:
		if event is InputEventMouseButton:
			if event.button_index == 1 and event.pressed:
				pressed_when_dissabled.emit()
				_view_pressed_tween()


func _get_drag_data(_at_position: Vector2) -> Variant:
	if dissabled: return
	
	var new_grab_word: GrabableWord = self.duplicate()
	new_grab_word.size = Vector2(0, 0)
	new_grab_word.offset_transform_enabled = true
	new_grab_word.offset_transform_position_ratio = Vector2(-0.5, -0.5)
	set_drag_preview(new_grab_word)
	
	grabbed.emit(self)
	
	return self


func _mouse_entered():
	if Engine.is_editor_hint(): return
	z_index = 100
	var _tween := create_tween()
	_tween.tween_property(panel_container, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)
	is_mouse_entered = true


func _mouse_exited():
	if Engine.is_editor_hint(): return
	z_index = 0
	var _tween := create_tween()
	_tween.tween_property(panel_container, "offset_transform_scale", Vector2(1.0, 1.0), 0.1)
	is_mouse_entered = false


func _view_pressed_tween():
	var old_scale := panel_container.offset_transform_scale
	var _tween := create_tween()
	_tween.tween_property(panel_container, "offset_transform_scale", old_scale * 0.95, 0.05)
	_tween.tween_property(panel_container, "offset_transform_scale", old_scale, 0.05)
