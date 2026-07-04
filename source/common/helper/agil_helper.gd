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
