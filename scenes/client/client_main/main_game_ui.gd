extends Control


func _unhandled_input(event):
	# _unhandled_input only fires if no Control consumed the event first
	if event is InputEventMouseButton and event.pressed:
		get_viewport().gui_release_focus()
