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
		if window_title != null: window_title.text = title_text

## WIP: Should be used to make sure a window sticks to a margin but w/e for now
@export var margin_size := Rect2(-10000, -10000, 10000, 10000)

@export var is_grabable: = true
@export var is_resizeable: = true

var is_being_resized := false
var old_window_pos: Vector2
var old_window_size: Vector2

var drag_offset := Vector2.ZERO
var is_dragging := false


@onready var window_title := %WindowTitle


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	window_title.text = title_text
	
	%CloseButton.pressed.connect(
		func():
			on_closed.emit()
			queue_free()
	)
	
	%TitleGrabableArea.gui_input.connect(
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
				var min_y := (old_window_pos.y + old_window_size.y) - get_combined_maximum_size().y
				if get_combined_maximum_size().y < 0.0: min_y = -INF
				var max_y := (old_window_pos.y + old_window_size.y) - get_combined_minimum_size().y
				global_position.y = clampf(global_position.y, min_y, max_y)
				
				var new_size = Vector2(
					g_mouse_pos.x - old_window_pos.x,
					(old_window_pos.y + old_window_size.y) - g_mouse_pos.y
				)
				size = new_size
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
				var min_x := (old_window_pos.x + old_window_size.x) - get_combined_maximum_size().x
				if get_combined_maximum_size().x < 0.0: min_x = -INF
				var max_x := (old_window_pos.x + old_window_size.x) - get_combined_minimum_size().x
				global_position.x = clampf(global_position.x, min_x, max_x)
				
				var new_size = Vector2(
					(old_window_pos.x + old_window_size.x) - g_mouse_pos.x,
					g_mouse_pos.y - old_window_pos.y
				)
				size = new_size
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
				var min_win_pos := Vector2(
					(old_window_pos.x + old_window_size.x) - get_combined_maximum_size().x,
					(old_window_pos.y + old_window_size.y) - get_combined_maximum_size().y
				)
				if get_combined_maximum_size().x < 0.0: min_win_pos.x = -INF
				if get_combined_maximum_size().y < 0.0: min_win_pos.y = -INF
				var max_win_pos := Vector2(
					(old_window_pos.x + old_window_size.x) - get_combined_minimum_size().x,
					(old_window_pos.y + old_window_size.y) - get_combined_minimum_size().y
				)
				global_position = global_position.clamp(min_win_pos, max_win_pos)
				
				var new_size = Vector2(
					(old_window_pos.x + old_window_size.x) - g_mouse_pos.x,
					(old_window_pos.y + old_window_size.y) - g_mouse_pos.y
				)
				size = new_size
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
	%TitleGrabableArea.visible = is_grabable
	
	%UpLeftControl.visible = is_resizeable
	%UpRightControl.visible = is_resizeable
	%DownLeftControl.visible = is_resizeable
	%DownRightControl.visible = is_resizeable
	
	_set_the_child_main_content_rect()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_set_the_child_main_content_rect()


func _exit_tree() -> void: on_closed.emit()


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
