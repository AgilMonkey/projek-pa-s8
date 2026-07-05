extends Node


const TEST_WORLD = "test_world"
const TEST_WORLD_2 = "test_world_2"
const TEST_WORLD_3 = "test_world_3"

var worlds := {
	TEST_WORLD: preload("uid://pib3xwojg88o"),
	TEST_WORLD_2: preload("uid://muhp4y16ej8f"),
	TEST_WORLD_3: preload("uid://h6rw77bewpo2"),
}


func is_valid_world_name(name: String) -> bool:
	return worlds.has(name)


func get_world_scene(name: String) -> PackedScene:
	return worlds[name]
