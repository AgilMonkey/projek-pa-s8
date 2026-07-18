extends ScrollContainer


var main_v_scroll: VScrollBar

@onready var content_scroller: VScrollBar = %ContentScroller


func _ready() -> void:
	main_v_scroll = get_v_scroll_bar()
	#content_scroller.scrolling.connect(_content_scroller_scrolling)


func _process(_delta: float) -> void:
	content_scroller.min_value = main_v_scroll.min_value
	content_scroller.max_value = main_v_scroll.max_value
	content_scroller.page = main_v_scroll.page
	
	main_v_scroll.value = lerp(main_v_scroll.value, content_scroller.value, _delta * 20.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			content_scroller.value -= 1.0 * 100.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			content_scroller.value += 1.0 * 100.0
		accept_event()


#func _content_scroller_scrolling():
	#main_v_scroll.value = content_scroller.value
