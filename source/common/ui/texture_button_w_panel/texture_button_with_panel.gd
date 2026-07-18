## Forget it
extends PanelContainer


var normal: StyleBox
var hover: StyleBox
var pressed: StyleBox
var disabled: StyleBox
var focus: StyleBox

var is_hover := false


#func _ready() -> void:
	#if theme.has_stylebox("normal"):
		#normal = theme.get_stylebox("normal", "Button")
		#print(normal)
		#hover = theme.get_stylebox("hover", "Button")
		#pressed = theme.get_stylebox("pressed", "Button")
		#disabled = theme.get_stylebox("disabled", "Button")
		#focus = theme.get_stylebox("focus", "Button")
	
	#mouse_entered.connect(_mouse_entered)
	#mouse_exited.connect(_mouse_exited)


func _mouse_entered():
	add_theme_stylebox_override("panel", hover)


func _mouse_exited():
	add_theme_stylebox_override("panel", normal)
