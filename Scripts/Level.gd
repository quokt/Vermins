extends Node2D
class_name Level

signal move_thread_finished

var teams : Dictionary #parsed by TitleScreen on_Single_pressed()


onready var tilemap = $TileMap
onready var actors = $Actors
onready var actors_array = $Actors.get_children()
onready var pathfinder = $Pathfinder
onready var floodfill = $FloodFill
onready var draw_node = $Draw
onready var ui = $UI_Layer/CombatUI
onready var actor_preview : ActorIcon = $UI_Layer/CombatUI/ActorIcon
onready var turn_displayer = $UI_Layer/CombatUI/TurnDisplayer
onready var spells_fx = $Spells_FX
onready var camera = $Camera2D

const DATA_PATH = "user://game_data.tres"

const ACTORS_BASE_PATH = "res://Characters/"

onready var movement_spell = $UI_Layer/CombatUI/Spells_UI/MovementSpell

#var spell_bar_scale := Vector2(0.4, 0.4)

#movement
var run_treshold = 3
var walking_speed = 0.44
var running_speed = 0.17
var path = []

var current_energy : int = 0
var movement_range : Array

var selected_spell : Spell
var selected_spell_name : String

var spell_possible_cells : Array
var spell_possible_positions : Array
var spell_preview_cells : Array
var spell_preview_positions : Array
var spell_cast_positions : Array
var spell_cell_preview : bool = false
var unavailable_cells : Array

var current_active
var active_index : int = 0


onready var thread : Thread = Thread.new()

#onready var active_player = actors_array[active_index]
var first_player


func load_team():
	return ResourceLoader.load(DATA_PATH).player_team


func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	#var real_mouse_pos = mouse_pos + tilemap.mouseOffset
	var hover_cell = tilemap.world_to_map(mouse_pos + tilemap.mouseOffset)
	#var hover_cell_position = tilemap.map_to_world(hover_cell)
	spell_preview_positions = []
	
	if is_instance_valid(current_active):
		if not current_active.team == Actor.TEAMS.ENEMIES:
			current_active.can_move = !movement_range.empty()
	#if !movement_range.empty():
		#current_active.can_move = true
	#else : current_active.can_move = false
	
	if not spell_possible_cells.has(hover_cell):
		spell_preview_positions = []
		draw_node.spell_preview = spell_preview_positions.duplicate(true)
		return
		
	if spell_cell_preview and not selected_spell == null:
		if selected_spell == movement_spell:
			spell_preview_cells = pathfinder.search(current_active.position, tilemap.map_to_world(hover_cell))
			spell_preview_positions = spell_preview_cells.duplicate(true)
			
		elif selected_spell.cell_mode == Spell.CELL_MODE.FULL:
			if hover_cell in tilemap.get_occupied_cells().keys():
				spell_preview_cells = floodfill.flood_fill(hover_cell, selected_spell.aoe, true, false)
				for cell in spell_preview_cells:
					spell_preview_positions.append(tilemap.map_to_world(cell))
					
			
		elif selected_spell.cell_mode == Spell.CELL_MODE.EMPTY:
			if not hover_cell in tilemap.get_occupied_cells().keys():
				spell_preview_cells = floodfill.flood_fill(hover_cell, selected_spell.aoe, true, false)
				for cell in spell_preview_cells:
					spell_preview_positions.append(tilemap.map_to_world(cell))
			
		else:
			spell_preview_cells = floodfill.flood_fill(hover_cell, selected_spell.aoe, true, false)
				
			for cell in spell_preview_cells:
				spell_preview_positions.append(tilemap.map_to_world(cell))
		
		draw_node.spell_preview = spell_preview_positions.duplicate(true)


