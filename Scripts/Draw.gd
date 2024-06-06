extends Node2D

onready var draw_tilemap = $TileMap
onready var tilemap = get_tree().get_nodes_in_group('nav')[0]
onready var grid = tilemap.grid

const SETTINGS_FILE_PATH = "res://Data/Settings.tres"

#const DRAW_TEXT := {
#	"green" : preload("res://Assets/Tiles/preview_texture_green.tres") ,
#	"yellow" : preload("res://Assets/Tiles/preview_texture_yellow.tres") ,
#	"red" : preload("res://Assets/Tiles/preview_texture_red.tres") ,
#	"blue" : preload("res://Assets/Tiles/preview_texture_blue.tres") ,
#	"white" : preload("res://Assets/Tiles/preview_texture_white.tres") ,
#	"ring" : preload("res://Assets/Tiles/preview_texture_ring.tres")
#}

const DRAW_TEXT = { 
	"square_trans_outline" : preload("res://Assets/Tiles/Textures/map_square_trans_outline.tres") ,
	"white_square" : preload ("res://Assets/Tiles/Textures/map_square.tres") ,
	"ring" : preload("res://Assets/Tiles/Textures/white_ring.tres") ,
	"grid_square" : preload("res://Assets/Tiles/Textures/grid_square.tres")
}
var draw_starting_pos : bool = false
var starting_pos : Array = [] #contains 1 array for each side

var draw_path = []
var movement_points = 0

var unavailable_cells : Array = []

#var draw_cast_cells : bool = false
#var cast_cells := [] #contains cells on which a spell was cast to draw a ring

var cast_draw_duration : float = 2.1

var spell_range
var spell_actor_position = Vector2.ZERO
var spell_preview : Array

var movement_range

var mousePosition

var color = Color.midnightblue
var offset = Vector2(-14,0.9)
var offset2 = Vector2(-8, -3.75)
var offset3 = Vector2(-16, 0)
var circleRadius = 1.5

var opacity = Color(1, 1, 1, 0.5)
var unavailable_cells_modulate = Color.darkblue


func _physics_process(_delta):
	update()

func _draw():
	
	var cellSize = tilemap.get_cell_size() 

	#mousePosition = tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()))
	
	if ResourceLoader.load(SETTINGS_FILE_PATH).show_grid == true:
		#draws the white grid
		var grid_color : Color = ResourceLoader.load(SETTINGS_FILE_PATH).grid_color
		
		for cell in grid.keys():
			
			var pos = cell + offset3
			
			draw_texture(DRAW_TEXT.grid_square, pos, grid_color)
			
		
	#draws mouse position
	if mousePosition != null:
		draw_texture(DRAW_TEXT.ring, mousePosition + offset3)
	
	if draw_starting_pos:
		draw_starting_pos()
	
#	if draw_cast_cells:
#		draw_cast_cells()
	
	
	#draws circle for movement
	var i : int = 0
	if draw_path.size() >= 1:
		for pos in draw_path:
			var draw_pos = pos + offset
			if i < movement_points:
				#draw_circle(draw_pos, circleRadius, Color.yellowgreen)
				draw_texture(DRAW_TEXT.white_square, draw_pos, Color.darkgoldenrod * opacity)
#			elif i+1 == draw_path.size():
#				draw_circle(draw_pos, circleRadius, Color.fuschia)
			else:
				draw_texture(DRAW_TEXT.white_square, draw_pos, Color.chartreuse * opacity)
				#draw_circle(draw_pos, circleRadius, Color.crimson)
			i += 1
	
	#draws circle for spell range
	if spell_actor_position != Vector2.ZERO:
		for pos in spell_range:
			var draw_pos = pos + offset
			draw_texture(DRAW_TEXT.white_square, draw_pos, Color.blue * opacity)
			#draw_circle(draw_pos, circleRadius, Color.aquamarine)
		for pos in movement_range:
			var draw_pos = pos + offset
			draw_texture(DRAW_TEXT.white_square, draw_pos, Color.yellow * opacity)
			
	#draws circle for cast cells preview
	if !spell_preview.empty():
		for pos in spell_preview:
			var draw_pos = pos + offset
			draw_texture(DRAW_TEXT.white_square, draw_pos, Color.red * opacity)
			#draw_cell(draw_pos, "red")
			#draw_circle(draw_pos, circleRadius+0.5, Color.hotpink)
			
	if not unavailable_cells.empty():
		for cell in unavailable_cells:
			var pos = tilemap.map_to_world(cell)
			if pos in spell_preview:
				continue
			var draw_pos = pos + offset
			draw_texture(DRAW_TEXT.white_square, draw_pos, Color.blue * opacity.darkened(0.8))


#func start_cast_draw() -> void:
#	draw_cast_cells = true
#	yield(get_tree().create_timer(cast_draw_duration), "timeout")
#	draw_cast_cells = false


#func draw_cast_cells() -> void:
#	for cell in cast_cells:
#		var pos = tilemap.map_to_world(cell)
#		var draw_pos = pos + offset
#		draw_texture(DRAW_TEXT.ring, draw_pos, Color.purple)


func draw_starting_pos() -> void:
	var i : int = 0
	for team in starting_pos:
		for cell in team:
			var pos = tilemap.map_to_world(cell)
			var draw_pos = pos + offset
			if i == 0:
				draw_texture(DRAW_TEXT.white_square, draw_pos, Color.red * opacity)
			else:
				draw_texture(DRAW_TEXT.white_square, draw_pos, Color.deepskyblue * opacity)
		i+=1


func pop_front_path():
	var _remove = draw_path.pop_front()
	_remove = Vector2.ZERO
