class_name SpeechSpawner
extends Node2D


const max_speech_bubble_count := 4
const SPEECH_BUBBLE = preload("uid://b8t8ny7b5y68k")

@onready var bubble_container: VBoxContainer = %BubbleContainer


func _ready() -> void:
	ChatManager.on_new_msg_by_who.connect(_chat_manager_on_new_msg_by_who)


func _chat_manager_on_new_msg_by_who(_peer_id: int, _msg: String):
	if get_multiplayer_authority() == _peer_id:
		_spawn_speech_bubble(_msg)


func _spawn_speech_bubble(_msg: String):
	if bubble_container.get_child_count() >= max_speech_bubble_count:
		bubble_container.get_child(0).queue_free()
	
	var bubble: SpeechBubble = SPEECH_BUBBLE.instantiate()
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bubble.speech_text = _msg
	bubble_container.add_child(bubble)
	_bubble_anim(bubble)


func _bubble_anim(_bubble: SpeechBubble):
	var tween := create_tween()
	_bubble.offset_transform_enabled = true
	_bubble.modulate.a = 0.0
	tween.tween_property(_bubble, "modulate:a", 1.0, 0.2)
	tween.tween_interval(5.0)
	tween.tween_property(_bubble, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_bubble.call_deferred.bind("queue_free"))
