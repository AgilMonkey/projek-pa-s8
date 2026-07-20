@tool
class_name QuizWindow
extends SubwindowComponent


@onready var iya_button: Button = %IyaButton
@onready var tidak_button: Button = %TidakButton


func _ready() -> void:
	super._ready()
	
	iya_button.pressed.connect(iya_button_pressed)
	tidak_button.pressed.connect(_tidak_button_pressed)


func iya_button_pressed():
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLScf0H6u1CEdrXTlw58IVdVm0w6oIlyVq2Qaj2V5lOAM9HS39g/viewform?usp=dialog")
	queue_free()


func _tidak_button_pressed():
	queue_free()
