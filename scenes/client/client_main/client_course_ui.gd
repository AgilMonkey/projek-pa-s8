class_name ClientCourseUI
extends Control


@onready var exit_button: Button = %ExitButton
@onready var question_number_label: RichTextLabel = %QuestionNumberLabel
@onready var question_text: RichTextLabel = %QuestionText
@onready var progress_pertanyaan: CustomTextProgressBar = %ProgressPertanyaan

@onready var jawaban_line_edit: LineEdit = %JawabanLineEdit
@onready var jawab_button: Button = %JawabButton

@onready var hasil_pertanyaan: PanelContainer = %HasilPertanyaan
@onready var label_hasil_pertanyaan: RichTextLabel = %LabelHasilPertanyaan
@onready var button_pertanyaan_selanjutnya: Button = %ButtonPertanyaanSelanjutnya

@onready var selesai_menjawab_keluar_button: Button = %SelesaiMenjawabKeluarButton


func _ready() -> void:
	jawab_button.pressed.connect(_cek_jawaban)
	CourseManager.course_data_updated.connect(
		func():
			update_ui_pertanyaan_baru(
				CourseManager.client_cur_question_count,
				CourseManager.client_total_question,
				CourseManager.client_cur_question
			)
	)


func update_ui_pertanyaan_baru(_cur_nomor_pertanyaan: int, _total_nomor_pertanyaan: int, _pertanyaan: String):
	hasil_pertanyaan.hide()
	
	question_number_label.text = "Pertanyaan %d" % (_cur_nomor_pertanyaan + 1)
	progress_pertanyaan.progress_bar.max_value = _total_nomor_pertanyaan
	progress_pertanyaan.progress_bar.value = _cur_nomor_pertanyaan
	progress_pertanyaan.label_progress_bar.text = "%d/%d" % [_cur_nomor_pertanyaan, _total_nomor_pertanyaan]
	question_text.text = _pertanyaan


func tunjukan_hasil_pertanyaan(sukses: bool):
	hasil_pertanyaan.show()
	label_hasil_pertanyaan.text = "[color=green]Jawaban benar!" if sukses else "[color=red]Jawaban salah!"
	button_pertanyaan_selanjutnya.pressed.connect(
		func():
			CourseManager._ask_server_for_next_question.rpc_id(
				1,
				CourseManager.client_course_name,
				CourseManager.client_course_id
			)
			, ConnectFlags.CONNECT_ONE_SHOT
	)


func _cek_jawaban():
	var text_jawaban = jawaban_line_edit.text.to_lower().strip_edges()
	var regex = RegEx.new()
	regex.compile(" +")  # Remove extra space in middle of text
	var clean_text_jawaban := regex.sub(text_jawaban, " ", true)
	
	if clean_text_jawaban == CourseManager.client_cur_answer.to_lower():
		tunjukan_hasil_pertanyaan(true)
	else:
		tunjukan_hasil_pertanyaan(false)
