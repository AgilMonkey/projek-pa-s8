extends Area2D


func _ready() -> void:
	body_entered.connect(_body_entered)


func _body_entered(body):
	TargetingManager.emit_kata_penyetop_target("stop_targeting_kelas_1")