func _unhandled_input(event):
	
	if event is InputEventKey:
		
		if event.is_action_pressed("escape"):
			get_tree().quit()
			
	if event is InputEventMouseButton:
		
		var target_position = tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()))
		
		if not tilemap.grid.has(target_position):
			return
			
		
		if event.is_action_pressed("mouse_right_click"):
			#if !movement_range.has(target_position):
			if spell_possible_positions.empty() and movement_range.empty() and not tilemap.get_occupied_cells().has(tilemap.world_to_map(get_global_mouse_position())):
				#set_preview_actor("void")
				set_preview_actor(current_active.CLASS, current_active)
				
			reset_values()
			print(str(tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset))), str(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset)))
			print("Tile index : ", tilemap.get_cell(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset).x, tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset). y))

			
		if event.is_action_pressed("mouse_left_click"):
			
			if !movement_range.empty():
				if !movement_range.has(target_position):
					reset_values()
						
			if spell_possible_positions.has(target_position) and !selected_spell == null and !selected_spell == movement_spell:
					
				var cast_cells = floodfill.flood_fill(tilemap.world_to_map(target_position), selected_spell.aoe, true, false)
				var occupied_cells = tilemap.get_occupied_cells()
				var target_cells = {} #keys : cells , values : actors
					
				for cell in cast_cells:
					
					target_cells["origin"] = target_position
						
					if selected_spell.cell_mode == Spell.CELL_MODE.FULL or selected_spell.cell_mode == Spell.CELL_MODE.BOTH:
						
						if occupied_cells.keys().has(cell):
							
							target_cells[cell] = occupied_cells[cell]
							
					if selected_spell.cell_mode == Spell.CELL_MODE.EMPTY:
							
						target_cells[cell] = "empty"
							
					
				selected_spell.cast_spell(target_cells)
					
				#current_active.cast_spell(selected_spell, selected_spell_name, target_cells)
					
				reset_values()


func _ready():

	var loaded_team = load_team()
	for team in teams:
		for actor in teams[team]:
			var path:String = ACTORS_BASE_PATH + str(teams[team][actor]["class"][0]) + "/" + str(teams[team][actor]["class"][0]) + ".tscn"
			var scene = load(path)
			var new_actor = scene.instance()
			new_actor.spells = []
			match team:
				"Player":
					new_actor.team = Actor.TEAMS.PLAYERS
				"Enemies":
					new_actor.team = Actor.TEAMS.ENEMIES
					
					
			actors.add_child(new_actor)
			
			var i : int = 1
			for spell in teams[team][actor]["spells"]:
				var spell_id = spell.spell_ID
				#print(spell["Name"])
				
				var scene_path = "res://Spells/" + new_actor.CLASS + "/" + spell_id + "/" + spell_id + ".tscn"
				var spell_scene = load(scene_path).instance()
				new_actor.spells_node.add_child(spell_scene)
				spell_scene.connect("jump_requested", self, "on_jump_requested")
				spell_scene.connect("slide_requested", self, "on_slide_requested")
				spell_scene.connect("spell_cast", self, "on_spell_cast")
				
				
				if new_actor.spells.has(spell_id):
					i += 1
					spell_id += str(i)
				

				
				new_actor.spells.append(spell_id)
				#print(new_actor.spells)
					


			if teams[team][actor].has("color"):
				if teams[team][actor]["color"] is Array:
					new_actor.set_outline_color(teams[team][actor]["color"][0])
				else:
					new_actor.set_outline_color(teams[team][actor]["color"])
	
	actors_array = actors.get_children()
	#sort actors depending on their initiative
	actors_array.sort_custom(actors , "sort_actors")
	for actor in actors_array:
		actor.raise()
	
	for actor in actors_array:
		if not (actor is Actor):
			continue
		turn_displayer.add_actor_icon([actor.CLASS, 0], actor, actor.get_outline_color())
	#temporary : place players on set starting positions
	var i : int = 0
	for actor in actors_array:
		actor.position = tilemap.starting_positions[i]
		i += 1
		actor.connect("died", self, "on_actor_died")
		actor.connect("actor_pressed", self, "on_actor_pressed")
		actor.connect("turn_ended", self, "end_turn")
		
	#connects end-turn button
	ui.connect("end_turn_pressed", self, "end_turn")
	
	#connects move_button
	ui.connect("move_button_pressed", self, "on_move_button_pressed")
	
	#sets first child in actors as active and connect its signals
	current_active = actors.get_child(active_index)

	start_turn(current_active)
	
	ui.connect("spell_used", self, "on_spell_requested", [current_active])


