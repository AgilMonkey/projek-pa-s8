class_name SpeechSpawner
extends Node2D


const SPEECH_BUBBLE = preload("uid://b8t8ny7b5y68k")

@onready var bubble_container: VBoxContainer = %BubbleContainer


func _ready() -> void:
	ChatManager.on_new_msg_by_who.connect(_chat_manager_on_new_msg_by_who)


func _chat_manager_on_new_msg_by_who(_peer_id: int, _msg: String):
	if get_multiplayer_authority() == _peer_id:
		_spawn_speech_bubble(_msg)


func _spawn_speech_bubble(_msg: String):
	var bubble: SpeechBubble = SPEECH_BUBBLE.instantiate()
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bubble.speech_text = _msg
	bubble_container.add_child(bubble)
	_bubble_anim(bubble)


func _bubble_anim(_bubble: SpeechBubble):
	pass
