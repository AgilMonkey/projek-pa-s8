class_name ClientCourseUI
extends Control


@onready var menjawab_pertanyaan_ui: MenjawabPertanyaanUI = %MenjawabPertanyaanUI
@onready var exit_button: Button = %ExitButton
@onready var question_number_label: RichTextLabel = %QuestionNumberLabel
@onready var question_text: RichTextLabel = %QuestionText
@onready var progress_pertanyaan: CustomTextProgressBar = %ProgressPertanyaan

@onready var jawaban_line_edit: LineEdit
@onready var jawab_button: Button = %JawabButton

@onready var selesai_menjawab_ui: VBoxContainer = %SelesaiMenjawabUI
@onready var hasil_selesai_menjawab_label: RichTextLabel = %HasilSelesaiMenjawabLabel
@onready var selesai_menjawab_keluar_button: Button = %SelesaiMenjawabKeluarButton


@onready var hasil_pertanyaan: PanelContainer = %HasilPertanyaan
@onready var label_hasil_pertanyaan: RichTextLabel = %LabelHasilPertanyaan
@onready var button_pertanyaan_selanjutnya: Button = %ButtonPertanyaanSelanjutnya


func _ready() -> void:
	jawab_button.pressed.connect(_cek_jawaban)
	CourseManager.course_data_updated.connect(
		func():
			menjawab_pertanyaan_ui.mouse_filter = MouseFilter.MOUSE_FILTER_PASS
			update_ui_pertanyaan_baru()
	)


func update_ui_pertanyaan_baru():
	var _cur_nomor_pertanyaan := CourseManager.client_cur_question_count
	var _total_nomor_pertanyaan := CourseManager.client_total_question
	var _pertanyaan := CourseManager.client_cur_question
	var _jawaban := CourseManager.client_cur_answer
	
	hasil_pertanyaan.hide()
	
	question_number_label.text = "Pertanyaan %d" % (_cur_nomor_pertanyaan + 1)
	progress_pertanyaan.progress_bar.max_value = _total_nomor_pertanyaan
	progress_pertanyaan.progress_bar.value = _cur_nomor_pertanyaan
	progress_pertanyaan.label_progress_bar.text = "%d/%d" % [_cur_nomor_pertanyaan, _total_nomor_pertanyaan]
	question_text.text = _pertanyaan
	
	var split_jawaban := _jawaban.split(" ")
	var random_kata = CourseManager.kosakata_stuff.random_kata_kata(3)
	split_jawaban.append_array(PackedStringArray(random_kata))
	var new_jawaban_text: Array[String] = []
	new_jawaban_text.assign(Array(split_jawaban))
	new_jawaban_text.shuffle()
	menjawab_pertanyaan_ui.set_up_kosakata(new_jawaban_text)


func tunjukan_hasil_pertanyaan(sukses: bool):
	hasil_pertanyaan.show()
	label_hasil_pertanyaan.text = "[color=green]Jawaban benar!" if sukses else "[color=red]Jawaban salah!"
	button_pertanyaan_selanjutnya.pressed.connect(
		_pertanyaan_selanjutnya,
		ConnectFlags.CONNECT_ONE_SHOT
	)


func _pertanyaan_selanjutnya():
	if CourseManager.is_pertanyaan_habis:
		_pertanyaan_habis()
		return
	
	CourseManager._ask_server_for_next_question.rpc_id(
		1,
		CourseManager.client_course_name,
		CourseManager.client_course_id
	)


func _pertanyaan_habis():
	hasil_pertanyaan.hide()
	menjawab_pertanyaan_ui.hide()
	selesai_menjawab_ui.show()
	
	hasil_selesai_menjawab_label.text = "Berhasil menjawab %d/%d\n" %[CourseManager.client_jawaban_benar.size(), CourseManager.client_total_question]
	selesai_menjawab_keluar_button.pressed.connect(
		_selesai_menjawab_keluar_button_pressed
		, ConnectFlags.CONNECT_ONE_SHOT
	)
	
	var point_didapat = _kalkulasi_point()
	PointManager.add_point(point_didapat)
	hasil_selesai_menjawab_label.text += "Anda mendapatakan %d point." % point_didapat
	
	CourseManager.emit_kelas_selesai()


func _kalkulasi_point() -> int:
	var is_first_time: bool = PenyimpananKelasManager.cur_penyimpanan_data_kelas[
		CourseManager.client_course_name].kelas_dicoba_count < 1
	return CourseManager.client_jawaban_benar.size() + (20 * int(is_first_time))


func _selesai_menjawab_keluar_button_pressed():
	CourseManager._client_exit_this_course()
	selesai_menjawab_ui.hide()
	menjawab_pertanyaan_ui.show()


func _cek_jawaban():
	menjawab_pertanyaan_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var _text_jawaban: String = menjawab_pertanyaan_ui.full_text_jawaban
	var regex = RegEx.new()
	regex.compile(" +")  # Remove extra space in middle of text
	var _clean_text_jawaban := regex.sub(_text_jawaban, " ", true)
	
	if CourseManager.client_cek_jawaban(_clean_text_jawaban):
		tunjukan_hasil_pertanyaan(true)
	else:
		tunjukan_hasil_pertanyaan(false)
