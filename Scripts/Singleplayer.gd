extends Node2D
class_name Singleplayer


#signal move_thread_finished()
signal turn_ended()
signal game_finished()
signal both_teams_ready()
signal actors_sorted()
signal actor_cleaned()
signal turn_passed(current_turn)

export var push_damage : int# = 4

const DATA_PATH = "user://game_data.tres"
const ACTORS_BASE_PATH = "res://Characters/"
const ITEMS_BASE_PATH = "res://Items/"

const AI_CONTROL_SCENE = preload("res://Scenes/AiControl.tscn")

var level_count : int = 0 #
var region : String

var team : int      # Server : 0 ; Client : 1

#variables used for initial placement phase
var placement_phase : bool = false
var both_teams_ready : bool = false
var server_ready : bool = false
remote var client_ready : bool = false
var selected_actor

var end_turn_queue : int = 0
var game_ended : bool = false

remotesync var teams : Dictionary
remotesync var IDs : Dictionary

onready var tilemap = get_tree().get_nodes_in_group("nav")[0]
onready var actors = get_tree().get_nodes_in_group("actors_list")[0]
onready var actors_array = actors.get_children()
onready var pathfinder = $Pathfinder
onready var floodfill = $FloodFill
onready var draw_node = $Draw
onready var ui = $UI_Layer/CombatUI
#onready var actor_preview : ActorIcon = $UI_Layer/CombatUI/ActorIcon
onready var turn_displayer = $UI_Layer/CombatUI/TurnDisplayer
onready var spells_fx = $Spells_FX
onready var camera = $Camera2D
onready var bonus_energy_label := $UI_Layer/CombatUI/TurnCount/Sprite/Label
onready var music_player := $MusicPlayer

onready var results_node := $Results

var selected_map : String

onready var movement_spell = $UI_Layer/CombatUI/MovementSpell

#var spell_bar_scale := Vector2(0.4, 0.4)

#movement
export var run_treshold : int# = 3
export var walking_speed : float# = 0.44
export var running_speed : float# = 0.17
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
var turn_displayer_index : int = 0

export var max_bonus_energy : int# = 5
var current_bonus_energy : int
var turn : int = 0


#onready var thread : Thread = Thread.new()
var players : Array = []
#onready var active_player = actors_array[active_index]
var first_player


func load_team():
	return ResourceLoader.load(DATA_PATH).player_team


func _process(_delta):
#	var test = get_tree().get_nodes_in_group("camera")
#	test[0].current = true

	
	var mouse_pos = get_global_mouse_position()
	#var real_mouse_pos = mouse_pos + tilemap.mouseOffset
	var hover_cell = tilemap.world_to_map(mouse_pos + tilemap.mouseOffset)
	#var hover_cell_position = tilemap.map_to_world(hover_cell)
	spell_preview_positions = []
	
	if placement_phase and get_tree().is_network_server():
		both_teams_ready = server_ready and client_ready
		if both_teams_ready:
			rpc("both_teams_ready")
	
	if is_instance_valid(current_active):
		current_active.can_move = !movement_range.empty()
		ui.move_button.disabled = not current_active.team == 0
		ui.attack_button.disabled = not current_active.team == 0
		ui.set_end_turn_button(current_active.team == 0 and end_turn_queue == 0 and not current_active.has_node("AiControl"))
		
	if not spell_possible_cells.has(hover_cell):
		spell_preview_positions = []
		draw_node.spell_preview = spell_preview_positions.duplicate(true)
		return
		
	if spell_cell_preview and not selected_spell == null:
		
		var origin_cell
		
		if selected_spell.cast_mode == Spell.CAST_MODE.ORIGIN:
			origin_cell = hover_cell
		
		if selected_spell.cast_mode == Spell.CAST_MODE.CUSTOM:
			var custom_origin = selected_spell.get_custom_origin()
			origin_cell = tilemap.world_to_map(custom_origin)
		
		
		if selected_spell == movement_spell:
			spell_preview_cells = pathfinder.search(current_active.position, tilemap.map_to_world(hover_cell))
			spell_preview_positions = spell_preview_cells.duplicate(true)
			
		elif selected_spell.cell_mode == Spell.CELL_MODE.FULL:
			if origin_cell in tilemap.get_occupied_cells().keys():
				preview_spell_aoe(origin_cell)
					
			
		elif selected_spell.cell_mode == Spell.CELL_MODE.EMPTY:
			if not origin_cell in tilemap.get_occupied_cells().keys():
				preview_spell_aoe(origin_cell)
			
		else:
			preview_spell_aoe(origin_cell)
		
		draw_node.spell_preview = spell_preview_positions.duplicate(true)


