extends CharacterBody2D


const ZOOM_SCALE := 0.2
const ZOOM_MAX := 3.0
const ZOOM_MIN := 0.5

@export var SPEED = 300.0

var my_username: String
var this_peer_id: int

@onready var main_camera: Camera2D = %MainCamera


func _input(_event: InputEvent) -> void:
	# Camera zoom in/out:
	if Input.is_action_just_pressed("zoom_out"):
		main_camera.zoom += main_camera.zoom * ZOOM_SCALE
	elif Input.is_action_just_pressed("zoom_in"):
		main_camera.zoom -= main_camera.zoom * ZOOM_SCALE
	main_camera.zoom = main_camera.zoom.clampf(ZOOM_MIN, ZOOM_MAX)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
