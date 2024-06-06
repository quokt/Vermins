extends TileMap

const MAPS_PATH = "res://Data/Maps.tres"
const PROPS_COLLISION_SCENE = preload("res://Scenes/PropsCollision.tscn")
const PROP_SPRITE_SCENE = preload("res://Scenes/PropSprite.tscn")

var walkable = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23] #hold walkable cells index
var grid = {} #to be tile world locations
#grid KEYS are world positions of the cells
#grid VALUES are ["empty"/"blocked" , instance_reference, position_in_grid]
var void_grid := {}
var level1_grid := {}

var mousePosition = Vector2() #cursor pick
var mouseOffset = Vector2(0 , -0.9) #offset mouse position to align with tiles

var actor_cells : Dictionary = {}


#references
onready var actors = get_tree().get_nodes_in_group('actors')
onready var draw_node = get_tree().get_nodes_in_group('draw')[0]
onready var pathfinder = get_tree().get_nodes_in_group('pathfinder')[0]
onready var landscape_tilemap : TileMap = $Landscape
onready var level1_tilemap : TileMap = get_tree().get_nodes_in_group("level1")[0]
onready var props_node : Node2D = get_tree().get_nodes_in_group("props")[0]

var props_tile_ids : Array = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

onready var props_collision_node = $PropsCollisions
#onready var trees_collision_node = $TreesCollisions

onready var starting_positions = []

var transparent_props : bool = false



func load_map(map_name : String = "default"):
	
	var map = ResourceLoader.load(MAPS_PATH).maps[map_name]
	var landscape = ResourceLoader.load(MAPS_PATH).landscapes[map_name]
	var level1 = ResourceLoader.load(MAPS_PATH).level1[map_name]
	var props = ResourceLoader.load(MAPS_PATH).props[map_name]
	
	for cell in map.keys():
		if cell in props.keys():
			landscape_tilemap.set_cell(cell.x, cell.y, map[cell][0], false, false, false, map[cell][1])
			continue
		set_cell(cell.x, cell.y, map[cell][0], false, false, false, map[cell][1])
		
		
	for cell in landscape.keys():
		if map.has(cell):
			continue
		landscape_tilemap.set_cell(cell.x, cell.y, landscape[cell][0], false, false, false, landscape[cell][1])
	
	for cell in level1.keys():
		level1_tilemap.set_cell(cell.x, cell.y, level1[cell][0], false, false, false, level1[cell][1])
	
	for cell in props.keys():
		var new_sprite = PROP_SPRITE_SCENE.instance()
		props_node.add_child(new_sprite)
		new_sprite.position = level1_tilemap.map_to_world(cell)
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = props[cell][2]
		atlas_texture.region = props[cell][3]
		new_sprite.set_texture(atlas_texture)
		new_sprite.connect("area_entered", self, "on_prop_collision_entered")
		new_sprite.connect("area_exited", self, "on_prop_collision_exited")
#		props_tilemap.set_cell(cell.x, cell.y, props[cell][0], false, false, false, props[cell][1])
		
		
		pass
	
	var starting_pos = ResourceLoader.load(MAPS_PATH).starting_pos[map_name]
	self.starting_positions = starting_pos.duplicate(true)


func on_prop_collision_entered(prop : Node2D, area : Area2D, collider : Area2D) -> void:
	if transparent_props:
		return
	if collider is Player:
		if collider.is_invisible: #and not collider.is_network_master():
			if collider.is_multiplayer and not collider.is_network_master():
				return
			elif not collider.is_multiplayer and collider.team == Actor.TEAMS.CLIENT:
				return
		prop.make_transparent(true)
	pass
	
	
func on_prop_collision_exited(prop : Node2D, area : Area2D, collider : Area2D) -> void:
	if transparent_props:
		return
	for collider in area.get_overlapping_areas():
		if not collider is Player:
			continue
		if not collider.is_invisible:
			#if there is at least one visible player in the area:
			return
		if collider.is_invisible:
			if collider.is_multiplayer and collider.is_network_master():
				return
			elif not collider.is_multiplayer and collider.team == Actor.TEAMS.SERVER :
				return
			else:
				continue
	prop.make_transparent(false)
	pass


