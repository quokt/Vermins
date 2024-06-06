extends Node

var resolution : Vector2


func set_resolution(index : int = 5):
	match index:
		0 : resolution = Vector2(1024, 600)
		1 : resolution = Vector2(1280, 720)
		2:  resolution = Vector2(1366, 768)
		3 : resolution = Vector2(1440, 810)
		4 : resolution = Vector2(1680, 945)
		5 : resolution = Vector2(1920, 1080)
		
		
		
func match_display_to_res(camera : Camera2D):
	match resolution :
		Vector2(1024,600): camera.zoom = Vector2(0.24, 0.22)
		Vector2(1920, 1080) : camera.zoom = Vector2(0.13, 0.13)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("key_f"):
			OS.set_window_fullscreen(not OS.is_window_fullscreen())
