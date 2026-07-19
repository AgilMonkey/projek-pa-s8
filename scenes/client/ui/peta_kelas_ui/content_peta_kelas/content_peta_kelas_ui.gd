class_name KontentPetaKelasUI
extends MarginContainer


signal konsep_requested(konsep_node: Control)
signal locate_lokasi_kelas(_button: ButtonKelas)

const PANEL_ISI_KELAS = preload("uid://c5nbia5s7cl05")

const KONSEL_KELAS_YOU_FUCK_UP = preload("uid://qpaek0e46qb8")

var cur_panel_isi_kelas: PanelIsiKelas
var cur_button_isi_kelas: ButtonKelas

@onready var panel_kelas_container: Control = %PanelKelasContainer

@onready var kelas_container: VBoxContainer = %KelasContainer


func _ready() -> void:
	for control in kelas_container.get_children():
		if control is ButtonKelas:
			control.pressed.connect(
				_spawn_new_panel_isi_kelas.bind(control)
			)
	
	visibility_changed.connect(_on_visibility_changed)


func _spawn_new_panel_isi_kelas(_button: ButtonKelas):
	if cur_panel_isi_kelas != null: cur_panel_isi_kelas.queue_free()
	
	var new_panel_isi_kelas: PanelContainer = PANEL_ISI_KELAS.instantiate()
	panel_kelas_container.add_child(new_panel_isi_kelas)
	new_panel_isi_kelas.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	new_panel_isi_kelas.global_position = _button.global_position
	new_panel_isi_kelas.global_position.x -= 100 + new_panel_isi_kelas.size.x
	cur_panel_isi_kelas = new_panel_isi_kelas
	
	cur_panel_isi_kelas.lihat_konsep_button.pressed.connect(
		_panel_isi_kelas_lihat_konsep_pressed.bind(_button)
	)
	
	cur_panel_isi_kelas.lokasi_kelas_button.pressed.connect(
		_panel_isi_kelas_lokasi_kelas_button_pressed.bind(_button)
	)


func _panel_isi_kelas_lihat_konsep_pressed(_button: ButtonKelas):
	if _button.konsep_kelas == null:
		konsep_requested.emit(KONSEL_KELAS_YOU_FUCK_UP.instantiate())
		return
	
	konsep_requested.emit(_button.konsep_kelas.instantiate())


func _panel_isi_kelas_lokasi_kelas_button_pressed(_button: ButtonKelas):
	locate_lokasi_kelas.emit(_button)



func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_set_up_buttons()


func _set_up_buttons():
	for n in kelas_container.get_children():
		if n is ButtonKelas:
			n.set_up()