func preview_spell_aoe(origin_cell : Vector2) -> void:
	
	spell_preview_cells = selected_spell.preview_spell_aoe(origin_cell)
	
	#spell_preview_cells = _spell_preview_cells
	for cell in spell_preview_cells:
		spell_preview_positions.append(tilemap.map_to_world(cell))


func _unhandled_input(event):
	
	if event is InputEventKey:
		
		if event.is_action_pressed("escape"):
			get_tree().quit()
			
	if event is InputEventMouseButton:
		
		var target_position = tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()))
		
#		if not tilemap.grid.has(target_position):
#			return
		
		if event.is_action_pressed("mouse_right_click"):
			#if !movement_range.has(target_position):
			if spell_possible_positions.empty() and movement_range.empty() and not tilemap.get_occupied_cells().has(tilemap.world_to_map(get_global_mouse_position())):
				if not placement_phase:
					#set_preview_actor("void")
					set_preview_actor(current_active.CLASS, current_active)
				
			if not placement_phase:
				reset_values()
			print(str(tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset))), str(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset)))
			print("Tile index : ", tilemap.get_cell(tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset).x, tilemap.world_to_map(get_global_mouse_position()+tilemap.mouseOffset). y))
			
		if not tilemap.grid.has(target_position):
			return
			
		if event.is_action_pressed("mouse_left_click"):
			
			if placement_phase and selected_actor != null:
				var cell = tilemap.world_to_map(get_global_mouse_position())
				if tilemap.starting_positions[team].has(cell) and not tilemap.get_occupied_cells().has(cell):
					on_jump_requested(target_position, selected_actor)
					#selected_actor.position = target_position
					
			
			if !movement_range.empty():
				if !movement_range.has(target_position):
					reset_values()
						
			if spell_possible_positions.has(target_position) and !selected_spell == null and !selected_spell == movement_spell:
				
					
				cast_spell( selected_spell, target_position)
				
				#selected_spell.cast_spell(target_cells)
					
				#current_active.cast_spell(selected_spell, selected_spell_name, target_cells)
					
				reset_values()
			


func cast_spell(spell , target_position : Vector2):
	end_turn_queue += 1
	spell.cast_spell(target_position)


func _ready():
	#if get_tree().is_network_server():
		#team = 0
	#else:
		#team = 1
	start_game()
	
	results_node.connect("title_screen_pressed", self, "on_title_screen_pressed")


remotesync func both_teams_ready() -> void:
	emit_signal("both_teams_ready")


remotesync func actors_sorted() -> void:
	emit_signal("actors_sorted")


func place_players() -> void :
	placement_phase = true
	turn_displayer.selector.visible = false
	
	draw_node.starting_pos = tilemap.starting_positions.duplicate(true)
	draw_node.draw_starting_pos = true

	ui.end_turn_button_label.text = "Ready!"
	ui.connect("end_turn_pressed", self, "on_ready_pressed")
	ui.end_turn_button.connect("transparent_props_toggled", self, "on_transparent_props_toggled")
	ui.end_turn_button.connect("sounds_toggled", self, "on_sounds_toggled")

	var i_s := [0, 0]
	for actor in actors_array:
		actor.position = tilemap.map_to_world(tilemap.starting_positions[actor.team][i_s[actor.team]])
		i_s[actor.team] += 1
			
func on_transparent_props_toggled(value : bool) -> void:
	tilemap.make_props_transparent(value)


func on_sounds_toggled(value : bool) -> void:
	music_player.mute(not value)


func on_ready_pressed() -> void:
	if get_tree().is_network_server():
		server_ready = true
	else:
		rset("client_ready", true)


func start_game() -> void :
	
	tilemap.set_map(selected_map)

	#var loaded_team = load_team()
	
	#if is_network_master():
		#rset("teams", teams)
	
	for team in teams:
		for actor_number in teams[team]:
			add_actor(actor_number, team)

	
	actors_array = actors.get_children()
	#sort actors depending on their initiative
	#sorting is done by server, then synced to client
	#if get_tree().is_network_server():
		
	actors_array.shuffle()
	actors_array.sort_custom(actors , "sort_actors")
	
	for actor in actors_array:
		actor.raise()
		
