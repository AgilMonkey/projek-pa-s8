class_name SubwindowComponent
extends PanelContainer


@onready var close_button: Button = %CloseButton
@onready var title_area: Control = %TitleArea

var drag_offset := Vector2.ZERO
var is_dragging := false


func _ready() -> void:
	close_button.pressed.connect( func(): queue_free() )
	
	title_area.gui_input.connect(
		func(event: InputEvent):
			if event is InputEventMouseButton:
				if event.button_index == 1 and event.pressed:
					is_dragging = true
					drag_offset = global_position - get_global_mouse_position()
					_reorder_node_to_be_first_in_child()
				elif event.button_index == 1 and event.is_released():
					is_dragging = false
			
			if event is InputEventMouseMotion and is_dragging:
				global_position = get_global_mouse_position() + drag_offset
	)


func _reorder_node_to_be_first_in_child():
	get_parent().move_child(self, -1)