func connect_spell_bar(actor):
	ui.set_preview_actor(actor)


func end_turn(actor : Actor = current_active):
	print("level received end_turn signal from combat_ui")
	#manages turn system
	#makes nodes in actors be "active" one at a time in tree order
	#actor.play_turn() activates only if the actor is active
	
	#de-activates the current active player
	#current_active = actors.get_child(active_index)
	
	if not actor == current_active:
		return
	
	if not is_instance_valid(current_active):
		return
	
	#wait for movement to finish
	if current_active.moving == true:
		yield(current_active, "move_finished")
		
	current_active.end_turn()

	draw_node.draw_path = [] ; movement_range = [] ; spell_possible_cells = []
	reset_values()
	
	if current_active.is_connected ("move_requested", self, "on_move_requested"):
		current_active.disconnect("move_requested", self, "on_move_requested")
	if current_active.is_connected("spell_cast", self, "on_spell_cast"):
		current_active.disconnect("spell_cast", self, "on_spell_cast")
	
	#if spells_bar.is_connected("spell_used", self, "on_spell_requested"):
		#spells_bar.disconnect("spell_used", self, "on_spell_requested")
		
	
	#activates and connects next player
	active_index = (active_index + 1) % actors.get_child_count() 
	current_active = actors.get_child(active_index)
	turn_displayer.set_active(current_active)
	#turn_displayer.active_index = active_index
	start_turn(current_active)
	
	"""
	current_active.first_action = true
	current_active.active = true
	yield(current_active, "turn_ready")
	update_values(current_active)
	set_preview_actor(current_active.CLASS)
	ui.active_effects = current_active.current_buffs.duplicate(true)
	current_active.connect("move_requested", self, "on_move_requested")
	current_active.connect("spell_cast", self, "on_spell_cast")
	connect_spell_bar(current_active)
	"""


func start_turn(actor):
	
	if actor.team == Actor.TEAMS.ENEMIES:
		ui.set_end_turn_button(false)
	else:
		ui.set_end_turn_button(true)
	
	actor.first_action = true
	actor.active = true
	
	yield(actor, "turn_ready")
	
	connect_spell_bar(actor)

	set_preview_actor(actor.CLASS, actor)
	
	ui.active_effects = actor.current_buffs.duplicate(true)
	
	actor.connect("move_requested", self, "on_move_requested")
	actor.connect("spell_cast", self, "on_spell_cast")
	
	update_values(actor, true)
	turn_displayer.set_active(actor)
	#turn_displayer.active_index = active_index
	



func on_actor_pressed(actor):
	set_preview_actor(actor.CLASS, actor)


func set_preview_actor(character : String, actor = null):
	var flip_h = true
	var line_thickness : float = 0.5
	actor_preview.visible = not character == "void"

	actor_preview.set_character([character, 0], flip_h, actor)
	if actor:
		actor_preview.set_outline_color(actor.get_outline_color(), false, line_thickness)
		ui.set_preview_actor(actor)


func on_move_button_pressed() -> void:
	#var occupied_cells = tilemap.get_occupied_cells()
	var energy = current_active.current_energy
	update_values(current_active, true)
	var draw_positions = floodfill.movement_range.duplicate(true)
	#var draw_positions = floodfill.flood_fill(tilemap.world_to_map(current_active.position), energy, false ,false, true)
	movement_range = [] ; spell_possible_positions = [] ; spell_possible_cells = draw_positions ; spell_preview_cells = []
	draw_node.unavailable_cells = []
	#draw_node.spell_preview = [] ; draw_node.spell_range = []
	spell_cell_preview = true
	selected_spell = movement_spell
	
	set_preview_actor(current_active.CLASS, current_active)
	
	for pos in draw_positions:
		movement_range.append(tilemap.map_to_world(pos))
		
	if energy == 0:
		print("No movement points left")
		movement_range.clear()
		
	if current_active.moving == false:
		draw_node.spell_range = movement_range ; draw_node.spell_actor_position = current_active.position
		#draw_node.unavailable_cells = floodfill.unavailable_cells
		draw_node.unavailable_cells = []


