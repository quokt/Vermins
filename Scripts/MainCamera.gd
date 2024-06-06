extends Camera2D

var previous_position : Vector2 = Vector2.ZERO
var draggable : bool = false

var BASE_CAM_POS = Vector2(200, 110) 
var BASE_CAM_ZOOM = Vector2(0.45,0.45)
var MAX_CAM_ZOOM = Vector2(0.11, 0.11)
const MAX_ZOOM_LEVEL = 5
var camera_zoom_speed = 0.8
var camera_trans_speed = 0.4
var zoom_level : int = 1

func _ready():
	zoom = BASE_CAM_ZOOM
	position = BASE_CAM_POS



func _unhandled_input(event : InputEvent):
	
	if event is InputEventMouseMotion and draggable:
		position.x = min(limit_right, max(limit_left, position.x + ((previous_position.x - event.position.x) * 1/zoom_level)))
		position.y = min(limit_bottom, max(limit_top, position.y + ((previous_position.y - event.position.y) * 1/zoom_level)))
		previous_position = event.position
		get_tree().set_input_as_handled()
		return
		
	if event is InputEventMouseButton:
		
		if Input.is_action_pressed("mousewheel_click") and zoom_level > 1:
			previous_position = event.position
			draggable = true
			get_tree().set_input_as_handled()
			return
			
		
		elif event.is_action_pressed("mousewheel_up") and not draggable:
			if zoom_level >= MAX_ZOOM_LEVEL :
				return
			zoom *= camera_zoom_speed
			position = lerp(position, get_global_mouse_position(), camera_trans_speed)
			zoom_level += 1
			
		elif event.is_action_pressed("mousewheel_down") and not draggable:
			if zoom >= BASE_CAM_ZOOM :
				return
			zoom_level -= 1
			zoom *= 1/camera_zoom_speed
			if zoom_level <= 1 :
				position = BASE_CAM_POS
			else:
				position = lerp(position, BASE_CAM_POS, camera_trans_speed)
			
		else: draggable = false
		

