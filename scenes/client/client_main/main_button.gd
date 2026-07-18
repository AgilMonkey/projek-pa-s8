extends Control


@onready var peta_kelas_button: Button = %PetaKelasButton

@onready var peta_kelas_ui: Control = %PetaKelasUi


func _ready() -> void:
	peta_kelas_button.pressed.connect(_peta_kelas_button_pressed)


func _peta_kelas_button_pressed():
	peta_kelas_ui.show()
