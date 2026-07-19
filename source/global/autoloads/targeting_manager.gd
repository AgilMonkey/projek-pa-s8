extends Node


signal start_targetting
signal stop_targetting

var is_targetting: bool

var cur_player_client: PlayerCharacter
var cur_target: Array[TargetDunia]
var cur_kata_penyetop_target: String


func enable_targeting():
	is_targetting = true
	start_targetting.emit()


func dissable_targetting():
	is_targetting = false
	stop_targetting.emit()


func emit_kata_penyetop_target(_kata_penyetop: String):
	if _kata_penyetop == cur_kata_penyetop_target:
		dissable_targetting()


func force_stop_targetting():
	dissable_targetting()
