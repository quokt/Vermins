extends Node

var target : Actor = null

onready var level = get_tree().get_nodes_in_group("level")[0]
onready var tilemap = get_tree().get_nodes_in_group("nav")[0]
onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]

var ai_buffer_time : float = 0.7

func _ready():
	if get_parent() is Actor:
		target = get_parent()
	else:
		print("Error : AiControl node was not added correctly and will delete itself...")
		queue_free()


func play_ai_turn():
	yield(get_tree().create_timer(ai_buffer_time),"timeout")
	
	if target == null or not is_instance_valid(target):
		return
	
	var actions = ["attack", "move"]
	#var attackable_cells : Array = floodfill.flood_fill(tilemap.world_to_map(position), default_spell.max_range, true, true)
	
	while not actions.empty():
		if not target.active or target.dead:
			break
		var closest_player = find_closest_player()
		if closest_player == null or not is_instance_valid(closest_player):
			return
		var cell = tilemap.world_to_map(closest_player.position)
		var neighbors = pathfinder.get_neighbors(target.position, false)
		
#		var movement_range = floodfill.flood_fill(tilemap.world_to_map(target.position), target.current_stamina, false, false, true).duplicate(true)
		
		
		if "attack" in actions:
			var spells = target.spells_node.get_children().duplicate()
			spells.shuffle()
			for spell in spells:
				if spell.energy_cost <= target.current_energy and spell.get_valid_cell() and spell.cooldown < 1:
					spell.cast_spell(tilemap.map_to_world(spell.get_valid_cell()))
					yield(get_tree().create_timer(ai_buffer_time*3),"timeout")
					
			if not "move" in actions:
				actions.erase("attack")
			
			
			
			var can_attack = false
			for spell in target.spells_node.get_children():
				if spell.energy_cost <= target.current_energy:
					can_attack = true
					break
			if can_attack == false:
				actions.erase("attack")
			
			
			#if cell in attackable_cells:
				#if type == TYPES.MELEE:
					#actions.erase("move")
#				var target_cells := {}
#				target_cells["origin"] = closest_player.position
#				target_cells[cell] = closest_player
#				default_spell.cast_spell(target_cells)
#
#				yield(get_tree().create_timer(ai_buffer_time*2),"timeout")
#
#				if current_energy < default_spell.energy_cost:
#					actions.erase("attack")
#		if type == TYPES.MELEE and "move" in actions and not tilemap.map_to_world(cell) in pathfinder.get_neighbors(position):
#			request_move(tilemap.map_to_world(cell))
		
		var player_cell : Vector2 = tilemap.world_to_map(find_closest_player(true).position)
		
		if target.ai_type == Actor.AI_TYPES.RANGE and "move" in actions and not "attack" in actions:
			var previous : Vector2 = tilemap.world_to_map(target.position)
			
			
			if player_cell in target.default_spell.preview_spell_range(-3):
			
				var opposite_dir : Vector2 #= Vector2(int(player_cell.x<previous.x), int(closest_player.position.y<position.y))
				opposite_dir.x = 1 if player_cell.x < previous.x else -1
				opposite_dir.y = 1 if player_cell.y < previous.y else -1
				opposite_dir.x = 0 if player_cell.x == previous.x else opposite_dir.x
				opposite_dir.y = 0 if player_cell.y == previous.y else opposite_dir.y
			
				var cells = tilemap.get_used_cells()
				for i in target.current_stamina:
					if cells.has(previous+opposite_dir):
						previous += opposite_dir
					else:
						for dir in [0,1]:
							opposite_dir[dir] = 0
							if cells.has(previous+opposite_dir):
								previous += opposite_dir
								break
			else:
				var result = target.request_move(tilemap.map_to_world(player_cell))
				yield(get_tree().create_timer(ai_buffer_time),"timeout")
				if result == -1:
					actions.erase("move")
				if target.current_stamina == 0:
					actions.erase("move")
						
			if tilemap.get_used_cells().has(previous):
				target.request_move(tilemap.map_to_world(previous))
				actions.erase("move")
			
		var debug = tilemap.map_to_world(player_cell)
		if "move" in actions and ((target.ai_type == Actor.AI_TYPES.RANGE and "attack" in actions) or (target.ai_type == Actor.AI_TYPES.MELEE and not debug in neighbors)):
			#actions.erase("move")
			var result = target.request_move(tilemap.map_to_world(player_cell))
			yield(get_tree().create_timer(ai_buffer_time),"timeout")
			#attackable_cells = floodfill.flood_fill(tilemap.world_to_map(position), default_spell.max_range, true, true)
			#if cell in attackable_cells:
				#continue
			if result == -1:
				actions.erase("move")
			if target.current_stamina == 0:
				actions.erase("move")
		else:
			actions.erase("move")
#		if not "move" in actions and type: #and not cell in attackable_cells:
#			actions.erase("attack")
#		if not "attack" in actions:
#			actions.erase("move")
		
	
	yield(get_tree().create_timer(ai_buffer_time*2),"timeout")
	
	level.on_end_turn(target)
	
	
func find_closest_player(ignore_puppets : bool = false) -> Actor:
	var occupied_cells = tilemap.get_occupied_cells().duplicate(true)
#	var array : Array = occupied_cells.values().duplicate(true)
	var array2 = []
	for actor in occupied_cells.values():
		if actor.team != target.team and not actor.dead:
			if ignore_puppets and actor is Puppet:
				continue
			array2.append(actor)
#	for actor in array:
#		if actor.team == self.team:
#			array.erase(actor)
	array2.sort_custom(self, "sort_actors_by_distance")

	if array2.empty():
		return null
	
	var closest_actor = array2[0]
	return closest_actor


func sort_actors_by_distance(a : Actor, b : Actor) -> bool :
	return (a.position-target.position).length() < (b.position-target.position).length()


func sort_actors_by_health(a : Actor, b : Actor) -> bool:
	return a.current_health_points < b.current_health_points
	
