@tool
class_name SpeechBubble
extends PanelContainer


@export var speech_text := ""


@onready var bubble_text_label: RichTextLabel = %BubbleTextLabel


func _process(delta: float) -> void:
	bubble_text_label.text = speech_text
