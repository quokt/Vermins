extends Node
class_name Spell

signal jump_requested(target_position, actor)
signal slide_requested(target_position, actor, strength, duration)
signal push_requested(origin, target, strength, duration)
signal spell_cast(spell, actor, target_dict)

export (String) var spell_ID = ""
export (String) var character = ""
export (bool) var _puppet = false

const SPELLS_PATH : String = "res://Spells/"
const BUFFS_PATH : String = "res://Buffs/"

onready var level = get_tree().get_nodes_in_group("level")[0]
onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]
onready var tilemap = get_tree().get_nodes_in_group("nav")[0]

enum ANIM_MODE {ORIGIN, TARGETS, CASTER}
enum CAST_MODE {ORIGIN, CUSTOM}
enum CELL_MODE {EMPTY, FULL, BOTH}
enum AOE_MODE {DEFAULT, CROSS, DIAGONAL, STAR, LINE_PARALLEL, LINE_PERPENDICULAR, SQUARE}
enum RANGE_MODE {DEFAULT, LINE, DIAGONAL, STAR}
enum SPELL_TYPE {PHYSIC, MAGIC}
enum TARGETS {ALL, ENEMIES, ALLIES, CASTER, ALL_NO_CASTER, EMPTY}


var default_spell : bool = false
var singleplayer : bool = false

var spell_effects : Array #stores selected effect flags from SpellResource
var cast_this_turn : int = 0

var anim_mode 
var animation : String

var min_range : int
var max_range : int

var icon : Texture

var spell_name : String
var description : String
var critical_effect : String

var cost : int
#var bonus_energy : int

var cast_mode
var cell_mode

var energy_cost : int

var sight_needed : bool
var range_modif : bool
var range_mode

var max_per_turn : int
var base_cooldown : int

var min_power : int
var max_power : int

var crit_min_power : int
var crit_max_power : int
var crit_chance : float

var spell_type

var aoe : int
var aoe_mode

var cooldown : int = 0 setget set_cooldown

var buff_name : String
var buff_targets

var ai_targets

var caster : Actor

var ignore_spell : bool = false #used to add temporary spells


func is_cell_valid(cell : Vector2) -> bool:
	if caster == null or not is_instance_valid(caster):
		return false
		
	var spell_range = preview_spell_range().duplicate()
	if cell_mode == CELL_MODE.EMPTY or ai_targets == TARGETS.EMPTY:
		return cell in spell_range and not cell in tilemap.get_occupied_cells()
		
	elif cell_mode == CELL_MODE.FULL:
		return cell in spell_range and cell in tilemap.get_occupied_cells()
	
	else:
		return cell in spell_range
	


func get_valid_cell():
	if caster == null or not is_instance_valid(caster):
		return null
		
	if cell_mode == CELL_MODE.EMPTY or ai_targets == TARGETS.EMPTY:
		var spell_range = preview_spell_range().duplicate()
		spell_range.shuffle()
		for cell in spell_range:
			if not cell in tilemap.get_occupied_cells():
				return cell
	else:
		var targets : Dictionary = tilemap.get_occupied_cells().duplicate()
		var avoid : Array = []
		for cell in targets.keys():
			if targets[cell] is Actor and is_instance_valid(targets[cell]):
				
				if targets[cell].team != caster.team and targets[cell].is_invisible:
					#ignore invisible actors if they have a different team
					continue
					
				match ai_targets:
					TARGETS.ALL:
						pass
					TARGETS.ALLIES:
						if targets[cell].team != caster.team:
							avoid.append(cell)
							targets.erase(cell)
					TARGETS.ENEMIES:
						if targets[cell].team == caster.team:
							avoid.append(cell)
							targets.erase(cell)
					TARGETS.CASTER:
						return caster.get_cell()
					TARGETS.ALL_NO_CASTER:
						if targets[cell] == caster:
							targets.erase(cell)
			else:
				targets.erase(cell)
		
		var best_cell := Vector2.ZERO
		var max_targets : int = 0
		for cell in preview_spell_range():
			var targets_count : int =  0
			for _cell in preview_spell_aoe(cell):
				if _cell in targets.keys():
					targets_count += 1
				elif _cell in avoid:
					targets_count -= 1
			if targets_count > max_targets:
				max_targets = targets_count
				best_cell = cell
				
		return best_cell
	



