extends Control


var list_pertanyaan := [
	{
		"pertanyaan": "I am jealous",
		"jawaban": "saya cemburu"
	},
	{
		"pertanyaan": "I am sad",
		"jawaban": "saya sedih"
	},
]

var list_nomor_pertanyaan_terjawab_benar: Array[int]

var cur_pertanyaan_count := 0
var cur_pertanyaan := ""
var cur_jawaban := ""

var is_pertanyaan_terjawab := false

@onready var menjawab_pertanyaan_ui: VBoxContainer = %MenjawabPertanyaanUI
@onready var progress_pertanyaan: CustomTextProgressBar = %ProgressPertanyaan
@onready var exit_button: Button = %ExitButton
@onready var question_number_label: RichTextLabel = %QuestionNumberLabel
@onready var question_text: RichTextLabel = %QuestionText
@onready var jawaban_line_edit: LineEdit = %JawabanLineEdit
@onready var jawab_button: Button = %JawabButton

@onready var hasil_pertanyaan: PanelContainer = %HasilPertanyaan
@onready var label_hasil_pertanyaan: RichTextLabel = %LabelHasilPertanyaan
@onready var button_pertanyaan_selanjutnya: Button = %ButtonPertanyaanSelanjutnya

@onready var selesai_menjawab_ui: VBoxContainer = %SelesaiMenjawabUI
@onready var hasil_selesai_menjawab_label: RichTextLabel = %HasilSelesaiMenjawabLabel
@onready var selesai_menjawab_keluar_button: Button = %SelesaiMenjawabKeluarButton


func _ready() -> void:
	jawab_button.pressed.connect(_jawab_pertanyaan)
	button_pertanyaan_selanjutnya.pressed.connect(_pertanyaan_selanjutnya)
	
	_mulai_pertanyaan()


func _mulai_pertanyaan():
	is_pertanyaan_terjawab = false
	cur_pertanyaan_count = -1
	
	_pertanyaan_selanjutnya()


func _pertanyaan_selanjutnya():
	is_pertanyaan_terjawab = false
	
	hasil_pertanyaan.hide()
	jawaban_line_edit.clear()
	
	cur_pertanyaan_count += 1
	if cur_pertanyaan_count > len(list_pertanyaan) - 1:
		_selesai_menjawab_semua_pertanyaan()
		return
	
	var pertanyaan: Dictionary = list_pertanyaan[cur_pertanyaan_count]
	cur_pertanyaan = pertanyaan["pertanyaan"]
	cur_jawaban = pertanyaan["jawaban"]
	_set_pertanyaan(pertanyaan)
	
	progress_pertanyaan.label_progress_bar.text = "%d/%d" % [cur_pertanyaan_count, len(list_pertanyaan)]
	progress_pertanyaan.progress_bar.max_value = len(list_pertanyaan)
	progress_pertanyaan.progress_bar.value = cur_pertanyaan_count


func _set_pertanyaan(pertanyaan: Dictionary):
	question_number_label.text = "Pertanyaan %d" % (cur_pertanyaan_count + 1)
	question_text.text = pertanyaan["pertanyaan"]


func _selesai_menjawab_semua_pertanyaan():
	menjawab_pertanyaan_ui.hide()
	
	hasil_selesai_menjawab_label.text = "Berhasil menjawab %d/%d pertanyaan" % [
		len(list_nomor_pertanyaan_terjawab_benar),
		len(list_pertanyaan)
		]
	if (len(list_nomor_pertanyaan_terjawab_benar) - len(list_pertanyaan)) != 0:
		hasil_selesai_menjawab_label.text += "\nYou can do better little kitty"
	else:
		hasil_selesai_menjawab_label.text += "\nGood boy"
	selesai_menjawab_ui.show()


func _jawab_pertanyaan():
	if cur_pertanyaan.is_empty() or cur_jawaban.is_empty() or is_pertanyaan_terjawab: return
	
	var text_jawaban = jawaban_line_edit.text.to_lower().strip_edges()
	var regex = RegEx.new()
	regex.compile(" +")  # Remove extra space in middle of text
	var clean_text_jawaban := regex.sub(text_jawaban, " ", true)
	
	if cur_jawaban == clean_text_jawaban:
		_jawaban_benar()
	else:
		_jawaban_salah()
	
	is_pertanyaan_terjawab = true


func _jawaban_benar():
	list_nomor_pertanyaan_terjawab_benar.append(cur_pertanyaan_count)
	
	hasil_pertanyaan.show()
	label_hasil_pertanyaan.text = "[color=green]Jawaban benar![/color]"


func _jawaban_salah():
	hasil_pertanyaan.show()
	label_hasil_pertanyaan.text = "[color=red]Jawaban salah![/color]"
