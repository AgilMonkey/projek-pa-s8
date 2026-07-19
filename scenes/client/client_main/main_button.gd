extends Control


@onready var peta_kelas_button: Button = %PetaKelasButton
@onready var cancel_target_lokasi_button: Button = %CancelTargetLokasiButton

@onready var peta_kelas_ui: Control = %PetaKelasUi


func _ready() -> void:
	peta_kelas_button.pressed.connect(_peta_kelas_button_pressed)
	cancel_target_lokasi_button.pressed.connect(_cancel_target_lokasi_button_pressed)
	
	TargetingManager.start_targetting.connect(cancel_target_lokasi_button.show)
	TargetingManager.stop_targetting.connect(cancel_target_lokasi_button.hide)


func _peta_kelas_button_pressed():
	peta_kelas_ui.show()


func _cancel_target_lokasi_button_pressed():
	TargetingManager.force_stop_targetting()
	cancel_target_lokasi_button.hide()
