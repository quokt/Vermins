extends Spell

onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
#onready var tilemap = get_tree().get_nodes_in_group("nav")[0]

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var actors_healed := []
	var buffer := []
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team == caster.team:
				buffer.append(target)
				
	while not buffer.empty():
		var _target = buffer.pop_front()
		_heal(_target)
		actors_healed.append(_target)
		for pos in pathfinder.get_neighbors(_target.position, false):
			var cell = tilemap.world_to_map(pos)
			if cell in pathfinder.occupied_cells.keys():
				var _actor = pathfinder.occupied_cells[cell]
				if _actor.team == caster.team and not _actor in actors_healed:
					buffer.append(_actor)
				
	
