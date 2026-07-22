class_name ClientChatUI
extends Control


## Use this for like server stuff. Have chat manager maybe
signal client_chat_send_msg(msg: String)

## Use this so I can stop player when chatting later
signal client_is_chatting(is_chatting: bool)

var max_panel_size := Vector2(800.0, 750.0)

var chat_panel_size_saved := Vector2.ZERO

var is_chat_panel_openned := false
var is_chat_panel_resized := false

@onready var main_panel_container: PanelContainer = %MainPanelContainer

@onready var chat_button: Button = %ChatButton
#@onready var text_chat_container_panel: PanelContainer = %TextChatContainerPanel
@onready var chat_buttons_container: HBoxContainer = %ChatButtonsContainer
@onready var resize_control: Control = %ResizeControl
@onready var right_down_resize_control: Control = %RightDownResizeControl
@onready var chat_box_text: RichTextLabel = %ChatBoxText


func _ready() -> void:
	_open_close_chat_panel()
	
	chat_button.pressed.connect(_open_close_chat_panel)
	right_down_resize_control.gui_input.connect(_resize_gui_input)
	%ChatTextEdit.gui_input.connect(_chat_text_edit_gui_input)
	
	%SendButton.pressed.connect(_send_chat_msg)
	
	%ChatTextEdit.focus_entered.connect(func(): client_is_chatting.emit(true))
	%ChatTextEdit.focus_exited.connect(func(): client_is_chatting.emit(false))


## Get whole messages array. Erases the text box and set it to this new one
func set_chat_bot_text(messages: Array[Dictionary]):
	var new_chat_box_text_messages = ""
	
	for msg_dict in messages:
		var username: String = msg_dict["username"]
		var msg: String = msg_dict["msg"]
		var new_msg_string := "%s: %s\n" % [username, msg]
		new_chat_box_text_messages += _safe_chat_text(new_msg_string)
	
	%ChatBoxText.text = new_chat_box_text_messages


func _safe_chat_text(msg: String) -> String:
	return msg.replace("[", "[lb]")


func _send_chat_msg():
	if %ChatTextEdit.text == "": return
	
	client_chat_send_msg.emit(%ChatTextEdit.text)
	%ChatTextEdit.release_focus()
	%ChatTextEdit.clear()


func _resize_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		is_chat_panel_resized = event.pressed
	
	if event is InputEventMouseMotion and is_chat_panel_resized:
		main_panel_container.size = get_global_mouse_position()
		main_panel_container.size = main_panel_container.size.clamp(
			Vector2.ZERO,
			max_panel_size
		)


func _chat_text_edit_gui_input(_event: InputEvent):
	if _event is InputEventKey:
		if _event.keycode == KEY_ENTER and _event.is_pressed():
			_send_chat_msg()
			accept_event()


func _open_close_chat_panel():
	if is_chat_panel_openned:
		main_panel_container.size = chat_panel_size_saved
		
		chat_button.text = "Tutup Chat"
		#text_chat_container_panel.show()
		chat_box_text.show()
		chat_buttons_container.show()
		resize_control.show()
		is_chat_panel_openned = false
	else:
		chat_panel_size_saved = main_panel_container.size
		
		chat_button.text = "Buka Chat"
		#text_chat_container_panel.hide()
		chat_box_text.hide()
		chat_buttons_container.hide()
		resize_control.hide()
		is_chat_panel_openned = true
		
		main_panel_container.set_anchors_and_offsets_preset(
			Control.PRESET_TOP_LEFT
		)
