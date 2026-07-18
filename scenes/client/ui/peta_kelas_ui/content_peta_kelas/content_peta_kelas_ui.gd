class_name KontentPetaKelasUI
extends MarginContainer


signal konsep_requested(konsep_node: Control)

const PANEL_ISI_KELAS = preload("uid://c5nbia5s7cl05")

var cur_panel_isi_kelas: PanelIsiKelas
var cur_button_isi_kelas: ButtonKelas

@onready var panel_kelas_container: Control = %PanelKelasContainer

@onready var button_kelas_1: ButtonKelas = %ButtonKelas1


func _ready() -> void:
	button_kelas_1.pressed.connect(_button_kelas_1_pressed)


func _button_kelas_1_pressed():
	if cur_panel_isi_kelas != null: cur_panel_isi_kelas.queue_free()
	
	var new_panel_isi_kelas: PanelContainer = PANEL_ISI_KELAS.instantiate()
	panel_kelas_container.add_child(new_panel_isi_kelas)
	new_panel_isi_kelas.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	new_panel_isi_kelas.global_position = button_kelas_1.global_position
	new_panel_isi_kelas.global_position.x -= 100 + new_panel_isi_kelas.size.x
	cur_panel_isi_kelas = new_panel_isi_kelas
	
	cur_panel_isi_kelas.lihat_konsep_button.pressed.connect(
		_panel_isi_kelas_lihat_konsep_pressed
	)


func _panel_isi_kelas_lihat_konsep_pressed():
	konsep_requested.emit(button_kelas_1.konsep_kelas.instantiate())