#		var previous_init : int = 0
#		for actor in actors.get_children().duplicate():
#			if actor.initiative != previous_init:
#				previous_init = actor.initiative
#			else:
#				if randi()%2 == 0:
#					actor.rpc("_raise")
				
		#self.rpc("actors_sorted")
	#else:
		#yield(self, "actors_sorted")
	
	actors_array = actors.get_children()
	
	for actor in actors_array:
		if not actor is Actor:
			continue
		turn_displayer.add_actor_icon([actor.CLASS, 0], actor, actor.get_outline_color())
		
	place_players()
		
	#yield(self, "both_teams_ready")
		
	ui.disconnect("end_turn_pressed", self, "on_ready_pressed")
	
	draw_node.starting_pos = []
	draw_node.draw_starting_pos = false
	ui.end_turn_button_label.text = "END\nTURN"
	
	placement_phase = false
	turn_displayer.selector.visible = true
	
	for actor in actors_array:
		actor.connect("died", self, "on_actor_died")
		#actor.connect("turn_ended", self, "on_end_turn")
		
	#connects end-turn button
	ui.connect("end_turn_pressed", self, "on_end_turn")

	#connects base attack
	ui.connect("attack_button_pressed", self, "on_attack_button_pressed")
	
	#connects move_button
	ui.connect("move_button_pressed", self, "on_move_button_pressed")
	
	
	ui.connect("back_button_pressed", self, "on_back_button_pressed")
	
	#sets first child in actors as active and connect its signals
	current_active = actors.get_child(active_index)

	start_turn(current_active)
	
	ui.connect("spell_used", self, "on_spell_requested")
	
	music_player.play_random()


func add_actor(actor, team) -> void:
	var path_:String = ACTORS_BASE_PATH + str(teams[team][actor]["class"][0]) + "/" + str(teams[team][actor]["class"][0]) + ".tscn"
	var scene = load(path_)
	var new_actor : Actor = scene.instance()
	
	actors.add_child(new_actor, true)
	if team == "Client":
		new_actor.add_child(AI_CONTROL_SCENE.instance())
		new_actor.base_stamina += 1
	
	new_actor.spells = []
	new_actor.is_multiplayer = false
#			match team:
#				"Player":
#					new_actor.team = Actor.TEAMS.PLAYERS
#				"Enemies":
#					new_actor.team = Actor.TEAMS.ENEMIES
	#new_actor.set_network_master(IDs[team])
	#new_actor.set_network_id(IDs[team])
	if team == "Server":
		new_actor.team = Actor.TEAMS.SERVER
	elif team == "Client":
		new_actor.team = Actor.TEAMS.CLIENT
	
	
	
	for item in teams[team][actor]["items"]:
		var scene_path = ITEMS_BASE_PATH + item + ".tscn"
		var item_scene : Item = load(scene_path).instance()
		new_actor.items_node.add_child(item_scene)
		item_scene.target = new_actor
		item_scene.singleplayer = true
		if item_scene.apply_mode == Item.APPLY_MODE.START :
			item_scene._apply_item(new_actor)
			pass
		elif item_scene.apply_mode == Item.APPLY_MODE.CUSTOM and item_scene._get_custom_apply():
			if item_scene.custom_apply == Item.CUSTOM_APPLY.LEVEL:
				connect(item_scene._get_custom_apply(), item_scene, "on_apply_signal")
			elif item_scene.custom_apply == Item.CUSTOM_APPLY.TARGET:
				new_actor.connect(item_scene._get_custom_apply(), item_scene, "on_apply_signal")
	
	var i : int = 1
	for spell_array in teams[team][actor]["spells"].values():
		var spell_id = spell_array[0]
		#print(spell["Name"])
		
		var scene_path = "res://Spells/" + new_actor.CLASS + "/" + spell_id + "/" + spell_id + ".tscn"
		var spell_scene = load(scene_path).instance()
		new_actor.spells_node.add_child(spell_scene)
		spell_scene.singleplayer = true
		spell_scene.connect("jump_requested", self, "on_jump_requested")
		spell_scene.connect("slide_requested", self, "on_slide_requested")
		spell_scene.connect("push_requested", self, "on_push_requested")
		spell_scene.connect("spell_cast", self, "on_spell_cast")
		
		
		
		
		#new_actor.base_energy += spell_scene.bonus_energy
		
		if new_actor.spells.has(spell_id):
			i += 1
			spell_id += str(i)
		

		#spells_references[new_actor] = {spell_id : spell_scene}
		new_actor.spells.append(spell_id)
		#print(new_actor.spells)
		
	var default_spell_scene : Spell = load("res://Spells/"+new_actor.CLASS+"/DefaultSpell/DefaultSpell.tscn").instance()
	default_spell_scene.default_spell = true
	default_spell_scene.character = new_actor.CLASS
	
	new_actor.spells_node.add_child(default_spell_scene)
	
	default_spell_scene.singleplayer = true
	if team == "Client":
		if default_spell_scene.max_range > 1:
			new_actor.ai_type = Actor.AI_TYPES.RANGE
			default_spell_scene.max_range *= 2
		if default_spell_scene.max_range > 2:
			new_actor.ai_type = Actor.AI_TYPES.RANGE
			default_spell_scene.max_range *= 2
		
	new_actor.default_spell = default_spell_scene
	default_spell_scene.connect("spell_cast", self, "on_spell_cast")
	
	
	
	if teams[team][actor].has("color"):
		if teams[team][actor]["color"] is Array:
			new_actor.set_outline_color(teams[team][actor]["color"][0])
		else:
			new_actor.set_outline_color(teams[team][actor]["color"])
			
	new_actor.connect("actor_pressed", self, "on_actor_pressed")
	new_actor.initialize_actor()


