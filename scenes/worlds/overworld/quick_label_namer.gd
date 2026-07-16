@tool
extends Label


var _last_text: String = ""

func _process(_delta):
	if text != _last_text:
		_last_text = text
		_on_text_changed(text)


func _on_text_changed(new_text: String):
	name = "Label" + new_text.capitalize().strip_edges().replace(" ", "")
