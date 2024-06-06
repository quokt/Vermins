extends Node2D
tool


const SAVE_PATH = "res://Data/Maps.tres"
const MAPS_PATH = "res://Data/Maps.tres"

export var load_map : bool = false
export var load_map_name : String

onready var line_edit = $Layer/LineEdit
onready var button = $Layer/Save

onready var tilemap = $TileMap
onready var landscape_tilemap = $TileMap/Landscape
onready var level1_tilemap = $TileMap/Level1
onready var props_tilemap = $TileMap/Props
onready var starting_pos_tilemap = $TileMap/StartingPositions

var tileset_path := "res://tileset_v2_h1.tres"


func print_tile_region():
	for cell in props_tilemap.get_used_cells():
		var tileset : TileSet = props_tilemap.tile_set
		var tile_id = props_tilemap.get_cellv(cell)
		print(tileset.tile_get_region(tile_id))
		


func add_collision_to_tiles() -> void:
	var collision_points := PoolVector2Array([
		Vector2(1.4, 25.1) ,
		Vector2(17, 17.1) ,
		Vector2(32.6, 25.1) ,
		Vector2(17, 32.7)
	])
	
	var collision_shape := ConvexPolygonShape2D.new()
	collision_shape.points = collision_points
	
	var tileset_res : TileSet = ResourceLoader.load(tileset_path)
	for tile_id in tileset_res.get_tiles_ids():
		#tileset_res.tile_set_shapes(tile_id, [])
#		tileset_res.tile_set_texture_offset(tile_id, Vector2(0,0))
		for x in range(9):
			for y in range(8):
				var atlas_coord = Vector2(x, y)
				#tileset_res.tile_set_shapes(tile_id, [])
				var size = tileset_res.tile_get_texture(tile_id).get_size()
				if size == Vector2(760,820):
					pass
					tileset_res.autotile_set_z_index(tile_id, atlas_coord, 2)
					#tileset_res.tile_set_texture_offset(tile_id, Vector2(0,-8))
					#tileset_res.tile_add_shape(tile_id, collision_shape, Transform2D.IDENTITY, false, atlas_coord)
		
	var ok = ResourceSaver.save(tileset_path, tileset_res)
	if ok == 0:
		print(OK)
	


func _process(_delta) -> void:
	if Engine.editor_hint:
		if load_map:
			load_map()


func save_map() -> void:
	
	var map_name : String
	if line_edit.text == "":
		print("Error : map name is empty!")
		return
	
	map_name = line_edit.text
	
	var save_file = ResourceLoader.load(SAVE_PATH)
	if save_file.maps.has(map_name):
		save_file.maps[map_name].clear()
	if save_file.landscapes.has(map_name):
		save_file.landscapes[map_name].clear()
	if save_file.level1.has(map_name):
		save_file.level1[map_name].clear()
	if save_file.props.has(map_name):
		save_file.props[map_name].clear()
	if save_file.starting_pos.has(map_name):
		save_file.starting_pos[map_name].clear()
	
	save_file.maps[map_name] = parse_map().duplicate(true)
	save_file.landscapes[map_name] = parse_landscape().duplicate(true)
	save_file.level1[map_name] = parse_level1().duplicate(true)
	save_file.props[map_name] = parse_props().duplicate(true)
	save_file.starting_pos[map_name] = parse_starting_pos().duplicate(true)
	
	var err = ResourceSaver.save(SAVE_PATH, save_file)
	print(str(err))
	if err == 0:
		print("Map saved")


func parse_map() -> Dictionary:
	var map : Dictionary = {}
	
	if tilemap.get_used_cells().empty():
		print("Error : map is empty!")
		return {}
	
	for cell in tilemap.get_used_cells():
		var tile_index = tilemap.get_cellv(cell)
		var atlas_coord = tilemap.get_cell_autotile_coord(cell.x, cell.y)
		map[cell] = [tile_index, atlas_coord]
		
	return map


func parse_landscape() -> Dictionary:
	var map : Dictionary = {}
	
	if landscape_tilemap.get_used_cells().empty():
		print("Warning : landscape is empty!")
	
	for cell in landscape_tilemap.get_used_cells():
		var tile_index = landscape_tilemap.get_cellv(cell)
		var atlas_coord = landscape_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		map[cell] = [tile_index, atlas_coord]
		
	return map


