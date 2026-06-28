class_name StartMenuUI
extends Control


signal start_button_pressed

@onready var connecting_panel: PanelContainer = %ConnectingPanel


func _ready() -> void:
	%StartButton.pressed.connect( func(): start_button_pressed.emit() )
