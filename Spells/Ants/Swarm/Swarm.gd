extends Spell

#TODO : test this spell
#onready var tilemap : TileMap = get_tree().get_nodes_in_group("nav")[0]

export var delay : float = 0.8

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var min_damage = min_power
	var max_damage = max_power
	
	if crit:
		min_damage = crit_min_power
		max_damage = crit_max_power
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			for x in [0, 1]:
				for y in [0, 1]:
					var next = tilemap.world_to_map(target.position) + Vector2(x, y)
					if tilemap.get_occupied_cells().keys().has(next):
						if tilemap.get_occupied_cells()[next].CLASS == "WorkerAnt":
							
							_deal_damage(target, min_damage, max_damage)
							yield(get_tree().create_timer(delay),"timeout")
			
			_deal_damage(target, min_damage, max_damage)
