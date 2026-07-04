class_name PlayerCharacter
extends CharacterBody2D


const SPEED = 300.0

var my_username: String
var this_peer_id: int


func _ready() -> void:
	my_username = SessionManager.server_sessions[this_peer_id]["username"]
	set_username(my_username)
	
	if this_peer_id != multiplayer.get_unique_id():
		%MainCamera.enabled = false
	
	%PlayerEntitySyncer.this_peer_id = this_peer_id
	
	global_position = global_position
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if this_peer_id != multiplayer.get_unique_id():
		return
	
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
