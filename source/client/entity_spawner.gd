class_name EntitySpawner
extends Node2D


const PLAYER_CHARACTER = preload("uid://ckvoywghnvtgb")

var entities_data := {}
var spawned_player_entities := {}

func _ready() -> void:
	EntityManager.client_cur_entity_spawner = self
	entities_data = WorldManager.client_cur_world_data
	
	WorldManager.world_entites_data_updated.connect(_data_update)


func _data_update():
	entities_data = WorldManager.client_cur_world_data
	_spawn_all_player_entities()


func _spawn_all_player_entities():
	var _unspawned_entities := spawned_player_entities.duplicate()  # Basically left overs
	
	for player_data in entities_data[WorldManager.client_cur_world_name].values():
		var p_id = player_data["peer_id"]
		var p_pos = player_data["position"]
		
		_unspawned_entities.erase(p_id)
		
		if spawned_player_entities.has(p_id):
			continue
		
		var p_ent: PlayerCharacter = PLAYER_CHARACTER.instantiate()
		p_ent.name = "player_" + str(p_id)
		p_ent.this_peer_id = p_id
		p_ent.global_position = p_pos
		add_child(p_ent, true)
		p_ent.reset_physics_interpolation()
		
		spawned_player_entities[p_id] = p_ent
	
	for _ent in _unspawned_entities:
		_unspawn_this_player_entity(_ent)


func _unspawn_this_player_entity(peer_id: int):
	var p_ent: Node2D = spawned_player_entities[peer_id]
	p_ent.call_deferred("queue_free")
	spawned_player_entities.erase(peer_id)
