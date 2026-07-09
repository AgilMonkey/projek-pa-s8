class_name PlayerCharacter
extends CharacterBody2D


const SPEED = 300.0

const ZOOM_SCALE := 0.2
const ZOOM_MAX := 3.0
const ZOOM_MIN := 0.5

@export var enable_movement := true

var my_username: String
var this_peer_id: int

@onready var main_camera: Camera2D = %MainCamera


func _ready() -> void:
	my_username = SessionManager.server_sessions[this_peer_id]["username"]
	set_username(my_username)
	
	if this_peer_id != multiplayer.get_unique_id():
		%MainCamera.enabled = false
	
	%PlayerEntitySyncer.this_peer_id = this_peer_id
	set_multiplayer_authority(this_peer_id)
	
	global_position = global_position
	reset_physics_interpolation()
	
	ChatManager.client_is_chatting.connect(
		func(_is_chatting): enable_movement = not _is_chatting
	)
	
	if !is_multiplayer_authority():
		$CollisionShape2D.disabled = true
	else:
		%AudioListener2D.make_current()


func _input(_event: InputEvent) -> void:
	if this_peer_id !=  multiplayer.get_unique_id(): return
	
	# Camera zoom in/out:
	if Input.is_action_just_pressed("zoom_out"):
		main_camera.zoom += main_camera.zoom * ZOOM_SCALE
	elif Input.is_action_just_pressed("zoom_in"):
		main_camera.zoom -= main_camera.zoom * ZOOM_SCALE
	main_camera.zoom = main_camera.zoom.clampf(ZOOM_MIN, ZOOM_MAX)


func _physics_process(_delta: float) -> void:
	if this_peer_id != multiplayer.get_unique_id():
		return
	
	if not enable_movement: return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()


func _process(delta: float) -> void:
	if this_peer_id != multiplayer.get_unique_id(): _multiplayer_puppet(delta)


func _multiplayer_puppet(delta):
	var target_pos = %PlayerEntitySyncer.entity_data["position"]
	global_position = global_position.lerp(target_pos, delta * 50.0)


func set_username(username):
	%UsernameLabel.text = username
