extends Button
class_name ActorIcon

const base_path : String = "res://Characters/"
const PUPPET_PATH : String = "res://Puppets/"

var giants := ["Mantis", "Spider", "Rat", "Earthworm"]

onready var sprite : AnimatedSprite = $AnimatedSprite
onready var shadow : AnimatedSprite = $AnimatedSprite/Shadow

onready var health_label = get_node_or_null("/Label")

#TODO : add code to unlock characters based on game events
var unlocked : bool = true

var character_name : String
var character_cost : int
var outline_color : Color setget set_outline_color, get_outline_color

var index : int
var color_index : int
var color_name : String

var spells := []
var items := []


func set_character(character : Array, flip_h = false, actor = null, is_puppet = false) -> void:
	var health_text : String = ""
	character_name = character[0]
	
	character_cost = character[1]
	
	self.set_icon(character_name, flip_h, is_puppet)
		

	if not unlocked:
		sprite.playing = false
		shadow.playing = false
		shadow.visible = false
		sprite.modulate = Color.black
		sprite.frame = 3
		
	
	if actor : #is Actor:
		health_text = str(actor.current_health_points) + "/" + str(actor.max_health_points)
		sprite.animation = actor.sprite.animation
		
	if health_label != null:
		health_label.text = health_text


func set_icon(character : String, flip_h = false, is_puppet = false) -> void:
	
	if character == "void":
		return
	var path : String
	
	if is_puppet:
		path = str(PUPPET_PATH + character + "/" + character + ".tres")
	else:
		path = str(base_path + character + "/" + character + ".tres")
		
	if character in giants:
		$AnimatedSprite.scale = Vector2(1.2,1.2)
	else:
		$AnimatedSprite.scale = Vector2(2.558, 2.786)
		
	var sprite_frames = load(path)
	
	$AnimatedSprite.set_sprite_frames(sprite_frames) 
	$AnimatedSprite.flip_h = flip_h
	
	$AnimatedSprite/Shadow.set_sprite_frames(sprite_frames)
	$AnimatedSprite/Shadow.flip_h = flip_h
	
	$AnimatedSprite/Shadow.frame = $AnimatedSprite.frame
	


func set_outline_color(color : Color = Color.white, override = false, thickness : float = 1.0) -> void:
	if override:
		outline_color = color
	sprite.material.set_shader_param("line_color", color)
	sprite.material.set_shader_param("line_thickness", thickness)


func get_outline_color() -> Color :
	return outline_color


func get_real_position() -> Vector2 :
	return rect_global_position
	#return $AnimatedSprite.global_position
