extends Spell

#var spells_list = preload("res://Spells/SpellsList.tres")
#var classes = preload("res://Data/Classes.tres")
#
##onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]
##onready var floodfill = get_tree().get_nodes_in_group("floodfill")[0]
#
#func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
#	var random_class = randi() % 20
#	var random_spell = randi() % 5
#	var _class_name_ : String = classes.characters_list[random_class][0]
#	var _spell_name = spells_list.get(_class_name_)[random_spell]
#
#	var spell_scene : Spell = load(SPELLS_PATH + _class_name_ + "/" + _spell_name + "/" + _spell_name + ".tscn").instance()
#
#	spell_scene.ignore_spell = true
#
#	caster.spells_node.add_child(spell_scene)
#	spell_scene.connect("jump_requested", level, "on_jump_requested")
#	spell_scene.connect("slide_requested", level, "on_slide_requested")
#	spell_scene.connect("push_requested", level, "on_push_requested")
#	spell_scene.connect("spell_cast", level, "on_spell_cast")
#
#	var occupied_cells = tilemap.get_occupied_cells()
#	var random_target : Actor = occupied_cells.values()[randi() % occupied_cells.size()]
#
#	assert(is_instance_valid(spell_scene.caster))
#
#	var cast_cells
#	var _cast_cells
#
#	var origin_cell : Vector2
#
#	if spell_scene.cast_mode == Spell.CAST_MODE.ORIGIN:
#		origin_cell = tilemap.world_to_map(random_target.position)
#	elif spell_scene.cast_mode == Spell.CAST_MODE.CUSTOM:
#		origin_cell = tilemap.world_to_map(spell_scene.get_custom_origin())
#
#	_cast_cells = floodfill.flood_fill(origin_cell, spell_scene.aoe, true, false)
#
#	match spell_scene.aoe_mode:
#
#		Spell.AOE_MODE.DEFAULT:
#			pass
#		Spell.AOE_MODE.CROSS:
#			for cell in _cast_cells.duplicate():
#				if not cell.x == origin_cell.x and not cell.y == origin_cell.y:
#					_cast_cells.erase(cell)
#
#		Spell.AOE_MODE.SQUARE:
#			var sides_x := Vector2(origin_cell.x-spell_scene.aoe, origin_cell.x+spell_scene.aoe)
#			var sides_y := Vector2(origin_cell.y-spell_scene.aoe, origin_cell.y+spell_scene.aoe)
#			_cast_cells = floodfill.flood_fill(origin_cell, spell_scene.aoe*2, true, false)
#			for cell in _cast_cells.duplicate():
#				if not (sides_x.x <= cell.x and cell.x <= sides_x.y) or not (sides_y.x <= cell.y and cell.y <= sides_y.y):
#					_cast_cells.erase(cell)
#
#		Spell.AOE_MODE.LINE_PARALLEL:
#			#choose a random orientation
#			var random : Vector2 = Vector2(randi()%2, randi()%2)
#			if random.x:
#				if random.y:
#					for cell in _cast_cells.duplicate():
#						if not cell.x == origin_cell.x or cell.y > origin_cell.y:
#							_cast_cells.erase(cell)
#				else:
#					for cell in _cast_cells.duplicate():
#						if not cell.x == origin_cell.x or cell.y < origin_cell.y:
#							_cast_cells.erase(cell)
#			else:
#				if random.y:
#					for cell in _cast_cells.duplicate():
#						if not cell.y == origin_cell.y or cell.x > origin_cell.x:
#							_cast_cells.erase(cell)
#				else:
#					for cell in _cast_cells.duplicate():
#						if not cell.y == origin_cell.y or cell.x < origin_cell.x:
#							_cast_cells.erase(cell)
#
#		Spell.AOE_MODE.LINE_PERPENDICULAR:
#			var random = randi()%2
#			if random:
#				for cell in _cast_cells.duplicate():
#					if not cell.y == origin_cell.y:
#						_cast_cells.erase(cell)
#			else:
#				for cell in _cast_cells.duplicate():
#					if not cell.x == origin_cell.x:
#						_cast_cells.erase(cell)
#
#		Spell.AOE_MODE.DIAGONAL:
#			for cell in _cast_cells.duplicate():
#				if not tilemap.map_to_world(cell).x == tilemap.map_to_world(origin_cell).x and not tilemap.map_to_world(cell).y == tilemap.map_to_world(origin_cell).y:
#					_cast_cells.erase(cell)
#
#		Spell.AOE_MODE.STAR:
#			for cell in _cast_cells.duplicate():
#				if not cell.x == origin_cell.x and not cell.y == origin_cell.y:
#					if not tilemap.map_to_world(cell).x == tilemap.map_to_world(origin_cell).x and not tilemap.map_to_world(cell).y == tilemap.map_to_world(origin_cell).y:
#						_cast_cells.erase(cell)
#
#
#	cast_cells = _cast_cells.duplicate(true)
#
#
#	occupied_cells = tilemap.get_occupied_cells()
#	var target_cells = {} #keys : cells , values : actors
#
#	for cell in cast_cells:
#
#		target_cells["origin"] = target_dict["origin"]
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
#
#
#	spell_scene.cast_spell(target_cells, crit)
#
#	yield(spell_scene,"spell_cast")
#
#	spell_scene.queue_free()