func parse_level1() -> Dictionary:
	var map : Dictionary = {}
	
	if level1_tilemap.get_used_cells().empty():
		print("Warning : level 1 is empty!")
	
	for cell in level1_tilemap.get_used_cells():
		var tile_index = level1_tilemap.get_cellv(cell)
		var atlas_coord = level1_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		map[cell] = [tile_index, atlas_coord]
		
	return map


func parse_props() -> Dictionary:
	var map : Dictionary = {}
	var tileset : TileSet = props_tilemap.tile_set
	
	if props_tilemap.get_used_cells().empty():
		print("Warning : props is empty!")
	
	var debug = props_tilemap.get_used_cells()
	for cell in debug:
		var tile_index = props_tilemap.get_cellv(cell)
		var atlas_coord = props_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		var tile_texture : Texture = tileset.tile_get_texture(tile_index)
		var tile_region : Rect2 = tileset.tile_get_region(tile_index)
		map[cell] = [tile_index, atlas_coord, tile_texture, tile_region]
		
	return map


func parse_starting_pos() -> Array:
	var _starting_pos : Array = []
	
	if starting_pos_tilemap.get_used_cells().empty():
		print("Warning : starting positions not set ; this map will not work")
		return []
	
	var team1 := []
	var team2 := []
	
	for cell in starting_pos_tilemap.get_used_cells():
		var tile_index = starting_pos_tilemap.get_cellv(cell)
		#var atlas_coord = starting_pos_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		if tile_index == 11 :
			team1.append(cell)
		elif tile_index == 12:
			team2.append(cell) 
	
	_starting_pos = [team1, team2]
	
	return _starting_pos


func load_map() -> void:
	
	load_map = false
	
	if not Engine.editor_hint:
		return
	
	var map_name : String
	
	if load_map_name == "":
		print("Error : map name is empty")
		return
	
	map_name = load_map_name
	var maps_resource = ResourceLoader.load(SAVE_PATH)
	
	var map = maps_resource.maps[map_name]
	
	var landscape = null
	if maps_resource.landscapes.has(map_name):
		landscape = maps_resource.landscapes[map_name]
		
	var level1 = null
	if maps_resource.level1.has(map_name):
		level1 = maps_resource.level1[map_name]
		
	var props = null
	if maps_resource.props.has(map_name):
		props = maps_resource.props[map_name]
		
	var starting_pos = null
	if maps_resource.starting_pos.has(map_name):
		starting_pos = maps_resource.starting_pos[map_name]

	
	#clear previous map
	for cell in tilemap.get_used_cells():
		tilemap.set_cell(cell.x, cell.y, -1)
		
	for cell in landscape_tilemap.get_used_cells():
		landscape_tilemap.set_cell(cell.x, cell.y, -1)
		
	for cell in level1_tilemap.get_used_cells():
		level1_tilemap.set_cell(cell.x, cell.y, -1)
		
	for cell in props_tilemap.get_used_cells():
		props_tilemap.set_cell(cell.x, cell.y, -1)
		
	for cell in starting_pos_tilemap.get_used_cells():
		starting_pos_tilemap.set_cell(cell.x, cell.y, -1)
	
	
	#set each cell to loaded map cells
	for cell in map.keys():
		tilemap.set_cell(cell.x, cell.y, map[cell][0], false, false, false, map[cell][1])
		
	if not landscape == null:
		for cell in landscape.keys():
			if map.has(cell):
				continue
			landscape_tilemap.set_cell(cell.x, cell.y, landscape[cell][0], false, false, false, landscape[cell][1])
	
	if not level1 == null:
		for cell in level1.keys():
			level1_tilemap.set_cell(cell.x, cell.y, level1[cell][0], false, false, false, level1[cell][1])
		
	if not props == null:
		for cell in props.keys():
			props_tilemap.set_cell(cell.x, cell.y, props[cell][0], false, false, false, props[cell][1])
		
	var i : int = 0
	var index
	if not starting_pos == null:
		for team_pos in starting_pos:
			for cell in team_pos:
				if i == 0:
					index = 11
				else:
					index = 12
				starting_pos_tilemap.set_cell(cell.x, cell.y, index )
			i += 1
	else: print("error 123456")
	
	print("Something happened in the editor")


func _on_Save_pressed() -> void:
	save_map()




func _on_Button_pressed():
	#print_tile_region()
	add_collision_to_tiles()
