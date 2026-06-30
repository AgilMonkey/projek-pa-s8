extends Control

@export var margin: float = 16.0

const SUBWINDOW = preload("uid://drc4t0hrrtk75")



func _process(_delta):
	for c in get_children():
		if c is Control:
			var min_pos = Vector2(margin, margin)
			var max_pos = size - c.size - Vector2(margin, margin)
			c.position = c.position.clamp(min_pos, max_pos)
	
	if AgilHelper.just_pressed(KEY_1): print("A")


func _input(event: InputEvent) -> void:
	if AgilHelper.key_just_pressed(event, KEY_K):
		_spawn_window()


func _spawn_window():
	var _window: SubwindowComponent = SUBWINDOW.instantiate()
	add_child(_window)
	
	var _area := size - _window.size
	_window.position = Vector2(
		randf() * _area.x,
		randf() * _area.y
		)
