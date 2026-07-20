extends Control


const LOG_OUT_WINDOW = preload("uid://dm0kdjwa6n1a6")

var cur_log_out_window: LogOutWindow


@onready var log_out_button: Button = %LogOutButton
@onready var peta_kelas_button: Button = %PetaKelasButton
@onready var cancel_target_lokasi_button: Button = %CancelTargetLokasiButton

@onready var label_stats: RichTextLabel = %LabelStats
@onready var peta_kelas_ui: Control = %PetaKelasUi


func _ready() -> void:
	peta_kelas_button.pressed.connect(_peta_kelas_button_pressed)
	cancel_target_lokasi_button.pressed.connect(_cancel_target_lokasi_button_pressed)
	log_out_button.pressed.connect(_log_out_button_pressed)
	
	TargetingManager.start_targetting.connect(cancel_target_lokasi_button.show)
	TargetingManager.stop_targetting.connect(cancel_target_lokasi_button.hide)
	
	visibility_changed.connect(_visibility_changed)
	PointManager.point_updated.connect(_point_updated)


func _peta_kelas_button_pressed():
	peta_kelas_ui.show()


func _cancel_target_lokasi_button_pressed():
	TargetingManager.force_stop_targetting()
	cancel_target_lokasi_button.hide()


func _log_out_button_pressed():
	if cur_log_out_window != null: return
	cur_log_out_window = MainGameWindowManager.spawn_subwindow_scene(LOG_OUT_WINDOW)


func _visibility_changed():
	if is_visible_in_tree():
		label_stats.text = "Username: " + UserManager.client_cur_username
		label_stats.text += "\nPoint: " + str(PointManager.cur_point)


func _point_updated(_point):
	label_stats.text = "Username: " + UserManager.client_cur_username
	label_stats.text += "\nPoint: " + str(_point)
