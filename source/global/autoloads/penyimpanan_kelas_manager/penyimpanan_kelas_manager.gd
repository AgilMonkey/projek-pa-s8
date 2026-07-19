## Ngurus saving/loading/getting/setting buat data kelas klien
extends Node


var cur_penyimpanan_data_kelas := {
	"course_0_1": DataPenyimpananKelas.new(
		preload("uid://bftacsjn6ivgg"),
		true,
		0
	),
	"course_0_2": DataPenyimpananKelas.new(
		preload("uid://bumocx4pxhvfg"),
		false,
		0
	)
}


func _ready() -> void:
	CourseManager.kelas_selesai.connect(_kelas_selesai)


func cek_unlock_kelas(_nama_kelas: String) -> bool:
	if cur_penyimpanan_data_kelas.has(_nama_kelas):
		var data: DataPenyimpananKelas = cur_penyimpanan_data_kelas[_nama_kelas]
		return data.unlocked
	return false


func unlock_kelas(_nama_kelas: String):
	if cur_penyimpanan_data_kelas.has(_nama_kelas):
		var data: DataPenyimpananKelas = cur_penyimpanan_data_kelas[_nama_kelas]
		data.unlocked = true


func tambah_coba_kelas(_nama_kelas: String):
	if cur_penyimpanan_data_kelas.has(_nama_kelas):
		var data: DataPenyimpananKelas = cur_penyimpanan_data_kelas[_nama_kelas]
		data.kelas_dicoba_count += 1


func _kelas_selesai(nama_kelas: String, nama_kelas_unlock: String):
	print("KELAS SELESAI BOII")
	tambah_coba_kelas(nama_kelas)
	unlock_kelas(nama_kelas_unlock)


class DataPenyimpananKelas:
	var course_res: CourseResource
	var unlocked: bool
	var kelas_dicoba_count: int
	
	func _init(_res: CourseResource, _unlocked: bool, _kelas_dicoba_count: int = 0) -> void:
		course_res = _res
		unlocked = _unlocked
		kelas_dicoba_count = _kelas_dicoba_count