func on_move_requested(target_position : Vector2 , actor : Actor, movement_points : int) -> void:
	print(actor.name, " requested move on ", str(target_position))
	var target_cell = tilemap.world_to_map(target_position)
	var real_target_position = tilemap.map_to_world(target_cell)
	var mousePosition = tilemap.mousePosition
	var actor_position = tilemap.map_to_world(tilemap.world_to_map(actor.position))
		#if path.size() != 0 and real_target_position == path[-1]:
			#if energy_used < movement_points:
				#var energy_left = movement_points - energy_used
				#path.resize(energy_left)
				#move_actor(actor, path)
				
	if actor.team == Actor.TEAMS.ENEMIES:
		path = pathfinder.search(actor_position, real_target_position)
		update_values(actor)
		move_actor(actor, path)
		
		return
		
	elif movement_range.has(real_target_position):
		if path.size() <= movement_points : #and energy_used < movement_points:
			path = pathfinder.search(actor_position , mousePosition)
			draw_node.draw_path = path.duplicate(true)
			update_values(actor)
			spell_possible_cells = []
			move_actor(actor, path)
			movement_range = []
			#update_values(actor, true)


func on_jump_requested(target_position : Vector2, actor : Actor) -> void:
	actor.position = tilemap.map_to_world(tilemap.world_to_map(target_position))



