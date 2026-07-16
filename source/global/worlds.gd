extends Node


const TEST_WORLD = "test_world"
const TEST_WORLD_2 = "test_world_2"
const TEST_WORLD_3 = "test_world_3"
const OVERWORLD = "overworld"
const WORLD_GEDUNG_PUSAT_POLIBAN = "world_gedung_pusat_poliban"

var worlds := {
	TEST_WORLD: preload("uid://pib3xwojg88o"),
	TEST_WORLD_2: preload("uid://muhp4y16ej8f"),
	TEST_WORLD_3: preload("uid://h6rw77bewpo2"),
	OVERWORLD: preload("uid://c1or0obp0uegg"),
	WORLD_GEDUNG_PUSAT_POLIBAN: preload("uid://c4cn1cmc53r2"),
	}


func is_valid_world_name(world_name: String) -> bool:
	return worlds.has(world_name)


func get_world_scene(world_name: String) -> PackedScene:
	return worlds[world_name]


#func get_world_name_from_all_worlds(world: AllWorlds):
	#return 
