class_name LoginUi
extends Control

signal on_login_button_pressed(data: Dictionary)

@onready var register_button: Button = %RegisterButton


func _ready() -> void:
	%LoginButton.pressed.connect(
		func():
			var username: String = %UsernameLine.text
			var password: String = %PasswordLine.text
			on_login_button_pressed.emit({
				"username":username, "password":password
			})
	)
