extends Control


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_viewport().gui_release_focus()   # release whatever has focus
		print("A")
