extends Control


@onready var panel_konsep_2: PanelKonsep = %PanelKonsep2

@onready var leaderboard_button: Button = %LeaderboardButton
@onready var panel_leaderboard: PanelLeaderboard = %PanelLeaderboard


func _ready() -> void:
	ClientManager.tunjukkan_konsep.connect(_tunjukkan_konsep)
	leaderboard_button.pressed.connect(panel_leaderboard.show)


func _unhandled_input(event):
	# _unhandled_input only fires if no Control consumed the event first
	if event is InputEventMouseButton and event.pressed:
		get_viewport().gui_release_focus()


func _tunjukkan_konsep(_scene:PackedScene):
	panel_konsep_2.show_konsep(_scene)
