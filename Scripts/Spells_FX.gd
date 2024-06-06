extends Node2D

var FX_PATH = "res://fx/"

export (Array) var animations = ["Explosion"]

var loaded_animations : Dictionary = {}

remotesync var draw_cast_cells : bool = false

var cast_cells_color : Color

var ring_texture = preload("res://Assets/Tiles/Textures/white_ring.tres")
var square_texture = preload ("res://Assets/Tiles/Textures/map_square.tres")

remotesync var cast_positions := []

var offset = Vector2(-16,0)

func _ready():
	
	for anim_name in animations:
		loaded_animations[anim_name] = load(FX_PATH + anim_name + ".tscn")
		
		
func _process(_delta) -> void:
	update()
		

func _draw() -> void:	
	if draw_cast_cells:
		draw_cast_cells()
		
		
func draw_cast_cells() -> void:
	for pos in cast_positions:
		var draw_pos = pos + offset
		draw_texture(ring_texture, draw_pos, cast_cells_color)
		draw_texture(square_texture, draw_pos, cast_cells_color*Color(1,1,1,0.2))


remotesync func play_anim(animation : String, target_pos : Vector2, type : String = "") :
	
	if not loaded_animations.has(animation):
		print("Error : could not find animation " + animation)
		return
	
	var animation_scene = loaded_animations[animation].instance()
	get_parent().add_child(animation_scene)
	animation_scene.position = target_pos
	animation_scene.start_animation(type)
	match type:
		"" : cast_cells_color = Color.antiquewhite
		"Magic" : cast_cells_color = Color.purple
		"Physic" : cast_cells_color = Color.orangered
	draw_cast_cells = true
	
	$AnimationPlayer.play("Flash")
	
	yield(animation_scene, "animation_ended")
	
	draw_cast_cells = false
	
	cast_positions = []
	
	animation_scene.queue_free()
	
