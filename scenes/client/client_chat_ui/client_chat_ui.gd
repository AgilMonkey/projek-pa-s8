class_name ClientChatUI
extends Control


var max_panel_size := Vector2(800.0, 750.0)

var chat_panel_size_saved := Vector2.ZERO

var is_chat_panel_openned := false
var is_chat_panel_resized := false

@onready var main_panel_container: PanelContainer = %MainPanelContainer

@onready var chat_button: Button = %ChatButton
@onready var text_chat_container_panel: PanelContainer = %TextChatContainerPanel
@onready var chat_buttons_container: HBoxContainer = %ChatButtonsContainer
@onready var resize_control: Control = %ResizeControl
@onready var right_down_resize_control: Control = %RightDownResizeControl


func _ready() -> void:
	_open_close_chat_panel()
	
	chat_button.pressed.connect(_open_close_chat_panel)
	right_down_resize_control.gui_input.connect(_resize_gui_input)


func _resize_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		is_chat_panel_resized = event.pressed
	
	if event is InputEventMouseMotion and is_chat_panel_resized:
		main_panel_container.size = get_global_mouse_position()
		main_panel_container.size = main_panel_container.size.clamp(
			Vector2.ZERO,
			max_panel_size
		)


func _open_close_chat_panel():
	if is_chat_panel_openned:
		main_panel_container.size = chat_panel_size_saved
		
		chat_button.text = "Tutup Chat"
		text_chat_container_panel.show()
		chat_buttons_container.show()
		resize_control.show()
		is_chat_panel_openned = false
	else:
		chat_panel_size_saved = main_panel_container.size
		
		chat_button.text = "Buka Chat"
		text_chat_container_panel.hide()
		chat_buttons_container.hide()
		resize_control.hide()
		is_chat_panel_openned = true
		
		main_panel_container.set_anchors_and_offsets_preset(
			Control.PRESET_TOP_LEFT
		)