func preview_spell_range(special_range_modif : int = 0) -> Array:
	var return_array := []
	var count_occupied
	var spell_max_cells
	var spell_min_cells
	var unavailable_cells : Array = []
	var _max_range : int
	if range_modif:
		_max_range = max(max_range + caster.current_range, min_range)
	elif range_modif == false:
		_max_range = max_range
	
	if special_range_modif != 0:
		_max_range = max(max_range + special_range_modif, min_range)
	
	
	count_occupied = not cell_mode == CELL_MODE.EMPTY
		
	spell_max_cells = floodfill.flood_fill(tilemap.world_to_map(caster.position), _max_range, count_occupied, sight_needed)
	spell_min_cells = floodfill.flood_fill(tilemap.world_to_map(caster.position), (min_range-1), true, false)
	
	for cell in spell_max_cells :
		if !spell_min_cells.has(cell):
			return_array.append(cell)
		
	match range_mode:
		RANGE_MODE.DEFAULT:
			pass
		RANGE_MODE.LINE:
			for cell in return_array.duplicate():
				if not cell.x == tilemap.world_to_map(caster.position).x and not cell.y == tilemap.world_to_map(caster.position).y:
					return_array.erase(cell)
			for cell in floodfill.unavailable_cells.duplicate():
				if not cell.x == tilemap.world_to_map(caster.position).x and not cell.y == tilemap.world_to_map(caster.position).y:
					floodfill.unavailable_cells.erase(cell)
		RANGE_MODE.DIAGONAL:
			for cell in return_array.duplicate():
				if not tilemap.map_to_world(cell).x == caster.position.x and not tilemap.map_to_world(cell).y == caster.position.y:
					return_array.erase(cell)
			for cell in floodfill.unavailable_cells.duplicate():
				if not tilemap.map_to_world(cell).x == caster.position.x and not tilemap.map_to_world(cell).y == caster.position.y:
					floodfill.unavailable_cells.erase(cell)
		RANGE_MODE.STAR:
			for cell in return_array.duplicate():
				if not cell.x == tilemap.world_to_map(caster.position).x and not cell.y == tilemap.world_to_map(caster.position).y:
					if not tilemap.map_to_world(cell).x == caster.position.x and not tilemap.map_to_world(cell).y == caster.position.y:
						return_array.erase(cell)
			for cell in floodfill.unavailable_cells.duplicate():
				if not cell.x == tilemap.world_to_map(caster.position).x and not cell.y == tilemap.world_to_map(caster.position).y:
					if not tilemap.map_to_world(cell).x == caster.position.x and not tilemap.map_to_world(cell).y == caster.position.y:
						floodfill.unavailable_cells.erase(cell)
		
	match cell_mode:
		CELL_MODE.EMPTY:
			for cell in tilemap.get_occupied_cells().keys():
				if cell in return_array:
					return_array.erase(cell)
					unavailable_cells.append(cell)
		CELL_MODE.FULL:
			for cell in return_array.duplicate():
				if not cell in tilemap.get_occupied_cells().keys():
					return_array.erase(cell)
					unavailable_cells.append(cell)
		CELL_MODE.BOTH:
			pass
			
	for cell in floodfill.unavailable_cells.duplicate():
		if cell in spell_min_cells:
			floodfill.unavailable_cells.erase(cell)
			
	level.unavailable_cells = unavailable_cells.duplicate()
	
	if not sight_needed:
		floodfill.unavailable_cells.clear()
	
	return return_array