func connect_spell_bar(actor):
	ui.set_preview_actor(actor, actor.team == Actor.TEAMS.CLIENT)


func on_end_turn(actor = null):
	print("level received end_turn signal from combat_ui")
	
	if game_ended:
		return
	
	if end_turn_queue:
		yield(self,"spell_cast")
		
	for _actor in actors.get_children():
		if _actor == null or not is_instance_valid(_actor):
			continue
		if _actor.dead:
			end_turn_queue += 1
			yield(get_tree().create_timer(2.0),"timeout")
			end_turn_queue = max(0, end_turn_queue - 1)
	
	
	var actor_path = ""
	if actor != null and is_instance_valid(actor):
		actor_path = actor.get_path()
		
	r_end_turn(actor_path)


remotesync func r_end_turn(actor_path : NodePath = ""):
	
	#manages turn system
	#makes nodes in actors be "active" one at a time in tree order
	#actor.play_turn() activates only if the actor is active
	
	#de-activates the current active player
	#current_active = actors.get_child(active_index)
	
	ui.set_end_turn_button(false)
	
	var actor = get_node_or_null(actor_path)
	
	if actor == null:
		actor = current_active
	
	#if not actor == current_active:
		#return
	
	if not is_instance_valid(actor):
		return
	
	#wait for movement to finish
	if actor.moving == true:
		yield(actor, "move_finished")
		
	actor.end_turn()
	
#	yield(actor, "turn_ended")

	draw_node.draw_path = [] ; movement_range = [] ; spell_possible_cells = []
	reset_values()
	
	if actor.is_connected ("move_requested", self, "on_move_requested"):
		actor.disconnect("move_requested", self, "on_move_requested")
	if actor.is_connected("spell_cast", self, "on_spell_cast"):
		actor.disconnect("spell_cast", self, "on_spell_cast")
	
	#if spells_bar.is_connected("spell_used", self, "on_spell_requested"):
		#spells_bar.disconnect("spell_used", self, "on_spell_requested")
	
	#activates and connects next player
	var actors_count : int = 0
	players = []
	for child in actors.get_children():
#		if child.dead:
#			continue
		actors_count += 1
		if child is Puppet and not child.dead:
			continue
		players.append(child)

			
	
#	if actor.dead:
#		active_index += 1

	active_index = (active_index + 1) % actors_count 
	current_active = actors.get_child(active_index)
	
	while current_active == null or not is_instance_valid(current_active) or current_active.dead:
		active_index = (active_index + 1) % actors_count 
		current_active = actors.get_child(active_index)
	
	while current_active is Puppet and not current_active.is_controlable:
		for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
			if buff.caster == current_active:
				if buff.apply_mode == Buff.APPLY_MODE.ON_CASTER_START:
					buff.apply_buff()
			
			if buff.target == current_active:
				if buff.apply_mode == Buff.APPLY_MODE.ON_TARGET_START:
					buff.apply_buff()
	
		for buff in get_tree().get_nodes_in_group("buffs").duplicate(true):
			if buff.caster == current_active and buff.cooldown_mode == Buff.COOLDOWN_MODE.CASTER:
				buff.pass_turn()
			
			if buff.target == current_active and buff.cooldown_mode == Buff.COOLDOWN_MODE.TARGET:
				buff.pass_turn()
		
		active_index = (active_index + 1) % actors_count 
		current_active = actors.get_child(active_index)
	
	if not current_active is Puppet:
		turn_displayer_index = (turn_displayer_index + 1) % players.size()
		#current_active = players[active_index]
		turn_displayer.set_active(current_active)
		#turn_displayer.active_index = turn_displayer_index
	
	start_turn(current_active)
	
	ui.set_end_turn_button(current_active.team == 0)
	
	emit_signal("turn_ended")
	


func start_turn(actor):
	
	#var network_master = actor.is_network_master()
	
