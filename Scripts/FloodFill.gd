extends Node

onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]
onready var landscape : TileMap = get_tree().get_nodes_in_group("nav")[1]
onready var grid = tilemap.grid 
onready var walkable = tilemap.walkable 

#onready var raycast = get_tree().get_nodes_in_group("raycast")[0]

onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]

#const DIRECTIONS = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1 , -1)]
const DIRECTIONS = [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]

var cell_size = Vector2(16, 8)

var raycast_offset = Vector2(0, 8)

var movement_range : Array = []

var unavailable_cells : Array = []

func flood_fill(starting_cell : Vector2 , spell_max_range : int, count_occupied : bool = true, sight_needed : bool = true, walking_mode : bool = false, skip_obstacles : bool = false) -> Array:
	var occupied_cells = tilemap.get_occupied_cells()
	var array := []
	var stack := [starting_cell]
	var return_array := []
	#unavailable_cells = []
	
	while not stack.empty():
		var current = stack.pop_back()
		
		#var world_pos = tilemap.map_to_world(current)
		#var world_pos_landscape = landscape.map_to_world(current)
		
		#var is_in_grid : bool = grid.has(world_pos)
		#var is_in_landscape : bool = landscape.grid.has(world_pos_landscape)
		
		#if not is_in_grid and not is_in_landscape:
			#continue
		
		if not grid.has(tilemap.map_to_world(current)) and not tilemap.void_grid.has(tilemap.map_to_world(current)):
			if not tilemap.level1_grid.has(tilemap.map_to_world(current)):
				continue
		if current in array:
			continue

		
		var difference: Vector2 = (current - starting_cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > spell_max_range:
			continue
		

		array.append(current)
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			#var index = tilemap.get_cell(coordinates.x, coordinates.y)
#			if !walkable.has(index):
#				continue
			if coordinates in array:
				continue
			
			stack.append(coordinates)
#	print(array)

	return_array = array.duplicate(true)
	
	#removes non grid cells from the array
	for cell in array:
		if tilemap.void_grid.has(tilemap.map_to_world(cell)) or tilemap.level1_grid.has(tilemap.map_to_world(cell)):
			return_array.erase(cell)
		#if grid.has(tilemap.map_to_world(cell)) and grid[tilemap.map_to_world(cell)][0] == "void":
			#return_array.erase(cell)
		#if landscape.grid.has(tilemap.map_to_world(cell)) and not grid.has(tilemap.map_to_world(cell)):
			#return_array.erase(cell)
	
	array = return_array.duplicate(true)
	
	#removes occupied cells
	if !count_occupied:
		for cell in array:
			if cell in occupied_cells.keys():
				if occupied_cells[cell].is_invisible == false:
					return_array.erase(cell)
				
				
	if walking_mode:
		for cell in array:
			if cell in occupied_cells:
				continue
			var walk = pathfinder.search(tilemap.map_to_world(starting_cell), tilemap.map_to_world(cell))
			if walk == []:
				return_array.erase(cell)
			if walk.size() > spell_max_range:
#				print(str(walk))
				return_array.erase(cell)
				
				
	#removes cells that are blocked from sight
	if sight_needed:
#		var base_pos = Position2D.new()
#		base_pos.position = tilemap.map_to_world(starting_cell)
		unavailable_cells = []
		
		var raycast = RayCast2D.new()
		if occupied_cells.has(starting_cell):
			var current_actor = occupied_cells[starting_cell]
			raycast.add_exception(current_actor)
			
		tilemap.add_child(raycast)
#		raycast.position = tilemap.map_to_world(starting_cell)
		raycast.enabled = true
		raycast.exclude_parent = false
		raycast.collide_with_areas = true
		raycast.collide_with_bodies = true
		
		for cell in array:
			raycast.position = tilemap.map_to_world(starting_cell) + raycast_offset
			#raycast.cast_to = tilemap.map_to_world(cell) - raycast.position + raycast_offset
			raycast.cast_to = tilemap.map_to_world(cell) - raycast.position + raycast_offset
			
			raycast.force_raycast_update()
			if raycast.is_colliding():
				#print(raycast.get_collider().name , " collided")
				if not cell == tilemap.world_to_map(raycast.get_collider().position):
					return_array.erase(cell)
					unavailable_cells.append(cell)
		
		raycast.queue_free()
		
		
	return return_array

