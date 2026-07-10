@tool
@icon("res://addons/at-icons/control/window.svg")
class_name SubwindowComponent
extends PanelContainer


signal on_dragged
signal on_resized
signal on_closed

@export var title_text := "Title": 
	set(value):
		title_text = value
		%WindowTitle.text = title_text

@export var max_window_size := Vector2(1000.0, 1000.0)

var is_being_resized := false
var old_window_pos: Vector2
var old_window_size: Vector2

var drag_offset := Vector2.ZERO
var is_dragging := false

@onready var title_area: Control = %TitleArea
@onready var close_button: TextureButton = %CloseButton


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	close_button.pressed.connect(
		func():
			on_closed.emit()
			queue_free()
	)
	
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
				on_dragged.emit()
	)
	
	#region  These are for resizing
	
	%DownRightControl.gui_input.connect(
		func(event):
			if event is InputEventMouseButton:
				is_being_resized = event.pressed
	
			if event is InputEventMouseMotion and is_being_resized:
				size = get_global_mouse_position() - global_position
				size = size.clamp(
					Vector2.ZERO,
					max_window_size
				)
				on_resized.emit()
	)
	
	%UpRightControl.gui_input.connect(
		func(event):
			if event is InputEventMouseButton:
				old_window_pos = global_position
				old_window_size = size
				is_being_resized = event.pressed
	
			if event is InputEventMouseMotion and is_being_resized:
				var g_mouse_pos := get_global_mouse_position()
				global_position.y = g_mouse_pos.y
				var max_y := (old_window_pos.y + old_window_size.y) - get_combined_minimum_size().y
				global_position.y = min(max_y, global_position.y)
				
				var new_size = Vector2(
					g_mouse_pos.x - old_window_pos.x,
					(old_window_pos.y + old_window_size.y) - g_mouse_pos.y
				)
				size = new_size
				size = size.clamp(
					Vector2.ZERO,
					max_window_size
				)
				on_resized.emit()
	)
	
	%DownLeftControl.gui_input.connect(
		func(event):
			if event is InputEventMouseButton:
				old_window_pos = global_position
				old_window_size = size
				is_being_resized = event.pressed
	
			if event is InputEventMouseMotion and is_being_resized:
				var g_mouse_pos := get_global_mouse_position()
				global_position.x = g_mouse_pos.x
				var max_x := (old_window_pos.x + old_window_size.x) - get_combined_minimum_size().x
				global_position.x = min(max_x, global_position.x)
				
				var new_size = Vector2(
					(old_window_pos.x + old_window_size.x) - g_mouse_pos.x,
					g_mouse_pos.y - old_window_pos.y
				)
				size = new_size
				size = size.clamp(
					Vector2.ZERO,
					max_window_size
				)
				on_resized.emit()
	)
	
	%UpLeftControl.gui_input.connect(
		func(event):
			if event is InputEventMouseButton:
				old_window_pos = global_position
				old_window_size = size
				is_being_resized = event.pressed
	
			if event is InputEventMouseMotion and is_being_resized:
				var g_mouse_pos := get_global_mouse_position()
				global_position = g_mouse_pos
				var max_win_pos := Vector2(
					(old_window_pos.x + old_window_size.x) - get_combined_minimum_size().x,
					(old_window_pos.y + old_window_size.y) - get_combined_minimum_size().y
				)
				global_position = global_position.min(max_win_pos)
				
				var new_size = Vector2(
					(old_window_pos.x + old_window_size.x) - g_mouse_pos.x,
					(old_window_pos.y + old_window_size.y) - g_mouse_pos.y
				)
				size = new_size
				size = size.clamp(
					Vector2.ZERO,
					max_window_size
				)
				on_resized.emit()
	)
	
	#endregion
	
	on_resized.connect(
		func():
			for child: Control in get_children():
				%MainContentContainer.custom_minimum_size = Vector2.ZERO
				
				if child.owner != self:
					
					child.global_position =  %MainContentContainer.global_position
					child.size = %MainContentContainer.size
					
					if (
						child.custom_minimum_size.length_squared() >
						%MainContentContainer.custom_minimum_size.length_squared()
					):
						%MainContentContainer.custom_minimum_size = child.custom_minimum_size
					if child is Container:
						%MainContentContainer.custom_minimum_size = child.get_combined_minimum_size()
			)


func _process(_delta: float) -> void:
	_set_the_child_main_content_rect()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_set_the_child_main_content_rect()


func _set_the_child_main_content_rect():
	for child: Control in get_children():
		%MainContentContainer.custom_minimum_size = Vector2.ZERO
		if child.owner != self:
			child.global_position =  %MainContentContainer.global_position
			child.size = %MainContentContainer.size
			
			if (
				child.custom_minimum_size.length_squared() >
				%MainContentContainer.custom_minimum_size.length_squared()
			):
				%MainContentContainer.custom_minimum_size = child.custom_minimum_size
			if child is Container:
				%MainContentContainer.custom_minimum_size = child.get_combined_minimum_size()
				child.queue_sort()


func _reorder_node_to_be_first_in_child():
	get_parent().move_child(self, -1)
