@tool
class_name SubwindowNotice
extends SubwindowComponent


@export_multiline var window_text := "":
	set(_text):
		window_text = _text
		if content_text_label != null: content_text_label.text = window_text


@onready var content_text_label: RichTextLabel = %ContentTextLabel
@onready var okay_button: Button = %OkayButton


func _ready() -> void:
	super()
	content_text_label.text = window_text
	okay_button.pressed.connect(queue_free)
