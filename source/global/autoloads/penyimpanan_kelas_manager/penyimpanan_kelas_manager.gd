## Ngurus saving/loading/getting/setting buat data kelas klien
extends Node


signal on_save_data_kelas

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
	UserManager.client_logged_in.connect(_load_data_dari_database)
	
	UserManager.on_before_log_off.connect(save_data_kelas_ke_server)
	CourseManager.kelas_selesai.connect(func(_a,_b): save_data_kelas_ke_server())
	multiplayer.server_disconnected.connect(save_data_kelas_ke_server)
	on_save_data_kelas.connect(save_data_kelas_ke_server)


func _load_data_dari_database(_result, _data):
	UserManager.minta_data_kelas_ke_server.rpc_id(1, UserManager.client_cur_username)
	var data: Dictionary = await UserManager.on_dapat_data_kelas
	apply_save_dict(data)


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


func save_data_kelas_ke_server():
	var peer := multiplayer.multiplayer_peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED: return
	
	var data_dict := to_save_dict()
	
	UserManager.save_data_kelas_to_database.rpc_id(
		1,
		UserManager.client_cur_username,
		data_dict
	)


func emit_save_data_kelas():
	on_save_data_kelas.emit()


func _kelas_selesai(nama_kelas: String, nama_kelas_unlock: String):
	tambah_coba_kelas(nama_kelas)
	unlock_kelas(nama_kelas_unlock)


func to_save_dict() -> Dictionary:
	var out := {}
	for key in cur_penyimpanan_data_kelas:
		var d: DataPenyimpananKelas = cur_penyimpanan_data_kelas[key]
		out[key] = {
			"unlocked": d.unlocked,
			"count": d.kelas_dicoba_count,
		}
	return out


func apply_save_dict(saved: Dictionary) -> void:
	for key in cur_penyimpanan_data_kelas:          # loop the CODE definitions
		var s = saved.get(key)
		if s == null:
			continue                                 # new course, keep defaults
		var d: DataPenyimpananKelas = cur_penyimpanan_data_kelas[key]
		d.unlocked = s.get("unlocked", d.unlocked)
		d.kelas_dicoba_count = s.get("count", d.kelas_dicoba_count)


class DataPenyimpananKelas:
	var course_res: CourseResource
	var unlocked: bool
	var kelas_dicoba_count: int
	
	func _init(_res: CourseResource, _unlocked: bool, _kelas_dicoba_count: int = 0) -> void:
		course_res = _res
		unlocked = _unlocked
		kelas_dicoba_count = _kelas_dicoba_count
