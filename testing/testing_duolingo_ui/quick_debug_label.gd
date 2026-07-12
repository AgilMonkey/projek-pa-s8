extends RichTextLabel


func setup() -> void:
	var _peer_id := multiplayer.get_unique_id()
	var _username := UserManager.client_cur_username
	var _cur_course := CourseManager.client_course_name
	
	text = "peer id: %d\n" % _peer_id
	text += "username: %s\n" % _username
	text += "cur course: %s\n" % _cur_course