#	if actor.team == Actor.TEAMS.ENEMIES:
#		ui.set_end_turn_button(false)
#	else:
#		ui.set_end_turn_button(true)

	if actor.has_node("AiControl"):
		ui.set_end_turn_button(false)
	else:
		ui.set_end_turn_button(true)
	
	if actors.get_child(0) == actor:
		turn += 1
		ui.turn_count_label.text = turn as String
		#current_bonus_energy = min(max_bonus_energy,max(0, current_bonus_energy + (randi()%5 - 2)))
		current_bonus_energy = (min(3, turn) + randi()%6) + int((randi()%5==0)) + int(randi()%3==0) - int(randi()%4==0)
		bonus_energy_label.text = "+" + str(current_bonus_energy)
		#bonus_energy_label.text = "+" + str(min(turn-1, max_bonus_energy))
		music_player.play_random()
		emit_signal("turn_passed", [turn])
	
	actor.first_action = true
	actor.active = true
	
	yield(actor, "turn_ready")

	
	ui.set_preview_actor(actor, actor.team == Actor.TEAMS.CLIENT)

	set_preview_actor(actor.CLASS, actor, actor.is_puppet, actor.team == Actor.TEAMS.CLIENT)
	
	var spell_tooltip = get_tree().get_nodes_in_group("spell_info")[0]
	spell_tooltip.position = Vector2(36 + actor.spells.size()*18, 65)
	
	ui.active_effects = actor.current_buffs.duplicate(true)
	
	#if actor.team == Actor.TEAMS.SERVER:
	actor.connect("move_requested", self, "on_move_requested")
	actor.connect("spell_cast", self, "on_spell_cast")
	
	update_values(actor)
	if not actor is Puppet:
		turn_displayer.set_active(actor)
		#turn_displayer.active_index = turn_displayer_index
		
	
	

func summon(pos : Vector2, new_puppet : Puppet, caster) -> void:

	
	var actors_list : Node2D = get_tree().get_nodes_in_group("actors_list")[0]
	actors_list.add_child_below_node(caster, new_puppet, true)
	
	if actors_list.get_children().find(new_puppet) <= active_index:
		active_index += 1
#	actors_list.add_child(new_puppet)
#
#	var index = new_puppet.get_index()
#	while actors_list.get_child(index -1) != caster:
#		if actors_list.get_child(index -1) is Puppet:
#			if actors_list.get_child(index -1)._master == caster:
#				break
#		new_puppet.raise()
#		index = new_puppet.get_index()
		
	new_puppet.initialize_actor()
	
	new_puppet.position = pos
	new_puppet.set_outline_color(caster.outline_color)
	new_puppet.team = caster.team
	new_puppet.controlable = new_puppet.is_controlable
	new_puppet.is_multiplayer = false
	new_puppet._master = caster
	#new_puppet.set_network_master(caster.network_ID)
	if new_puppet.ai_controled or caster.has_node("AiControl"):
		new_puppet.add_child(AI_CONTROL_SCENE.instance())
	
	for spell_scene in new_puppet.spells_node.get_children():
		spell_scene.connect("jump_requested", self, "on_jump_requested")
		spell_scene.connect("slide_requested", self, "on_slide_requested")
		spell_scene.connect("push_requested", self, "on_push_requested")
		spell_scene.connect("spell_cast", self, "on_spell_cast")
		spell_scene.singleplayer = true
		if spell_scene.spell_ID != "DefaultSpell":
			new_puppet.spells.append(spell_scene.spell_ID)
	
	
	new_puppet.connect("died", self, "on_actor_died")
	new_puppet.connect("actor_pressed", self, "on_actor_pressed")
	



func on_actor_pressed(actor):
	if not selected_spell: 
		var preview = actor != current_active or not actor.team == Actor.TEAMS.SERVER
		set_preview_actor(actor.CLASS, actor, actor.is_puppet, preview)
	if placement_phase:
		set_preview_actor(actor.CLASS, actor, actor.is_puppet)
		if actor.is_network_master():
			selected_actor = actor
		else:
			selected_actor = null


func set_preview_actor(character : String, actor = null, is_puppet : bool = false, preview_only : bool = false):
	var flip_h = true
	var line_thickness : float = 0.5
	#actor_preview.visible = not character == "void"
	preview_only = actor != current_active or not actor.team == Actor.TEAMS.SERVER
	
	if actor:
		var spell_tooltip = get_tree().get_nodes_in_group("spell_info")[0]
		spell_tooltip.position = Vector2(36 + actor.spells.size()*18, 65)
		
		ui.set_preview_actor(actor, preview_only)


func on_back_button_pressed() -> void:
	ui.set_preview_actor(current_active, current_active.team == Actor.TEAMS.CLIENT)


func on_attack_button_pressed() -> void:
	var _spell = current_active.default_spell
	
	var _spell_unique_name = _spell.spell_ID
	
	on_spell_requested(_spell, _spell_unique_name)


func on_move_button_pressed() -> void:
	#var occupied_cells = tilemap.get_occupied_cells()
	var stamina = current_active.current_stamina
	if stamina == 0:
		print("No movement points left")
		movement_range.clear()
		return
		
	update_values(current_active, true)
	var draw_positions = floodfill.movement_range.duplicate(true)
	#var draw_positions = floodfill.flood_fill(tilemap.world_to_map(current_active.position), energy, false ,false, true)
	movement_range = [] ; spell_possible_positions = [] ; spell_possible_cells = draw_positions ; spell_preview_cells = []
	draw_node.unavailable_cells = []
	#draw_node.spell_preview = [] ; draw_node.spell_range = []
	spell_cell_preview = true
	selected_spell = movement_spell
	
	set_preview_actor(current_active.CLASS, current_active, current_active.is_puppet)
	
	for pos in draw_positions:
		movement_range.append(tilemap.map_to_world(pos))
		
	if stamina == 0:
		print("No movement points left")
		movement_range.clear()
		
	if current_active.moving == false:
		draw_node.movement_range = movement_range ; draw_node.spell_actor_position = current_active.position
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
				
