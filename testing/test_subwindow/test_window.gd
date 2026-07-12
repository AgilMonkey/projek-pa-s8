extends Control


var window_duplicate: SubwindowComponent


func _ready() -> void:
	window_duplicate = $KeepInMarginControl/SubwindowComponent.duplicate()


func _input(event: InputEvent) -> void:
	if AgilHelper.key_just_pressed(event, KEY_0):
		var new_w: SubwindowComponent = window_duplicate.duplicate()
		new_w.global_position = Vector2(
			randf_range(0, 1200),
			randf_range(0, 720)
		)
		$KeepInMarginControl.add_child(new_w)
