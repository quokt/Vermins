extends Actor
class_name Player

const AI_SPELLS_PATH = "res://json/AI_spells.json"

var thread : Thread

var network_ID : int = -1 setget set_network_id

signal turn_ready
signal turn_ended
signal puppet_turn_ended
signal move_requested
#signal died
signal ai_thread_finished

var string_class : String
var ai_spells

var ai_buffer_time : float = 0.7



var puppet_playing : bool = false
var active_puppet = null
var is_puppet : bool = false

var working : bool = false

var best_spell
var best_cell


func set_network_id(value : int) -> void:
	network_ID = value


func _ready():
	if is_multiplayer:
		return

func _process(_delta):
	if not active:
		return
	
	if active and not dead:
		play_turn()


func play_turn():
	if has_node("AiControl"):
		if first_action and active and not dead:
			start_turn()
			get_node("AiControl").play_ai_turn()
		return
	
	if first_action:
		start_turn()
	
	if is_multiplayer:
		if can_move and not moving and not entangled:
			if not is_network_master():
				return
			if Input.is_action_just_pressed("mouse_left_click"):
				request_move(get_global_mouse_position())
		
	elif team is int:
		match team:
			TEAMS.SERVER:
				if can_move and not moving and not entangled:
					if is_multiplayer:
						if not is_network_master():
							return
					if Input.is_action_just_pressed("mouse_left_click"):
						request_move(get_global_mouse_position())

func request_move(target_pos):
	var path : Array = []
	var target_cell := Vector2.ZERO
	if is_multiplayer:
		target_cell = target_pos
		emit_signal("move_requested", target_cell , self, current_stamina)
		return 0
		
	elif has_node("AiControl"):
		
		
		var i : int = 0
		var _pos = target_pos
		while path.empty():
			i += 1
			if i > 100:
				break
			var neighbors = pathfinder.get_neighbors(_pos)
	#		neighbors.sort_custom(self, "sort_neighbors")
			var nearest = neighbors[0]
			var distance : float = 10000.0
			for n in neighbors:
				if (n - self.position).length() < distance:
					nearest = n
					distance = (n-self.position).length()
			if not nearest == null:
				path = pathfinder.search(self.position, nearest).duplicate(true)
				
		print(path)
		current_stamina = max(0, current_stamina)
		if path.size() > current_stamina:
			path.resize(current_stamina)
		var path_target_cell = path.pop_back()
		if not path_target_cell:
			return -1
		target_cell = path_target_cell
	else:
		target_cell = target_pos
		
	emit_signal("move_requested", target_cell , self, current_stamina)
	
	return 0


func start_turn():
	first_action = false
	#current_energy = max_energy + energy_modif
	current_energy = max_energy + energy_modif + level.current_bonus_energy #+ int((min(level.turn-1, level.max_bonus_energy)))
	current_stamina = max_stamina + stamina_modif
	current_range = range_modif
		
		
#	for buff_array in current_buffs.values():
#		for buff in buff_array:
#			if buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
#				buff.pass_turn()
	if is_multiplayer:
		for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
			if buff.caster == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_CASTER_START:
					buff.apply_buff()
				
				#if buff.cooldown_mode == Buff.COOLDOWN_MODE.CASTER:
					#buff.rpc("pass_turn")
			
			if buff.target == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_TARGET_START:
					buff.apply_buff()
				
				#if buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
					#buff.rpc("pass_turn")
		if is_network_master():
			for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
				if buff.caster == self and buff.cooldown_mode == Buff.COOLDOWN_MODE.CASTER:
					buff.rpc("pass_turn")
				
				if buff.target == self and buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
					buff.rpc("pass_turn")
	
	else:
		for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
			if buff.caster == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_CASTER_START:
					buff.apply_buff()
				
				#if buff.cooldown_mode == Buff.COOLDOWN_MODE.CASTER:
					#buff.rpc("pass_turn")
			
			if buff.target == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_TARGET_START:
					buff.apply_buff()
				
				#if buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
					#buff.rpc("pass_turn")
					
		for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
			if buff.caster == self and buff.cooldown_mode == Buff.COOLDOWN_MODE.CASTER:
				buff.pass_turn()
			
			if buff.target == self and buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
				buff.pass_turn()
	
	#var i : int = 0
	for spell in cooldowns.keys():
		if cooldowns[spell] != 0:
			cooldowns[spell] -=1
		#i +=1
	
	for child in spells_node.get_children():
		if child is Spell:
			if child.ignore_spell == true:
				continue
				
			child.cast_this_turn = 0
			if child.cooldown > 0:
				child.cooldown -= 1
			else:
				child.cooldown = 0
	
	#if team == TEAMS.ENEMIES:
	#	yield(get_tree().create_timer(ai_buffer_time),"timeout")
	can_move = current_stamina > 0
	emit_signal("turn_ready", current_buffs)
	#first_action = false