#	if actor.team == Actor.TEAMS.ENEMIES:
#		path = pathfinder.search(actor_position, real_target_position)
#		update_values(actor)
#		move_actor(actor, path)
#
#		return
	
	var _range := []
	if not movement_range.has(real_target_position):
		for cell in movement_range:
			_range.append(tilemap.map_to_world(cell))
	else:
		_range = movement_range.duplicate()
		
	if _range.has(real_target_position) or actor.team == Actor.TEAMS.CLIENT or actor.has_node("AiControl"):
		if path.size() <= movement_points : #and energy_used < movement_points:
			path = pathfinder.search(actor_position , real_target_position)
#			if actor.is_invisible and actor.team == Actor.TEAMS.CLIENT:
#				draw_node.draw_path = path.duplicate(true)
			update_values(actor)
			spell_possible_cells = []
			move_actor(actor, path)
			movement_range = []
			#update_values(actor, true)


func on_jump_requested(target_position : Vector2, actor : Actor) -> void:
	jump (target_position, actor.get_path())


remotesync func jump(target_position : Vector2, actor_path : NodePath) -> void:
	var actor = get_node(actor_path)
	actor.position = tilemap.map_to_world(tilemap.world_to_map(target_position))


func on_slide_requested(target_position : Vector2, actor : Actor, strength : int = 1,  duration : float = 0.5) -> void:
	slide (target_position, actor.get_path(), strength, duration)


