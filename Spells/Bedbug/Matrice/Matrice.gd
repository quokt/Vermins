extends Spell

var spells_list = preload("res://Spells/SpellsList.tres")
var classes = preload("res://Data/Classes.tres")
onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]

#onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]
#onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	randomize()
	
	var random_class = randi() % 20
	var random_spell = randi() % 5
	var _class_name_ : String = classes.characters_list[random_class][0]
	var _spell_name = spells_list.get(_class_name_)[random_spell]
	
	var spell_scene : Spell = load(SPELLS_PATH + _class_name_ + "/" + _spell_name + "/" + _spell_name + ".tscn").instance()
	
	spell_scene.ignore_spell = true
	
	caster.spells_node.add_child(spell_scene)
	spell_scene.connect("jump_requested", level, "on_jump_requested")
	spell_scene.connect("slide_requested", level, "on_slide_requested")
	spell_scene.connect("push_requested", level, "on_push_requested")
	spell_scene.connect("spell_cast", level, "on_spell_cast")
	
	spell_scene.singleplayer = singleplayer
	spell_scene.anim_mode = Spell.ANIM_MODE.ORIGIN
	
	var occupied_cells = tilemap.get_occupied_cells()
	var random_target : Actor = occupied_cells.values()[randi() % occupied_cells.size()]
	
	assert(is_instance_valid(spell_scene.caster))
	
	var cast_cells
	var _cast_cells
	
	var origin_cell : Vector2
	
	var neighbors := []

	if spell_scene.cell_mode == Spell.CELL_MODE.EMPTY:
		var i = 0
		while neighbors.empty() and i<12:
			neighbors = pathfinder.get_neighbors(random_target.position)
			if not neighbors.empty():
				break
			random_target = occupied_cells.values()[randi()% occupied_cells.size()]
			i += 1
		origin_cell = tilemap.world_to_map(neighbors[randi()% neighbors.size()])
	
	elif spell_scene.cast_mode == Spell.CAST_MODE.ORIGIN:
		origin_cell = tilemap.world_to_map(random_target.position)
	elif spell_scene.cast_mode == Spell.CAST_MODE.CUSTOM:
		origin_cell = tilemap.world_to_map(spell_scene.get_custom_origin())
	
	cast_cells = spell_scene.preview_spell_aoe(origin_cell).duplicate(true)

	occupied_cells = tilemap.get_occupied_cells()
#	var target_cells = {} #keys : cells , values : actors
#
#	for cell in cast_cells:
#
#		target_cells["origin"] = tilemap.map_to_world(origin_cell)
#
#		if spell_scene.cell_mode == Spell.CELL_MODE.FULL or spell_scene.cell_mode == Spell.CELL_MODE.BOTH:
#			#if spell is in mode "full cell" or "full or empty":
#			if occupied_cells.keys().has(cell):
#				#add every occupied cell in targets dictionary
#				target_cells[cell] = occupied_cells[cell]
#
#		if spell_scene.cell_mode == Spell.CELL_MODE.EMPTY:
#			#add every cell as "empty" in targets dictionary
#			target_cells[cell] = "empty"
				
		
	spell_scene.cast_spell(tilemap.map_to_world(origin_cell), crit)
	
	yield(spell_scene,"spell_cast")
	
	yield(get_tree().create_timer(6.0),"timeout")
	
	spell_scene.queue_free()