func preview_spell_aoe(origin_cell : Vector2) -> Array:
	var spell_preview_cells = floodfill.flood_fill(origin_cell, aoe, true, false)
	
	match aoe_mode:
		AOE_MODE.DEFAULT:
			pass
		AOE_MODE.CROSS:
			for cell in spell_preview_cells.duplicate():
				if not cell.x == origin_cell.x and not cell.y == origin_cell.y:
					spell_preview_cells.erase(cell)
					
		AOE_MODE.SQUARE:
			var sides_x := Vector2(origin_cell.x-aoe, origin_cell.x+aoe)
			var sides_y := Vector2(origin_cell.y-aoe, origin_cell.y+aoe)
			spell_preview_cells = floodfill.flood_fill(origin_cell, aoe*2, true, false)
			for cell in spell_preview_cells.duplicate():
				if not (sides_x.x <= cell.x and cell.x <= sides_x.y) or not (sides_y.x <= cell.y and cell.y <= sides_y.y):
					spell_preview_cells.erase(cell)
					
		AOE_MODE.LINE_PARALLEL:
			var caster_cell : Vector2 = tilemap.world_to_map(caster.position)
			if origin_cell.x == caster_cell.x:
				if origin_cell.y < caster_cell.y:
					for cell in spell_preview_cells.duplicate():
						if not cell.x == origin_cell.x or cell.y > origin_cell.y:
							spell_preview_cells.erase(cell)
				elif origin_cell.y > caster_cell.y:
					for cell in spell_preview_cells.duplicate():
						if not cell.x == origin_cell.x or cell.y < origin_cell.y:
							spell_preview_cells.erase(cell)
							
			elif origin_cell.y == caster_cell.y:
				if origin_cell.x < caster_cell.x:
					for cell in spell_preview_cells.duplicate():
						if not cell.y == origin_cell.y or cell.x > origin_cell.x:
							spell_preview_cells.erase(cell)
				elif origin_cell.x > caster_cell.x:
					for cell in spell_preview_cells.duplicate():
						if not cell.y == origin_cell.y or cell.x < origin_cell.x:
							spell_preview_cells.erase(cell)
		
		AOE_MODE.LINE_PERPENDICULAR:
			var caster_cell : Vector2 = tilemap.world_to_map(caster.position)
			if origin_cell.x == caster_cell.x:
				for cell in spell_preview_cells.duplicate():
					if not cell.y == origin_cell.y:
						spell_preview_cells.erase(cell)
			elif origin_cell.y == caster_cell.y:
				for cell in spell_preview_cells.duplicate():
					if not cell.x == origin_cell.x:
						spell_preview_cells.erase(cell)

		AOE_MODE.DIAGONAL:
			for cell in spell_preview_cells.duplicate():
				if not tilemap.map_to_world(cell).x == tilemap.map_to_world(origin_cell).x and not tilemap.map_to_world(cell).y == tilemap.map_to_world(origin_cell).y:
					spell_preview_cells.erase(cell)

		AOE_MODE.STAR:
			for cell in spell_preview_cells.duplicate():
				if not cell.x == origin_cell.x and not cell.y == origin_cell.y:
					if not tilemap.map_to_world(cell).x == tilemap.map_to_world(origin_cell).x and not tilemap.map_to_world(cell).y == tilemap.map_to_world(origin_cell).y:
						spell_preview_cells.erase(cell)
						
	return spell_preview_cells.duplicate()


func _ready() -> void:
	var resource = get_spell_resource()
	
	if resource == null:
		return
		
	min_range = resource.min_range
	max_range = resource.max_range
	
	spell_effects = get_flags_from_int(resource.spell_effects)
	print(spell_effects)
	
	icon = resource.icon

	spell_name = resource.spell_name
	description = resource.description
	critical_effect = resource.critical_effect

	cost = resource.cost
	#bonus_energy = resource.bonus_energy
	
	animation = resource.animation
	
	anim_mode = resource.anim_mode
	cast_mode = resource.cast_mode
	cell_mode= resource.cell_mode

	energy_cost = resource.energy_cost

	sight_needed = resource.sight_needed
	range_modif = resource.range_modif
	range_mode= resource.range_mode
	
	max_per_turn = resource.max_per_turn
	base_cooldown = resource.cooldown

	min_power = resource.min_power
	max_power = resource.max_power
	
	crit_min_power = resource.crit_min_power
	crit_max_power = resource.crit_max_power
	crit_chance = resource.crit_chance
	
	var _spell_type
	match resource.spell_type:
		SpellResource.SPELL_TYPE.PHYSIC:
			_spell_type = "Physic"
		#SpellResource.SPELL_TYPE.PSYCHIC:
			#_spell_type = "Psychic"
		SpellResource.SPELL_TYPE.MAGIC:
			_spell_type = "Magic"
			
	spell_type= _spell_type

	aoe = resource.aoe
	aoe_mode = resource.aoe_mode
	
	buff_name = resource.buff_name
	buff_targets = resource.buff_targets
	
	ai_targets = resource.ai_targets
	
	if get_parent().get_parent() is Actor:
		caster = get_parent().get_parent()


func get_flags_from_int(int_flags : int) -> Array:
	var selected_flags : Array = []
	#hard coded flags detector -> key = effect, value = true/false
	var _flags: Dictionary = {
	attack = int_flags in [1, 3, 5, 7, 9, 11, 13, 15],
	heal = int_flags in [2, 3, 6, 7, 10, 11, 14, 15],
	jump = int_flags in [4, 5, 6, 7, 12, 13, 14, 15],
	buff = int_flags in [8, 9, 10, 11, 12, 13, 14, 15]
	}
	for flag in _flags:
		if _flags[flag] == true:
			selected_flags.append(flag as String)
	
	return selected_flags


