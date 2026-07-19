@tool
class_name LogOutWindow
extends SubwindowComponent


@onready var iya_button: Button = %IyaButton
@onready var tidak_button: Button = %TidakButton


func _ready() -> void:
	super._ready()
	
	iya_button.pressed.connect(iya_button_pressed)
	tidak_button.pressed.connect(_tidak_button_pressed)


func iya_button_pressed():
	UserManager.client_log_off_and_dc()
	queue_free()


func _tidak_button_pressed():
	queue_free()
