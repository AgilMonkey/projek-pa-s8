@tool

class_name SubwindowText
extends SubwindowComponent


@export_multiline var window_text := "":
	set(_text):
		window_text = _text
		%ContentTextLabel.text = window_text
