extends Control

const ACTOR_ICON_SCENE = preload("res://Scenes/ActorIcon.tscn")

onready var level = get_tree().get_nodes_in_group("level")[0]

#var teams: Dictionary    #parsed by level
var active_index : int

var references : Dictionary = {}

var first_time : bool = true

onready var Bg2 = $Bg2
onready var Bg3 = $Bg3
onready var Bg4 = $Bg4
onready var Bg5 = $Bg5
onready var Bg6 = $Bg6
onready var Bg7 = $Bg7
onready var Bg8 = $Bg8
onready var Bg9 = $Bg9
onready var Bg10 = $Bg10

onready var backgrounds : Array = [Bg2, Bg3, Bg4, Bg5, Bg6, Bg7, Bg8, Bg9, Bg10]

onready var icons = $IconsContainer/Icons
onready var selector = $IconsContainer/Control

onready var icons_container = $IconsContainer


var fine_scale = Vector2(0.2, 0.2)
var selector_speed : float = 0.3
var selector_offset : Vector2 = Vector2(167, 40)
var selector2_offset : Vector2 = Vector2(0, -3)

onready var actor_count : int = icons.get_child_count()

var bg_index : int

var clickable : bool = false
var draggable : bool = false

var previous_position := Vector2.ZERO

func _process(_delta):
	actor_count = icons.get_child_count()
	match actor_count:
		0: bg_index = -1
		1: bg_index = -1
		2: bg_index = 0
		3: bg_index = 1
		4: bg_index = 1
		5: bg_index = 2
		6: bg_index = 3
		7: bg_index = 3
		8: bg_index = 4
		9: bg_index = 4
		10: bg_index = 5
		_: bg_index = actor_count
	
	set_visible_bg(actor_count)
	
	if clickable:
		if Input.is_action_just_pressed("mouse_left_click"):
			draggable = true
		elif Input.is_action_pressed("mouse_left_click"):
			draggable = true
		elif Input.is_action_just_released("mouse_left_click"):
			draggable = false
			previous_position = Vector2.ZERO
		else:
			draggable = false
	else:
		draggable = false
	#selector_container.rect_scale = icons_container.rect_scale
	#selector_container.rect_size = icons_container.rect_size
	#selector_container.rect_position = icons_container.rect_position + icons.rect_position


func _input(event):
	if not clickable or not draggable:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("mouse_left_click"):
			previous_position = event.position
	
	if event is InputEventMouseMotion:
		if previous_position == Vector2.ZERO:
			previous_position = event.position
		self.rect_position += -(previous_position - event.position) * 0.225
		previous_position = event.position


func set_active(actor_ref : Actor):
	
#	index = max(0, index)
	
	#var pos = icons.get_child(index).get_real_position()
	
	if not references.has(actor_ref):
		return
	
	var icon = references[actor_ref]
	
	
	if first_time:
		#selector.rect_position = Vector2.ZERO + selector_offset
		selector.rect_position = icon.rect_position  + selector_offset
		
	else:
		var tween = Tween.new()
		self.add_child(tween)
		tween.interpolate_property(selector, "rect_position", 
		null, 
		icon.rect_position + selector_offset,
		selector_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()
	
	first_time = false


func display_teams(teams : Dictionary):
	for icon in icons.get_children():
		icon.free()
	
	for team in teams:
		for actor in teams[team]:
			var out_color = teams[team][actor]["color"]
			if out_color is Array:
				add_actor_icon(teams[team][actor]["class"], null, out_color[0])
			else:
				add_actor_icon(teams[team][actor]["class"], null, out_color)


func add_actor_icon(char_class : Array, node_ref = null, outline_color : Color = Color.transparent):
	var new_icon = ACTOR_ICON_SCENE.instance()
	var outline_thickness : float = 0.5
	
	icons.add_child(new_icon)
	
	new_icon.set_character(char_class)
	new_icon.set_outline_color(outline_color, false, outline_thickness)
	
	if not node_ref == null:
		references[node_ref] = new_icon


func remove_actor_icon(actor):
	if references.has(actor):
		if is_instance_valid(references[actor]):
			references[actor].free()
			references.erase(actor)
		yield(icons,"sort_children")
		set_active(level.current_active)
	
	
	#icons.get_child(index).free()
	#yield(icons,"sort_children")
	#set_active(active_index)


func set_visible_bg(index : int = -1):
	
	var bg_name : String = "Bg" + str(index)
	
	for bg in backgrounds:
		bg.visible = bg.name == bg_name

	if index == -1:
		return
		
	#backgrounds[index].visible = true


func _on_TurnDisplayer_mouse_entered():
	clickable = true


func _on_TurnDisplayer_mouse_exited():
	clickable = false
