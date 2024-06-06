extends TileMap

var grid : Dictionary = {} #to be tile world locations
#grid KEYS are world positions of the cells
#grid VALUES are ["empty"/"blocked" , instance_reference, position_in_grid]




func parse_grid():
	#get used cells into an array (not real world pos)
	var tiles = get_used_cells()
	
	#create a grid dictionary containing a data array for each cell that have the right index (in 'walkable' array)
	#get cell world pos, centralize it and append to grid array
	
	for pos in tiles:
		
		#get current cell index
		#var index = get_cell(pos.x,pos.y)
		
		#if idx is not in walkable cell idx dictionary
		#if !walkable.has(index):
			#continue #skip to the next iteration
		
		#else
		var tgt = map_to_world(pos,false) #get world pos
		#tgt = Vector2(tgt.x,tgt.y+15) #offset to centralize tile
		#grid is dictionary, make data array for each cell
		grid[tgt] = ["empty", null, pos] #[empty/blocked, instance_refernce, world_position]
		
	#for pos in grid.keys():
		#if !walkable.has(get_cell(grid[pos][2].x, grid[pos][2].y)):
			#grid[pos][0] = "blocked"
