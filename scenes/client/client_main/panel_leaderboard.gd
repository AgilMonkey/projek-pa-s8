class_name PanelLeaderboard
extends PanelContainer


const CONTAINER_LEADERBOARD_CELL = preload("uid://c6851bfidi41t")

@onready var leaderboard_exit_button: TextureButton = %LeaderboardExitButton
@onready var container_leaderboard_cell: VBoxContainer = %ContainerLeaderboardCell


func _ready() -> void:
	leaderboard_exit_button.pressed.connect(hide)
	visibility_changed.connect(_visibility_changed)


func _visibility_changed():
	if is_visible_in_tree():
		for n in container_leaderboard_cell.get_children():
			n.queue_free()
		
		PointManager.get_leaderboard_data.rpc_id(1)
		var leaderboard_data = await PointManager.got_leaderboard_data
		for data in leaderboard_data:
			var username = data["username"]
			var total_point = data["total_point"]
			
			var cell: ContainerLeaderboardCell = CONTAINER_LEADERBOARD_CELL.instantiate()
			cell.username = username
			cell.total_point = total_point
			container_leaderboard_cell.add_child(cell)
