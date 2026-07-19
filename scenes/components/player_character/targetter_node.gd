class_name TargetterNode
extends Node2D


var target_pos: Vector2


func _ready() -> void:
	TargetingManager.start_targetting.connect(_start_targetting)
	TargetingManager.stop_targetting.connect(_stop_targetting)


func _process(_delta: float) -> void:
	visible = TargetingManager.is_targetting
	if !TargetingManager.is_targetting: return
	
	for w in TargetingManager.cur_target:
		if w.nama_dunia == WorldManager.client_cur_world_name:
			target_pos = w.lokasi_target
			break
	look_at(target_pos)


func _start_targetting():
	pass


func _stop_targetting():
	pass
