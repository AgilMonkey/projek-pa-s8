class_name ContainerLeaderboardCell
extends PanelContainer


var username: String
var total_point: int

@onready var label_nama: RichTextLabel = %LabelNama
@onready var label_total_skor: RichTextLabel = %LabelTotalSkor


func _ready() -> void:
	label_nama.text = username
	label_total_skor.text = str(total_point)
