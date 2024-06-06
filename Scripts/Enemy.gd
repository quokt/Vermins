extends Player
class_name Enemy

enum TYPES {MELEE, RANGE, PROTECTOR}
var type = TYPES.MELEE


func _ready() -> void:
	pass


func play_turn():
	if first_action and active and not dead:
		start_turn()
		play_ai_turn()

				
func play_ai_turn() -> void:
	
	yield(get_tree().create_timer(ai_buffer_time),"timeout")
	
	var actions = ["attack", "move"]
	#var attackable_cells : Array = floodfill.flood_fill(tilemap.world_to_map(position), default_spell.max_range, true, true)
	
	while not actions.empty():
		if not active or dead:
			break
		var closest_player = find_closest_player()
		if closest_player == null or not is_instance_valid(closest_player):
			return
		var cell = tilemap.world_to_map(closest_player.position)
		var neighbors = pathfinder.get_neighbors(position, false)
		
		
		if "attack" in actions:
			var spells = spells_node.get_children().duplicate()
			spells.shuffle()
			for spell in spells:
				while spell.energy_cost <= current_energy and spell.get_valid_cell():
					spell.cast_spell(tilemap.map_to_world(spell.get_valid_cell()))
					yield(get_tree().create_timer(ai_buffer_time*3),"timeout")
					
			if not "move" in actions:
				actions.erase("attack")
				
			var can_attack = false
			for spell in spells_node.get_children():
				if spell.energy_cost <= current_energy:
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
		
		
		if type == TYPES.RANGE and "move" in actions and not "attack" in actions:
			var previous : Vector2 = tilemap.world_to_map(position)
			var player_cell : Vector2 = tilemap.world_to_map(closest_player.position)
			var opposite_dir : Vector2 #= Vector2(int(player_cell.x<previous.x), int(closest_player.position.y<position.y))
			opposite_dir.x = 1 if player_cell.x < previous.x else -1
			opposite_dir.y = 1 if player_cell.y < previous.y else -1
			opposite_dir.x = 0 if player_cell.x == previous.x else opposite_dir.x
			opposite_dir.y = 0 if player_cell.y == previous.y else opposite_dir.y
			
			var cells = tilemap.get_used_cells()
			for i in current_stamina:
				if cells.has(previous+opposite_dir):
					previous += opposite_dir
				else:
					for dir in [0,1]:
						opposite_dir[dir] = 0
						if cells.has(previous+opposite_dir):
							previous += opposite_dir
							break
						
			if tilemap.get_used_cells().has(previous):
				request_move(tilemap.map_to_world(previous))
				actions.erase("move")
			
		var debug = tilemap.map_to_world(cell)
		if "move" in actions and ((type == TYPES.RANGE and "attack" in actions) or (type == TYPES.MELEE and not debug in neighbors)):
			#actions.erase("move")
			request_move(tilemap.map_to_world(cell))
			yield(get_tree().create_timer(ai_buffer_time),"timeout")
			#attackable_cells = floodfill.flood_fill(tilemap.world_to_map(position), default_spell.max_range, true, true)
			#if cell in attackable_cells:
				#continue
			if current_stamina == 0:
				actions.erase("move")
		else:
			actions.erase("move")
#		if not "move" in actions and type: #and not cell in attackable_cells:
#			actions.erase("attack")
#		if not "attack" in actions:
#			actions.erase("move")
		
	
	yield(get_tree().create_timer(ai_buffer_time*2),"timeout")
	
	level.on_end_turn(self)
					

func find_closest_player() -> Actor:
	var occupied_cells = tilemap.get_occupied_cells().duplicate(true)
#	var array : Array = occupied_cells.values().duplicate(true)
	var array2 = []
	for actor in occupied_cells.values():
		if actor.team != self.team and not actor.dead:
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
	return (a.position-self.position).length() < (b.position-self.position).length()


func sort_actors_by_health(a : Actor, b : Actor) -> bool:
	return a.current_health_points < b.current_health_points
