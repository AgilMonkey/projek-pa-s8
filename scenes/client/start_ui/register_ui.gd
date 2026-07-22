class_name RegisterUI
extends Control

signal on_registering(_data: Dictionary)

@onready var error_labels: Control = %ErrorLabels
@onready var username_error_label: RichTextLabel = %UsernameErrorLabel
@onready var password_error_label: RichTextLabel = %PasswordErrorLabel

@onready var username_line: LineEdit = %UsernameLine
@onready var password_line: LineEdit = %PasswordLine
@onready var password_again_line: LineEdit = %PasswordAgainLine

@onready var back_button: Button = %BackButton
@onready var register_button: Button = %RegisterButton

@onready var register_panel: PanelContainer = %RegisterPanel
@onready var username_container: HBoxContainer = %UsernameContainer
@onready var password_container: HBoxContainer = %PasswordContainer
@onready var password_again_container: HBoxContainer = %PasswordAgainContainer


func _ready() -> void:
	register_button.pressed.connect(
		func():
			username_error_label.hide()
			password_error_label.hide()
			
			if username_line.text.is_empty():
				_show_error("[color=red]Username tidak boleh kosong[/color]")
				return
			
			if password_line.text.is_empty():
				_show_error("", "[color=red]Password tidak boleh kosong[/color]")
				return
			
			if password_again_line.text.is_empty():
				_show_error("", "[color=red]Tulis password mu lagi[/color]")
				return
			
			if password_line.text != password_again_line.text:
				_show_error("", "[color=red]Password tidak sama![/color]")
				return
			
			on_registering.emit({
				"username":username_line.text,
				"password":password_line.text,
			})
	)


func _process(_delta: float) -> void:
	#var register_panel_right_edge = register_panel.global_position.x + register_panel.size.x
	#
	#error_labels.global_position.x = register_panel_right_edge
	username_error_label.global_position.y = username_container.global_position.y
	password_error_label.global_position.y = password_container.global_position.y


func _show_error(username_error_msg := "", password_error_msg := ""):
	username_error_label.hide()
	password_error_label.hide()
	
	if username_error_msg:
		username_error_label.show()
		username_error_label.text = username_error_msg
		username_error_label.reset_size()
	
	if password_error_msg:
		password_error_label.show()
		password_error_label.text = password_error_msg
		password_error_label.reset_size()
