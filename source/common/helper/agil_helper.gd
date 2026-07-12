## A helper created by agil for common functions and const
extends Node


var _curr := {}
var _prev := {}
var _watch := {}   # keycodes to track


func _process(_delta):
	for k in _watch:
		_prev[k] = _curr.get(k, false)
		_curr[k] = Input.is_key_pressed(k)


## Only use this inside of [method Node._process]
func just_pressed(keycode: int) -> bool:
	_watch[keycode] = true          # auto-register on first use
	return _curr.get(keycode, false) and not _prev.get(keycode, false)


## Only use this inside of [method Node._input]
func key_just_pressed(event: InputEvent, keycode: int) -> bool:
	return event is InputEventKey \
		and event.pressed \
		and not event.echo \
		and event.keycode == keycode


## Create a timer and add it as a _node child
static func create_timer_on_current_node(_node: Node, _autostart := false, _ignore_time_scale := false, _oneshot := false) -> Timer:
	assert(_node != null, "_node is null! Fyd")
	
	var new_t := Timer.new()
	new_t.autostart = _autostart
	new_t.ignore_time_scale = _ignore_time_scale
	new_t.one_shot = _oneshot
	_node.add_child(new_t)
	
	return new_t