func get_spell_resource() -> SpellResource:
	if (not character or spell_ID == "") and not default_spell:
		return null
		
	var resource_path
	if _puppet:
		resource_path = SPELLS_PATH + "Puppets/" + character + "/" + spell_ID + "/" + spell_ID + ".tres"
	elif default_spell:
		resource_path = SPELLS_PATH + character + "/DefaultSpell/DefaultSpell.tres"
	else:
		resource_path = SPELLS_PATH + character + "/" + spell_ID + "/" + spell_ID + ".tres"
		
	var spell_resource = load(resource_path)
		
	return spell_resource

#target_dict : key = cells ; value = actor
func autocast(target_dict : Dictionary) -> void:
	if "attack" in spell_effects:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				_deal_damage(target)
			
	if "heal" in spell_effects:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				_heal(target)
			
	if "jump" in spell_effects:
		request_jump(target_dict["origin"])
		
	if "buff" in spell_effects:
		var crit := false
		if buff_name != "":
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					match buff_targets:
						TARGETS.ALL:
							_add_buff(target, buff_name, crit)
						TARGETS.ALL_NO_CASTER:
							if target != caster:
								_add_buff(target, buff_name, crit)
						TARGETS.CASTER:
							if target == caster:
								_add_buff(target, buff_name, crit)
						TARGETS.ALLIES:
							if target.team == caster.team:
								_add_buff(target, buff_name, crit)
						TARGETS.ENEMIES:
							if target.team != caster.team:
								_add_buff(target, buff_name, crit)
								
			if "jump" in spell_effects:
				_add_buff(caster, buff_name, crit)


func crit_autocast(target_dict : Dictionary) -> void:
	if "attack" in spell_effects:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				_deal_damage(target, crit_min_power, crit_max_power)
			
	if "heal" in spell_effects:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				_heal(target, crit_min_power, crit_max_power)
			
	if "jump" in spell_effects:
		request_jump(target_dict["origin"])
		
	if "buff" in spell_effects:
		var crit := true
		if buff_name != "":
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					match buff_targets:
						TARGETS.ALL:
							_add_buff(target, buff_name, crit)
						TARGETS.ALL_NO_CASTER:
							if target != caster:
								_add_buff(target, buff_name, crit)
						TARGETS.CASTER:
							if target == caster:
								_add_buff(target, buff_name, crit)
						TARGETS.ALLIES:
							if target.team == caster.team:
								_add_buff(target, buff_name, crit)
						TARGETS.ENEMIES:
							if target.team != caster.team:
								_add_buff(target, buff_name, crit)
								
			if "jump" in spell_effects:
				_add_buff(caster, buff_name, crit)


func cast_spell(target_position: Vector2, force_crit : bool = false, _ignore_spell : bool = false) -> void:
	if caster == null or not is_instance_valid(caster):
		print("Couldn't find any caster ; spell won't be cast")
		return
		
	var cast_cells
	var _cast_cells
	
	var origin_cell : Vector2
	
	if cast_mode == CAST_MODE.ORIGIN:
		origin_cell = tilemap.world_to_map(target_position)
	elif cast_mode == CAST_MODE.CUSTOM:
		origin_cell = tilemap.world_to_map(get_custom_origin())
	
	cast_cells = preview_spell_aoe(origin_cell)
	#cast_cells = _cast_cells.duplicate(true)
	
	var occupied_cells = tilemap.get_occupied_cells()
	var target_cells = {} #keys : cells , values : actors
		
	for cell in cast_cells:
		
		target_cells["origin"] = target_position
			
		if cell_mode == CELL_MODE.FULL or cell_mode == CELL_MODE.BOTH:
			#if spell is in mode "full cell" or "full or empty":
			if occupied_cells.keys().has(cell):
				#add every occupied cell in targets dictionary
				if occupied_cells[cell]!= null and is_instance_valid(occupied_cells[cell]) and not occupied_cells[cell].dead:
					target_cells[cell] = occupied_cells[cell]
				
		if cell_mode == CELL_MODE.EMPTY:
			#add every cell as "empty" in targets dictionary
			target_cells[cell] = "empty"
		
	var crit : bool = force_crit or randf() <= crit_chance + caster.crit_chance_bonus
	
	var string_end : String = "" if not crit else " (critical hit!)"
	
	if not singleplayer and caster.is_network_master():
		CombatPrinter.print_new_line([caster.name, " cast ", spell_name, string_end ])
	elif singleplayer:
		CombatPrinter.print_new_line([caster.name, " cast ", spell_name, string_end ])
	
	if not ignore_spell and not _ignore_spell:
		caster.current_energy -= self.energy_cost
		caster.emit_signal("energy_spent", [energy_cost])
		cast_this_turn += 1
		if max_per_turn > 0 and cast_this_turn == max_per_turn:
			set_cooldown(1)
		else:
			set_cooldown(base_cooldown)
	
	if caster.has_node("ActorAnimation"):
		if not singleplayer:
			caster.get_node("ActorAnimation").rpc("r_play", "spell_cast")
		else:
			caster.get_node("ActorAnimation").r_play("spell_cast")
		yield(caster.get_node("ActorAnimation"), "animation_finished")
	
	
	
	_cast_spell(target_cells, crit)
	
	emit_signal("spell_cast", self, caster, target_cells, crit)


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	print("No _cast_spell function in ", self , ". Spell will be autocast")
	
	if crit:
		crit_autocast(target_dict)
		
	else:
		autocast(target_dict)


