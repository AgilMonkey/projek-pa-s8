class_name PanelIsiKelas
extends PanelContainer


@onready var close_button: TextureButton = %CloseButton

@onready var lihat_konsep_button: Button = %LihatKonsepButton
@onready var lokasi_kelas_button: Button = %LokasiKelasButton


func _ready() -> void:
	close_button.pressed.connect(queue_free)
