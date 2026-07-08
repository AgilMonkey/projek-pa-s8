## Deals with main game window. Different from context window which is super global
extends Node


const SUBWINDOW = preload("uid://drc4t0hrrtk75")

var main_game_window_spawner: Control


func create_subwindow_with_control(node: Control) -> SubwindowComponent:
	var new_s: SubwindowComponent = SUBWINDOW.instantiate()
	main_game_window_spawner.add_child(new_s)
	
	new_s.add_child(node)
	
	new_s.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	return new_s


func set_main_game_window_spawner(control):
	main_game_window_spawner = control