func set_map(map_name : String) -> void:
	if not map_name:
		map_name = "default"
	load_map(map_name)
	parse_grid()
	landscape_tilemap.parse_grid()

#func _ready():
#	load_map(map_name)
#	parse_grid()
#	landscape_tilemap.parse_grid()


func parse_grid():
	#get used cells into an array (not real world pos)
	var tiles = get_used_cells()
	var level1_tiles = level1_tilemap.get_used_cells()
	#var props_tiles = props_tilemap.get_used_cells()
	#create a grid dictionary containing a data array for each cell that have the right index (in 'walkable' array)
	#get cell world pos, centralize it and append to grid array
	
	for pos in tiles:
		
		
		#get current cell index
		var index = get_cell(pos.x,pos.y)
		
		
		#if idx is not in walkable cell idx dictionary
		if !walkable.has(index):
			var tgt = map_to_world(pos)
			void_grid[tgt] = ["empty", null, pos]
			continue #skip to the next iteration
		
		#else
		var tgt = map_to_world(pos,false) #get world pos
		#tgt = Vector2(tgt.x,tgt.y+15) #offset to centralize tile
		#grid is dictionary, make data array for each cell
		grid[tgt] = ["empty", null, pos] #[empty/blocked/void, instance_refernce, world_position]
		
	for pos in landscape_tilemap.get_used_cells():
		var tgt = map_to_world(pos)
		void_grid[tgt] = ["empty", null, pos]
		
	for pos in level1_tiles:
		var tgt = map_to_world(pos, false)
		level1_grid[tgt] = pos
	
	for sprite in props_node.get_children():
		var tgt = map_to_world(world_to_map(sprite.position), false)
		level1_grid[tgt] = world_to_map(sprite.position)
	
	for pos in grid.keys():
		if !walkable.has(get_cell(grid[pos][2].x, grid[pos][2].y)):
			grid[pos][0] = "blocked"
		#if level1_grid.has(pos):
			#grid[pos][0] = "blocked"

	for pos in level1_grid.keys():
		if grid.has(pos):
			grid.erase(pos)
		
			
	pathfinder.occupied_cells = get_occupied_cells()


func _process(_delta):
	
	#get map tile pos relative to mouse
	var tgt_cell = world_to_map( get_global_mouse_position() + mouseOffset)
	var cell_index = get_cell(tgt_cell.x, tgt_cell.y)
	
	#if tgt_cell is a valid cell (!= -1), sets it to mousePosition
	if cell_index != -1:
		#get world position and centralize offset tile 
		mousePosition =  map_to_world(tgt_cell)
	else:
		mousePosition = null #unable it
	
	#parse cursor target to be drawn
	draw_node.mousePosition = mousePosition


func get_occupied_cells() -> Dictionary : #keys = cells ; values = actors
	#actualize occupied cells
	actors = get_tree().get_nodes_in_group('actors')
	actor_cells = {} #keys : cells , values : actor
	for actor in actors:
		if actor == null or not is_instance_valid(actor):
			continue
		var cell_pos = world_to_map(actor.position)
		actor_cells.keys().append(cell_pos)
		actor_cells[cell_pos] = actor
	
	for cell in grid.keys():
		if cell in actor_cells.keys():
			grid[cell][0] = "blocked"
		elif !walkable.has(get_cell(grid[cell][2].x, grid[cell][2].y)):
			grid[cell][0] = "blocked"
		else:
			grid[cell][0] = "empty"
			

	pathfinder.occupied_cells = actor_cells
	return actor_cells


func make_props_transparent(value : bool = true) -> void:
	for child in props_node.get_children():
		child.make_transparent(value)
	transparent_props = value
	
	if value == false:
		for child in props_node.get_children():
			for collider in child.get_node("HideArea").get_overlapping_areas():
				on_prop_collision_entered(child, child.get_node("HideArea"), collider)
