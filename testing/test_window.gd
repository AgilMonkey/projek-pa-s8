extends Control


var window_window: PackedScene


func _ready() -> void:
	window_window = PackedScene.new()
	window_window.pack($SubwindowComponent)


func _input(event: InputEvent) -> void:
	if AgilHelper.key_just_pressed(event, KEY_0):
		var new_w: SubwindowComponent = window_window.instantiate()
		new_w.global_position = Vector2(
			randf_range(0, 1200),
			randf_range(0, 720)
		)
		add_child(new_w)
