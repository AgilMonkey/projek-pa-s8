@icon("res://addons/at-icons/node2d/gate.svg")
class_name CourseDoor
extends Node2D


const COURSE_MENU = preload("uid://bgr108nc2ql5u")

@export var course_resource: CourseResource

var _course_win: CourseMenu
var _cur_win: SubwindowComponent

@onready var begin_course_area: Area2D = $BeginCourseArea


func _ready() -> void:
	begin_course_area.body_entered.connect(
		func(_body):
			if _cur_win != null: return
			_course_win = COURSE_MENU.instantiate()
			_cur_win = MainGameWindowManager.create_subwindow_with_control(_course_win)
			_cur_win.on_closed.connect(func(): _cur_win = null)
			
			_course_win.main_text.text = """[center][font_size=32][b]Course Test[/b][/font_size]\nSome kinda test. Have some example questions[/center]"""
			_course_win.start_button.pressed.connect(
				func():
					_cur_win.queue_free()
					CourseManager.client_enter_course(_body.global_position, course_resource)
					)
			
	)
