extends Control


@onready var exit_button: TextureButton = %ExitButton


func _ready() -> void:
	exit_button.pressed.connect(_exit_button_pressed)


func _exit_button_pressed():
	hide()
