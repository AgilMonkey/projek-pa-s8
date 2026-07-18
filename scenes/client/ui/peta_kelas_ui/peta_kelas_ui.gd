extends Control


@onready var exit_button: TextureButton = %ExitButton

@onready var content_peta_kelas_ui: KontentPetaKelasUI = %ContentPetaKelasUi

@onready var panel_konsep: PanelContainer = %PanelKonsep
@onready var konsep_container: MarginContainer = %KonsepContainer


func _ready() -> void:
	exit_button.pressed.connect(_exit_button_pressed)
	content_peta_kelas_ui.konsep_requested.connect(_content_peta_kelas_ui_konsep_requested)


func _exit_button_pressed():
	hide()


func _content_peta_kelas_ui_konsep_requested(_konsep: Control):
	for n: Node in konsep_container.get_children():
		n.queue_free()
	
	konsep_container.add_child(_konsep)
	panel_konsep.show()
