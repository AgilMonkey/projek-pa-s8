class_name ButtonKelas
extends Button


const LOCK_TEXTURE = preload("uid://cfgnol3w7gyq8")


const LINE_ENABLED_COLOR = Color.WHITE
const LINE_DISABLED_COLOR = Color(1, 1, 1, 0.5)


var lock_tex: TextureRect

@export var nama_course_ini: String
@export var konsep_kelas: PackedScene
@export var target: Array[TargetDunia]
@export var kata_penyetop_target: String

@export var line_control: LineControl


func _ready() -> void:
	lock_tex = LOCK_TEXTURE.instantiate()
	add_child(lock_tex)
	lock_tex.hide()


func set_up() -> void:
	if line_control == null: return
	if nama_course_ini.is_empty(): return
	
	if PenyimpananKelasManager.cek_unlock_kelas(nama_course_ini):
		disabled = false
		line_control.modulate = LINE_ENABLED_COLOR
		lock_tex.hide()
	else:
		disabled = true
		line_control.modulate = LINE_DISABLED_COLOR
		lock_tex.show()
