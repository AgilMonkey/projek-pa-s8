class_name ClientCourseUI
extends Control


@onready var exit_button: Button = %ExitButton
@onready var question_number_label: RichTextLabel = %QuestionNumberLabel
@onready var question_text: RichTextLabel = %QuestionText
@onready var progress_pertanyaan: CustomTextProgressBar = %ProgressPertanyaan


func _update_ui_pertanyaan_baru(_cur_nomor_pertanyaan: int, _total_nomor_pertanyaan: int, _pertanyaan: String):
	question_number_label.text = "Pertanyaan %d" % (_cur_nomor_pertanyaan + 1)
	progress_pertanyaan.progress_bar.max_value = _total_nomor_pertanyaan
	progress_pertanyaan.progress_bar.value = _cur_nomor_pertanyaan
	progress_pertanyaan.label_progress_bar.text = "%d/%d" % [_cur_nomor_pertanyaan, _total_nomor_pertanyaan]
	question_text.text = _pertanyaan