func _deal_damage(target, _min_power = min_power, _max_power = max_power) -> int :
	
	var rand_number = spell_rng(_min_power, _max_power)
	
	var caster_damage = rand_number * caster.damage_type_modif[spell_type]["Coef"] + caster.damage_type_modif[spell_type]["Flat"]
	caster_damage = caster_damage * caster.damage_output_coef_modif + caster.damage_output_flat_modif
	
	if not singleplayer:
		target.rpc("take_damage" , [caster_damage, spell_type], caster.get_path() )
	else:
		target.take_damage( [caster_damage, spell_type], caster.get_path() )
		
	return caster_damage


func _heal(target, _min_power = min_power, _max_power = max_power) -> int:
	
	var rand_number = spell_rng(_min_power, _max_power)
	
	var caster_heal = rand_number * caster.damage_type_modif[spell_type]["Coef"] + caster.damage_type_modif[spell_type]["Flat"]
	caster_heal = caster_heal * caster.healing_output_coef_modif + caster.healing_output_flat_modif
	
	if not singleplayer:
		target.rpc("heal" , [caster_heal, spell_type] )
	else:
		target.heal( [caster_heal, spell_type])
	
	return caster_heal


func _lifesteal(target, _min_power = min_power, _max_power = max_power, lifesteal_amount : float = 0.5, custom_heal_target : Actor = null) -> int:
	
	caster = get_parent().get_parent()
	
	var heal_target = custom_heal_target if custom_heal_target else caster
	
	var rand_number = spell_rng(_min_power, _max_power)
	
	
	var caster_damage = rand_number * caster.damage_type_modif[spell_type]["Coef"] + caster.damage_type_modif[spell_type]["Flat"]
	caster_damage = caster_damage * caster.damage_output_coef_modif + caster.damage_output_flat_modif
	
	if not singleplayer:
		target.rpc("take_damage" , [caster_damage, spell_type], caster.get_path() )
	else:
		target.take_damage( [caster_damage, spell_type], caster.get_path() )
	
	
	var caster_heal = caster_damage * lifesteal_amount
	caster_heal = caster_heal * caster.healing_output_coef_modif + caster.healing_output_flat_modif
	
	if not singleplayer:
		heal_target.rpc("heal" , [caster_heal, spell_type] )
	else:
		heal_target.heal( [caster_heal, spell_type])
	
	return caster_damage


#TODO : add a bool crit argument to this function and add crit effects to buffs
func _add_buff(target , buff_name_ : String = buff_name, critical : bool = false) -> void:
	
	caster = get_parent().get_parent()
	
	if not singleplayer:
		target.rpc("add_buff", buff_name_, caster.get_path(), critical)
	else:
		target.add_buff(buff_name_, caster.get_path(), critical)


func summon(pos, new_puppet, _caster = caster) -> void:
	level.summon(pos, new_puppet, _caster)


remotesync func _summon(_pos : Vector2, crit : bool = false) -> void:
	#to be overriden by subclass
	pass


func request_jump(target_position : Vector2, target = caster) -> void:
	emit_signal("jump_requested", target_position, target)


func request_slide(target_position : Vector2, target , strength : int = 1 ,duration : float = 1.0) -> void:
	emit_signal("slide_requested", target_position, target, strength, duration)


func request_push(origin : Vector2, target, strength : int = 1, duration : float = 1.0) -> void:
	emit_signal("push_requested", origin, caster, target, strength, duration)


func spell_rng(min_ = min_power, max_ = max_power) -> int :
	if caster.jinx == true:
		return int(min_)
	elif caster.third_eye == true:
		return int(max_)
	else:
		return int(min_ + (randi() % (int(max_ - min_) + 1)))


func get_custom_origin() -> Vector2:
	return caster.position


func set_cooldown(value : int) -> void:
	cooldown = value
	if caster != null and is_instance_valid(caster):
		caster.cooldowns[spell_ID] = value
