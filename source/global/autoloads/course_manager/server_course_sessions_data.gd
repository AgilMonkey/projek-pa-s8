class_name ServerCourseSessionsData
extends RefCounted


var server_courses: Array[ServerCourse]


func to_dict() -> Dictionary:
	var courses_arr = []
	for course in server_courses:
		courses_arr.append(course.to_dict())   # delegate to child
	return { "server_courses": courses_arr }


static func from_dict(data: Dictionary) -> ServerCourseSessionsData:
	var obj = ServerCourseSessionsData.new()
	obj.server_courses = []
	for course_dict in data.get("server_courses", []):
		obj.server_courses.append(ServerCourse.from_dict(course_dict))
	return obj


class ServerCourse:
	var course_name: String
	var course_resource: CourseResource
	var course_sessions: Array[CourseSession]
	
	func to_dict() -> Dictionary:
		var sessions_arr = []
		for s in course_sessions:
			sessions_arr.append(s.to_dict())
		return {
			"course_name": course_name,
			# course_resource handled separately — see note below
			"course_sessions": sessions_arr,
		}
	
	static func from_dict(data: Dictionary) -> ServerCourse:
		var obj = ServerCourse.new()
		obj.course_name = data.get("course_name", "")
		# load the resource from its path instead of reconstructing it
		var path = data.get("course_resource_path", "")
		if path != "":
			obj.course_resource = load(path)
		obj.course_sessions = []
		for session_dict in data.get("course_sessions", []):
			obj.course_sessions.append(CourseSession.from_dict(session_dict))
		return obj


class CourseSession:
	var session_id: int
	var course_data: Array[CourseSessionData]
	
	func to_dict() -> Dictionary:
		var data_arr = []
		for d in course_data:
			data_arr.append(d.to_dict())
		return {
			"session_id": session_id,
			"course_data": data_arr,
		}
	
	static func from_dict(data: Dictionary) -> CourseSession:
		var obj = CourseSession.new()
		obj.session_id = data.get("session_id", 0)
		obj.course_data = []
		for d_dict in data.get("course_data", []):
			obj.course_data.append(CourseSessionData.from_dict(d_dict))
		return obj


class CourseSessionData:
	var peer_id: int
	var course_total_question: int
	var course_cur_question_count: int
	var course_question: String
	var course_answer: String
	
	func to_dict() -> Dictionary:
		return {
			"peer_id": peer_id,
			"course_total_question": course_total_question,
			"course_cur_question_count": course_cur_question_count,
			"course_question": course_question,
			"course_answer": course_answer,
		}
	
	static func from_dict(data: Dictionary) -> CourseSessionData:
		var obj = CourseSessionData.new()
		obj.peer_id = data.get("peer_id", 0)
		obj.course_total_question = data.get("course_total_question", 0)
		obj.course_cur_question_count = data.get("course_cur_question_count", 0)
		obj.course_question = data.get("course_question", "")
		obj.course_answer = data.get("course_answer", "")
		return obj
