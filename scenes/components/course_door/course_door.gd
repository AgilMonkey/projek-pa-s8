@icon("res://addons/at-icons/node2d/gate.svg")
class_name CourseDoor
extends Node2D


const KONSEL_KELAS_YOU_FUCK_UP = preload("uid://qpaek0e46qb8")
const COURSE_MENU = preload("uid://bgr108nc2ql5u")

@export var nama_course: String
@export var world_button: WorldInteractButton
@export_multiline() var text_pelajaran: String
@export var course_resource: CourseResource
@export var scene_konsepnya: PackedScene
@export var kata_stop_targetting: String
@export var nama_course_selanjutnya: String

var _course_win: CourseMenu
var _cur_win: SubwindowComponent


func _ready() -> void:
	world_button.button_pressed.connect(_world_button_button_pressed)


func _world_button_button_pressed():
	if _cur_win != null: return
	_course_win = COURSE_MENU.instantiate()
	_cur_win = MainGameWindowManager.create_subwindow_with_control(_course_win)
	_cur_win.title_text = "Kelas"
	_cur_win.on_closed.connect(func(): _cur_win = null)
	
	_course_win.set_main_text(text_pelajaran)
	_course_win.start_button.pressed.connect(
		func():
			_cur_win.queue_free()
			CourseManager.client_enter_course(global_position, course_resource)
			CourseManager.client_next_kelas_unlock_name = nama_course_selanjutnya
			)
	
	_course_win.belajar_konsep_button.pressed.connect(
		func():
			if scene_konsepnya == null:
				ClientManager.emit_tunjukkan_konsep(KONSEL_KELAS_YOU_FUCK_UP)
				return
			ClientManager.emit_tunjukkan_konsep(scene_konsepnya)
	)
	
	TargetingManager.emit_kata_penyetop_target(kata_stop_targetting)
	
	if PenyimpananKelasManager.cek_unlock_kelas(nama_course):
		_course_win.lock_lock_panel(false)
	else: _course_win.lock_lock_panel(true)
