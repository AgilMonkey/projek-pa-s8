@tool
@icon("res://addons/at-icons/control/arrow_x.svg")
extends Control
class_name KeepInMarginControl


@export var margin_left := 0
@export var margin_right := 0
@export var margin_up := 0
@export var margin_down := 0

var min_x: float
var max_x: float
var min_y: float
var max_y: float


func _process(_delta: float) -> void:
	min_x = global_position.x + margin_left
	max_x = global_position.x + size.x - margin_right
	min_y = global_position.y + margin_up
	max_y = global_position.y + size.y - margin_down
	
	for child: Control in get_children():
		var new_max_x := (max_x - min_x) - child.size.x
		var new_max_y := (max_y - min_y) - child.size.y
		
		child.global_position.x = clamp(child.global_position.x, min_x, new_max_x)
		child.global_position.y = clamp(child.global_position.y, min_y, new_max_y)