remotesync func slide(target_position : Vector2, actor_path : NodePath, strength : int = 1,  duration : float = 0.5) -> void:
	var real_target_pos: Vector2 = Vector2.ZERO
	
	var actor = get_node(actor_path)
	
	var shortest_distance = 10000
	if tilemap.world_to_map(target_position) in tilemap.get_occupied_cells():
		
		
		var debug = pathfinder.get_neighbors(target_position, false)
		for neighbor in debug:
			if neighbor == actor.position :
				return
			var distance = (neighbor - actor.position).length()
			if distance < shortest_distance:
				shortest_distance = distance
				real_target_pos = neighbor
				
	else:
		real_target_pos = target_position
		
	var path_ = pathfinder.search(actor.position, real_target_pos)
	path_.resize( min(strength, path_.size()) )
	print(path_)
	
	var tween = Tween.new()
	self.add_child(tween)
	
	tween.interpolate_property(actor, "position", 
		null,
		path_[-1],
		duration,
		Tween.TRANS_EXPO,
		Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	tween.queue_free()


func on_push_requested(origin : Vector2, caster : Actor, target : Actor, strength : int = 1, duration : float = 0.5) -> void:
	push (origin, caster.get_path(), target.get_path(), strength, duration)


remotesync func push(origin : Vector2, caster_path : NodePath, target_path : NodePath, strength : int = 1, duration : float = 0.5) -> void:
	
	var caster = get_node(caster_path)
	var target = get_node(target_path)
	
	var vector = (tilemap.world_to_map(target.position) - tilemap.world_to_map(origin)).normalized()
	
	var real_target_pos := Vector2.ZERO
	var overpush : int = 0
	
	if target.rooted :
		overpush = strength
	else:
		for i in strength :
			var try = tilemap.map_to_world(tilemap.world_to_map(target.position) + vector * (i+1))
			if try in tilemap.grid.keys() and not tilemap.world_to_map(try) in tilemap.get_occupied_cells():
				real_target_pos = try
			else:
				#overpush += 1
				overpush = strength-i
				break
	
	if not real_target_pos == Vector2.ZERO:
	
		var tween = Tween.new()
		self.add_child(tween)
		
		tween.interpolate_property(target, "position", 
			null,
			real_target_pos,
			duration/5,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_completed")
		tween.queue_free()
	
	if overpush:
		deal_push_damage(caster_path, target, overpush)


func deal_push_damage(caster_path : NodePath, target : Actor, amount : int) -> void:
	target.take_damage([push_damage * amount, "Physic"], caster_path)


func on_spell_requested(spell : Spell, spell_unique_name : String) -> void:
	
	var actor = current_active 
	
	if actor.is_multiplayer and not actor.is_network_master():
		return
		
	movement_range = []
	actor = current_active
	if spell.energy_cost <= actor.current_energy:
		if actor.moving == false:
			spell_possible_cells = spell.preview_spell_range()
			
			spell_possible_positions = []
			spell_cell_preview = true
		
			for pos in spell_possible_cells:
				spell_possible_positions.append(tilemap.map_to_world(pos))
			
			draw_node.spell_range = spell_possible_positions.duplicate(true)
			draw_node.movement_range = []
				
			draw_node.unavailable_cells = floodfill.unavailable_cells
			draw_node.unavailable_cells.append_array(unavailable_cells)
			draw_node.spell_actor_position = actor.position
			update()
		
		selected_spell = spell
		selected_spell_name = spell_unique_name
		
		print(actor.name + " requested spell : " + spell.spell_name)
		
	else:
		print("Not enough man")


func on_spell_cast(_spell : Spell, actor : Actor = current_active, target_dict : Dictionary = {}, crit : bool = false) -> void:
	update_values(actor)
		
	#CombatPrinter.print_new_line([actor.name, " cast ", _spell.spell_name ]) #, " on ", tilemap.get_occupied_cells()[tilemap.world_to_map(target_dict["origin"])]])
	
	if crit:
		actor.on_critical_hit()
	
	var animation_name : String
	
	if not _spell.animation:
		animation_name = "Explosion"
	else:
		animation_name = _spell.animation
	
	var animation_pos : Vector2
	
	match _spell.anim_mode:
		Spell.ANIM_MODE.ORIGIN:
			animation_pos = target_dict["origin"]
			
		Spell.ANIM_MODE.CASTER:
			animation_pos = _spell.caster.position
			
		Spell.ANIM_MODE.TARGETS:
			for target in target_dict:
				animation_pos = target_dict[target]
				
	if animation_name == "Explosion":
		
		var pos_array := []
		for cell in _spell.preview_spell_aoe(tilemap.world_to_map(target_dict["origin"])):
			pos_array.append(tilemap.map_to_world(cell))
		
		spells_fx.cast_positions = pos_array.duplicate()
		spells_fx.draw_cast_cells = true
		
		for pos in pos_array:
			spells_fx.play_anim(animation_name, pos, _spell.spell_type)
	else:
		spells_fx.play_anim(animation_name, animation_pos)

#	for _actor in actors.get_children():
#		if _actor.dead:
#			yield(_actor, "actor_cleaned")
	#yield(get_tree().create_timer(3.0),"timeout")
	end_turn_queue = max(0, end_turn_queue - 1)



func on_actor_died(actor):
	print(actor.name + " died")
	CombatPrinter.print_new_line([actor.name, " died"])
	if actor.active:
		r_end_turn()
		#return
	#yield(get_tree().create_timer(1.5),"timeout")
	for buff in get_tree().get_nodes_in_group("buffs"):
		if buff.caster == actor or buff.target == actor:
			buff.queue_free()
		
	
	
	#check if a team won:
	var client_team_empty : bool = true
	var server_team_empty : bool = true
	
	for actor_ in actors.get_children():
		if actor_ is Puppet or actor_ == actor or actor_.dead :
			continue
		if actor_.team == Actor.TEAMS.CLIENT:
			client_team_empty = false
		if actor_.team == Actor.TEAMS.SERVER:
			server_team_empty = false
	
	if client_team_empty and server_team_empty:
		end_game("draw")
	if client_team_empty:
		end_game("server")
	if server_team_empty:
		end_game("client")

#	var actor_index = actors.get_children().find(actor)
#
#	if not actor is Puppet:
#		var td_index = players.find(actor)
#
#		if td_index <= turn_displayer_index:
#			turn_displayer_index = max(0, turn_displayer_index-1)
	
#	if actor_index <= active_index and not (actor is Puppet and not actor.controlable):
#		active_index -= 1
	
	turn_displayer.remove_actor_icon(actor)
	#turn_displayer.active_index = turn_displayer_index
	
	emit_signal("actor_cleaned")
	
	actor.visible = false
	yield(get_tree().create_timer(1.0),"timeout")
	if is_instance_valid(actor):
		actor.free()
		
	if current_active != null and is_instance_valid(current_active):
		update_values(current_active, true)
	


func end_game(winner : String = "draw") -> void:
	game_ended = true
	level_count += 1
	match winner:
		"server" : 
			results_node.set_status(level_count, team == 0)
			results_node.set_winner_team(teams["Server"])
			results_node.set_looser_team(teams["Client"])
		"client" :
			results_node.set_status(level_count, team == 1)
			results_node.set_winner_team(teams["Client"])
			results_node.set_looser_team(teams["Server"])
		"draw" :
			results_node.set_status(level_count, false)
			results_node.set_winner_team(teams["Client"])
			results_node.set_looser_team(teams["Server"])
			
	if winner == "server":
		for _actor in teams["Client"].values():
			var actor_name = _actor["class"][0]
			var game_data_res := ResourceLoader.load(DATA_PATH)
			
			if game_data_res.characters_unlock[actor_name] == false:
				game_data_res.characters_unlock[actor_name] = true
				ResourceSaver.save(DATA_PATH, game_data_res)
				
				var unlock_popup := preload("res://Scenes/UnlockPopup.tscn").instance()
				add_child(unlock_popup)
				unlock_popup.set_actor(actor_name)
			
			
	#results_node.connect("title_screen_pressed", self, "on_title_screen_pressed")
			
	ui.visible = false
	results_node.visible = true
	
	camera.zoom = camera.BASE_CAM_ZOOM
	camera.position = camera.BASE_CAM_POS
	
	music_player.end()


func on_title_screen_pressed(victory : bool) -> void:
	emit_signal("game_finished", victory)


remotesync func move_actor(actor, moving_path) -> void:
	
	if actor is EncodedObjectAsID:
		actor = current_active
	
	var moving_speed : float
	if moving_path.size() < run_treshold :
		moving_speed = walking_speed
	elif moving_path.size() >= run_treshold :
		moving_speed = running_speed
	
	actor.moving = true
	
	var tween = Tween.new()
	self.add_child(tween)
	
	var stamina_spent : int = 0
	
	for pos in moving_path :
		
		if tilemap.get_occupied_cells().keys().has(tilemap.world_to_map(pos)):
			CombatPrinter.print_new_line(["Something is in the way!"])
			for _pos in draw_node.draw_path.duplicate():
				draw_node.call("pop_front_path")
			break
		
		#orientates the actor depending on the move direction
		actor.sprite.flip_h = pos.x < actor.position.x
		
#		if pos.x > actor.position.x :
#			if pos.y > actor.position.y:
#				#actor.sprite.animation = "IdleDown"
#				actor.sprite.flip_h = false
#			if pos.y < actor.position.y:
#				#actor.sprite.animation = "IdleUp"
#				actor.sprite.flip_h = false
#		if pos.x < actor.position.x :
#			if pos.y > actor.position.y:
#				#actor.sprite.animation ="IdleDown"
#				actor.sprite.flip_h = true
#			if pos.y < actor.position.y:
#				#actor.sprite.animation = "IdleUp"
#				actor.sprite.flip_h = true
				
		#moves the player to current target cell 
		tween.interpolate_property(actor, "position", actor.position , pos , moving_speed)
		tween.start()
		#wait for movement to finish
		yield(tween, "tween_completed")
		
		actor.current_stamina -= 1
		stamina_spent += 1
		update_values(actor)
		
		draw_node.call("pop_front_path")
		
	path = []
	actor.moving = false
	update_values(actor, true)
	actor.emit_signal("stamina_spent", [stamina_spent])
	actor.emit_signal("move_finished")


func update_values(actor, update_mov_range : bool = false) -> void:
	
	active_index = actors.get_children().find(current_active)
	draw_node.movement_points = actor.current_stamina
	draw_node.spell_range = []
	draw_node.movement_range = []
	draw_node.unavailable_cells.clear()

	ui.energy = actor.current_energy
	ui.stamina = actor.current_stamina
	ui.cooldowns = actor.cooldowns.duplicate(true)
	ui.set_preview_actor(actor, current_active.team == Actor.TEAMS.CLIENT)
	
	if update_mov_range:
		#updates mov range without thread (possible freeze)
		
		var _stamina = current_active.current_stamina if not current_active.frozen else floor(current_active.current_stamina/2)
		movement_range = floodfill.flood_fill(tilemap.world_to_map(current_active.position), _stamina, false, false, true).duplicate(true)
		
		#var array = [tilemap.world_to_map(current_active.position), current_active.current_energy]
		
		#thread.start(self, "thread_update_move_range", array)
		
		floodfill.movement_range = movement_range.duplicate(true)


func reset_values() -> void:
	movement_range.clear()
	draw_node.spell_range.clear()
	draw_node.movement_range.clear()
	draw_node.unavailable_cells.clear()
	unavailable_cells.clear()
	spell_possible_cells.clear()
	spell_possible_positions.clear()
	selected_spell = null


func fade_out() -> void:
	var new_layer = CanvasLayer.new()
	add_child(new_layer)
	new_layer.layer = 100
	var color_rect = ColorRect.new()
	new_layer.add_child(color_rect)
	color_rect.show_on_top = true
	color_rect.rect_position = Vector2(-123,-100)
	color_rect.rect_size = Vector2(1920, 1080)
	color_rect.color = Color(0.0,0.0,0.0,0.0)
	var tween := Tween.new()
	add_child(tween)
	tween.interpolate_property(color_rect, "color",
	null, Color(0.0,0.0,0.0,1.0),
	2.0, Tween.TRANS_LINEAR)
	
	tween.start()
	yield(tween,"tween_completed")
	tween.queue_free()
