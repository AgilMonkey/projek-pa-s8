class_name CourseMenu
extends PanelContainer


@onready var main_text: RichTextLabel = %MainText
@onready var start_button: Button = %StartButton
@onready var belajar_konsep_button: Button = %BelajarKonsepButton
@onready var lock_panel: PanelContainer = %LockPanel


func lock_lock_panel(lock: bool):
	lock_panel.visible = lock


func set_main_text(_body_text: String):
	main_text.text = _body_text
