@tool
class_name LineControl
extends Control


@onready var line_2d: Line2D = $Line2D


func _process(delta: float) -> void:
	var pos_x := (position.x + size.x) / 2.0
	line_2d.position.x = pos_x
	
	var pos_one := Vector2(0.0, 0.0)
	var pos_two := Vector2(0.0, size.y)
	line_2d.set_point_position(0, pos_one)
	line_2d.set_point_position(1, pos_two)
