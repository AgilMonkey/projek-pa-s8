extends PanelContainer


@onready var close_button: TextureButton = %CloseButton


func _ready() -> void:
	close_button.pressed.connect(queue_free)