func on_slide_requested(target_position : Vector2, actor : Actor, strength : int = 1,  duration : float = 1.0) -> void:
	
	var real_target_pos: Vector2 = Vector2.ZERO
	
	var shortest_distance = 5000
	if tilemap.world_to_map(target_position) in tilemap.get_occupied_cells():
		
		for neighbor in pathfinder.get_neighbors(target_position):
			var distance = (target_position - actor.position).length()
			if distance < shortest_distance:
				shortest_distance = distance
				real_target_pos = neighbor
				
	else:
		real_target_pos = target_position
		
	var path = pathfinder.search(actor.position, real_target_pos)
	path.resize(strength)
	print(path)
	
	var tween = Tween.new()
	self.add_child(tween)
	
	tween.interpolate_property(actor, "position", 
		null,
		path[-1],
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	tween.queue_free()


func on_spell_requested(spell : Spell, spell_unique_name : String, actor : Actor) -> void:
	var count_occupied : bool
	var sight_needed : bool
	movement_range = []
	actor = current_active
	if spell.mana <= actor.current_energy:
		if actor.moving == false:
			spell_possible_cells = []
			var actual_range = spell.max_range + actor.current_range
			var spell_max_cells
			var spell_min_cells
			var unavailable_cells : Array = []
			
			
			count_occupied = not spell.cell_mode == Spell.CELL_MODE.EMPTY
				
			sight_needed = spell.sight_needed
				
			spell_max_cells = floodfill.flood_fill(tilemap.world_to_map(actor.position), actual_range, count_occupied, sight_needed)
			spell_min_cells = floodfill.flood_fill(tilemap.world_to_map(actor.position), (spell.min_range-1), true, false)
			
			for cell in spell_max_cells :
				if !spell_min_cells.has(cell):
					spell_possible_cells.append(cell)
				
			match spell.range_mode:
				Spell.RANGE_MODE.DEFAULT:
					pass
				Spell.RANGE_MODE.LINE:
					for cell in spell_possible_cells.duplicate():
						if not cell.x == tilemap.world_to_map(actor.position).x and not cell.y == tilemap.world_to_map(actor.position).y:
							spell_possible_cells.erase(cell)
					for cell in floodfill.unavailable_cells.duplicate():
						if not cell.x == tilemap.world_to_map(actor.position).x and not cell.y == tilemap.world_to_map(actor.position).y:
							floodfill.unavailable_cells.erase(cell)
				Spell.RANGE_MODE.DIAGONAL:
					for cell in spell_possible_cells.duplicate():
						if not tilemap.map_to_world(cell).x == actor.position.x and not tilemap.map_to_world(cell).y == actor.position.y:
							spell_possible_cells.erase(cell)
					for cell in floodfill.unavailable_cells.duplicate():
						if not tilemap.map_to_world(cell).x == actor.position.x and not tilemap.map_to_world(cell).y == actor.position.y:
							floodfill.unavailable_cells.erase(cell)
				Spell.RANGE_MODE.STAR:
					for cell in spell_possible_cells.duplicate():
						if not cell.x == tilemap.world_to_map(actor.position).x and not cell.y == tilemap.world_to_map(actor.position).y:
							if not tilemap.map_to_world(cell).x == actor.position.x and not tilemap.map_to_world(cell).y == actor.position.y:
								spell_possible_cells.erase(cell)
					for cell in floodfill.unavailable_cells.duplicate():
						if not cell.x == tilemap.world_to_map(actor.position).x and not cell.y == tilemap.world_to_map(actor.position).y:
							if not tilemap.map_to_world(cell).x == actor.position.x and not tilemap.map_to_world(cell).y == actor.position.y:
								floodfill.unavailable_cells.erase(cell)
				
			match spell.cell_mode:
				Spell.CELL_MODE.EMPTY:
					for cell in tilemap.get_occupied_cells().keys():
						if cell in spell_possible_cells:
							spell_possible_cells.erase(cell)
							unavailable_cells.append(cell)
				Spell.CELL_MODE.FULL:
					for cell in spell_possible_cells.duplicate():
						if not cell in tilemap.get_occupied_cells().keys():
							spell_possible_cells.erase(cell)
							unavailable_cells.append(cell)
				Spell.CELL_MODE.BOTH:
					pass
			

			
			spell_possible_positions = []
			spell_cell_preview = true
		
			for pos in spell_possible_cells:
				spell_possible_positions.append(tilemap.map_to_world(pos))
			
			draw_node.spell_range = spell_possible_positions.duplicate(true)
			for cell in floodfill.unavailable_cells.duplicate():
				if cell in spell_min_cells:
					floodfill.unavailable_cells.erase(cell)
				
			if not sight_needed:
				floodfill.unavailable_cells.clear()
			draw_node.unavailable_cells = floodfill.unavailable_cells
			draw_node.unavailable_cells.append_array(unavailable_cells)
			draw_node.spell_actor_position = actor.position
			update()
		
		selected_spell = spell
		selected_spell_name = spell_unique_name
		
		print(actor.name + " requested spell : " + spell.spell_name)
		
	else:
		print("Not enough man")


func on_spell_cast(spell : Spell, actor : Actor = current_active) -> void:
	update_values(actor)

"""
	func on_spell_cast(actor, spell : Dictionary, targets : Dictionary, damages, healings, new_puppet, buffs, new_pos):
	#var target_cell = tilemap.world_to_map(target)
	#var cast_cells = floodfill.flood_fill(target_cell, spell["AOE"])
	#var occupied_cells = tilemap.get_occupied_cells()
	
	if spell.has("Anim"):
		spells_fx.play_anim(spell["Anim"], targets["origin"])
	
	for target in targets:
		
		if str(target) == "origin":
			continue
	
		if spell["Cell"] == "Full" or spell["Cell"] == "Both":
			if !damages == null and !damages.empty():
				print("Dealt " , damages[target][0] , " ", damages[target][1], " damage to " , targets[target].name)
				targets[target].take_damage(damages[target])
				#CombatPrinter.print_new_line(["Dealt " , damages[target][0] , " ", damages[target][1], " damage to " , targets[target].name])

			if !healings == null and !healings.empty():
				print("healed for ", healings[target])
				targets[target].heal(healings[target])
				
		if buffs != null:
			for buff in buffs.values():
				buff["spell_ID"] = spell["ID"]
				if buff.has("Targets") :
					if buff["Targets"].has("Self") :
						actor.add_buff(buff)
					if buff["Targets"].has("Allies"):
						if actor.team == targets[target].team:
							targets[target].add_buff(buff)
					if buff["Targets"].has("Enemies"):
						if actor.team != targets[target].team:
							targets[target].add_buff(buff)
				else:
					targets[target].add_buff(buff)
					
		if new_puppet != null:
			new_puppet.position = tilemap.map_to_world(target)
			actors.add_child_below_node(current_active, new_puppet)
			
		if new_pos != null:
			actor.position = tilemap.map_to_world(new_pos)
			
	draw_node.spell_preview = []
	ui.active_effects = actor.current_buffs.duplicate(true)
	ui.cooldowns = actor.cooldowns.duplicate(true)
	update_values(actor, true)
"""

func on_actor_died(actor):
	print(actor.name + " died")
	CombatPrinter.print_new_line([actor.name, " died"])
	if actor.active:
		end_turn()
		#return
		
	#yield(get_tree().create_timer(1.5),"timeout")

	var actor_index = actors.get_children().find(actor)
	
	if actor_index <= active_index:
		active_index -= 1
	
	turn_displayer.remove_actor_icon(actor)
	turn_displayer.active_index = active_index
	
	
	actor.visible = false
	yield(get_tree().create_timer(1.0),"timeout")
	actor.free()
	
	update_values(current_active, true)


func move_actor(actor, moving_path) -> void:
	
	var moving_speed : float
	if path.size() < run_treshold :
		moving_speed = walking_speed
	elif path.size() >= run_treshold :
		moving_speed = running_speed
	
	actor.moving = true
	
	var tween = Tween.new()
	self.add_child(tween)
	
	for pos in moving_path :
		
		#orientates the actor depending on the move direction
		if pos.x > actor.position.x :
			if pos.y > actor.position.y:
				#actor.sprite.animation = "IdleDown"
				actor.sprite.flip_h = false
			if pos.y < actor.position.y:
				#actor.sprite.animation = "IdleUp"
				actor.sprite.flip_h = false
		if pos.x < actor.position.x :
			if pos.y > actor.position.y:
				#actor.sprite.animation ="IdleDown"
				actor.sprite.flip_h = true
			if pos.y < actor.position.y:
				#actor.sprite.animation = "IdleUp"
				actor.sprite.flip_h = true
				
		#moves the player to current target cell 
		tween.interpolate_property(actor, "position", actor.position , pos , moving_speed)
		tween.start()
		#wait for movement to finish
		yield(tween, "tween_completed")
		
		actor.current_energy -= 1
		update_values(actor)
		
		draw_node.call("pop_front_path")
		
	path = []
	actor.moving = false
	update_values(actor, true)
	actor.emit_signal("move_finished")


func update_values(actor, update_mov_range : bool = false) -> void:
	draw_node.movement_points = actor.current_energy
	draw_node.spell_range = []
	draw_node.unavailable_cells.clear()

	ui.energy = actor.current_energy
	ui.energy = actor.current_energy
	ui.cooldowns = actor.cooldowns.duplicate(true)
	ui.set_preview_actor(actor)
	
	if update_mov_range:
		
		var array = [tilemap.world_to_map(current_active.position), current_active.current_energy]
		thread.start(self, "thread_update_move_range", array)
		#yield(self, "move_thread_finished")
		#thread.wait_to_finish()
		floodfill.movement_range = movement_range.duplicate(true)


func thread_update_move_range(param_array):
	var array
	array = floodfill.flood_fill(param_array[0] , param_array[1], false, false, true)
	movement_range = array.duplicate(true)
	
	call_deferred("end_thread")
	return array
	#emit_signal("move_thread_finished")


func end_thread():
	var result = thread.wait_to_finish()
	
	movement_range = result.duplicate(true)
	floodfill.movement_range = result.duplicate(true)


func reset_values() -> void:
	movement_range.clear()
	draw_node.spell_range.clear()
	draw_node.unavailable_cells.clear()
	unavailable_cells.clear()
	spell_possible_cells.clear()
	spell_possible_positions.clear()
	selected_spell = null
