class_name KosakataStuff
extends RefCounted


const KOSAKATA_PATH = "res://source/global/other/kosakata_stuff/kosakata.txt"

var kosa_kata := []


func _init() -> void:
	muat_kata(KOSAKATA_PATH)


func muat_kata(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Gagal buka file: " + path)
		return
	var isi = file.get_as_text()
	file.close()
	# split per baris, "false" = buang baris kosong
	kosa_kata = isi.split("\n", false)


func random_kata_kata(size: int) -> Array[String]:
	var hasil: Array[String] = []
	if size <= 0 or kosa_kata.is_empty():
		return hasil
	var salinan := kosa_kata.duplicate()  # jangan acak array aslinya
	salinan.shuffle()
	print(salinan.slice(0, mini(size, salinan.size())))
	return salinan.slice(0, mini(size, salinan.size()))