func end_turn():
	if not is_multiplayer or is_network_master():
		for buff in get_tree().get_nodes_in_group("buffs"):
			if buff.caster == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_CASTER_END:
					buff.apply_buff()
		
			if buff.target == self:
				if buff.apply_mode == Buff.APPLY_MODE.ON_TARGET_END:
					buff.apply_buff()
	
	
	active = false
	
	current_energy = max_energy + energy_modif + int((min(level.turn-1, level.max_bonus_energy)))
	current_stamina = max_stamina + stamina_modif
	current_range = range_modif

	label.set_text("")
	first_action = true

	
	yield(get_tree().create_timer(0.4),"timeout")
	emit_signal("turn_ended", self)



remotesync func emit_end_turn_signal():
	emit_signal("turn_ended", self)


func set_outline_color(color : Color = Color.white):
	sprite.material.set_shader_param("line_color", color)


func _exit_tree():
	if is_instance_valid(thread):
		if thread.is_active():
			thread.wait_to_finish()


"""
func ai_thread():
	if can_attack() :#and not find_best_spell().empty():
		best_spell = find_best_spell()
		emit_signal("ai_thread_finished")
		return
		#cast_spell(ai_spells[best_spell[0]], best_spell[0], best_spell[2])
	else:
		var can_attack : bool = false
		var distances : Dictionary
		var best_cell
		if can_move and not moving:
			var move_range = floodfill.flood_fill(tilemap.world_to_map(self.position), current_energy, true, false, true)
			for cell in move_range:
				if can_attack(tilemap.map_to_world(cell)):
					can_attack = true
					best_cell = cell
					#distances[cell] = (find_closest_player().position - self.position).length()
					emit_signal("ai_thread_finished")
					#break
					return
	emit_signal("ai_thread_finished")


func can_attack(from_pos : Vector2 = self.position) -> bool:
	
	var can_attack : bool
	
	var possible_cells : Array = []
	var possible_cast_cells : Array = []
	var occupied_cells = tilemap.get_occupied_cells()
	
	for spell in ai_spells.values():
		
		var max_possible_cells = floodfill.flood_fill(tilemap.world_to_map(from_pos) , spell["Max_Range"], not spell["Cell"] == "Empty", spell["Sight"])
		var min_possible_cells = floodfill.flood_fill(tilemap.world_to_map(from_pos) , spell["Min_Range"] -1)
			
		for cell in max_possible_cells :
			if !min_possible_cells.has(cell):
				possible_cells.append(cell)
					
					
		var best_actor_count : int = 0
		var _best_cell : Vector2 = Vector2.ZERO
		for cell in possible_cells:
			var actor_count : int = 0
			var aoe_cells = floodfill.flood_fill(cell, spell["AOE"])
			for aoe_cell in aoe_cells:
				if aoe_cell in occupied_cells:
					if occupied_cells[aoe_cell] == self:
						continue
					else:
						actor_count += 1
			
			if actor_count > best_actor_count:
				_best_cell = cell
				best_actor_count = actor_count
				
		if spell["Cell"] == "Empty" or spell["Cell"] == "Both":
			if best_actor_count == 0:
				possible_cast_cells = []
			else:
				possible_cast_cells = possible_cells.duplicate(true)
		elif spell["Cell"] == "Full":
			for cell in possible_cells:
				if occupied_cells.has(cell):
					possible_cast_cells.append(cell)
	
	can_attack = not possible_cast_cells.empty()
			
	return can_attack


func find_best_spell(check_mov_range : bool = false) -> Array :
	var possible_cells : Array = []
	#var possible_cast_cells : Array = []
	var occupied_cells = tilemap.get_occupied_cells()
	
	if occupied_cells.has(tilemap.world_to_map(self.position)):
		occupied_cells.erase(tilemap.world_to_map(self.position))
	
	var global_best_actor_count : int 
	var best_spell : Array
	for spell in ai_spells:
		
		var max_possible_cells = floodfill.flood_fill(tilemap.world_to_map(self.position) , ai_spells[spell]["Max_Range"], not ai_spells[spell]["Cell"] == "Empty", ai_spells[spell]["Sight"])
		var min_possible_cells = floodfill.flood_fill(tilemap.world_to_map(self.position) , ai_spells[spell]["Min_Range"] -1)
			
		for cell in max_possible_cells :
			if !min_possible_cells.has(cell):
				possible_cells.append(cell)
					
					
		var best_actor_count : int = 0
		var _best_cell
		for cell in possible_cells:
			var actor_count : int = 0
			var aoe_cells = floodfill.flood_fill(cell, ai_spells[spell]["AOE"])
			for occupied_cell in occupied_cells:
				if aoe_cells.has(occupied_cell):
					actor_count += 1
			#for aoe_cell in aoe_cells:
				#if aoe_cell in occupied_cells:
					#actor_count += 1
			
			if actor_count > best_actor_count:
				_best_cell = cell
				best_actor_count = actor_count
				if best_actor_count > global_best_actor_count:
					global_best_actor_count = best_actor_count
					best_spell = [spell, _best_cell]
					
	if best_spell == []:
		print("No spell found by ", self.name, " ai")
		return []
	
	var target_cells = {}
	target_cells["origin"] = tilemap.map_to_world(best_spell[1])
	
	for cell in floodfill.flood_fill(best_spell[1], ai_spells[best_spell[0]]["AOE"]):
						
		if ai_spells[best_spell[0]]["Cell"] == "Full" or ai_spells[best_spell[0]]["Cell"] == "Both":
						
			if occupied_cells.keys().has(cell):
							
				target_cells[cell] = occupied_cells[cell]
							
		if ai_spells[best_spell[0]]["Cell"] == "Empty":
							
			target_cells[cell] = "empty"
			
	best_spell.append(target_cells)
	return best_spell


func find_closest_player() -> Actor:
	var occupied_cells = tilemap.get_occupied_cells()
	var actors = occupied_cells.values()
	var players := []
	for actor in actors:
		if actor.team == TEAMS.PLAYERS:
			players.append(actor)
			
	players.sort_custom(self, "sort_actors")
	var closest_player = players[0]
	#var closest_actor = occupied_cells.values().sort_custom(self, "sort_actors")[0]
	
	return closest_player


func find_closest_neighbor() -> Vector2:
	var neighbor := Vector2.ZERO
	
	var neighbors = pathfinder.get_neighbors(find_closest_player().position)
	
	neighbors.sort_custom(self, "sort_neighbors")
	
	neighbor = neighbors.pop_front()
	
	return neighbor


func sort_actors(a : Actor, b : Actor) -> bool :
	return (a.position-self.position).length() < (b.position-self.position).length()
"""

func sort_neighbors(a : Vector2 , b : Vector2) -> bool :
	return (a - self.position).length() < (b - self.position).length()

