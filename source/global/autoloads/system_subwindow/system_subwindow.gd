extends CanvasLayer


const SUBWINDOW_NOTICE = preload("uid://n5d25ppgw4di")


func spawn_subwindow_notice(_msg: String):
	var sb_notice: SubwindowNotice = SUBWINDOW_NOTICE.instantiate()
	sb_notice.title_text = "NOTICE"
	sb_notice.window_text = _msg
	
	sb_notice.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	add_child(sb_notice)
