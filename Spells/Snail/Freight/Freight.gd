extends Spell

#onready var tilemap = get_tree().get_nodes_in_group("nav")[0]

var power : Vector2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	power = Vector2(crit_min_power, crit_max_power) if crit else Vector2(min_power, max_power)
	
	var _target = tilemap.get_occupied_cells()[tilemap.world_to_map(target_dict["origin"])]
	if _target.team == caster.team:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				if target == _target:
					_heal(target, power.x, power.y)
				else:
					_deal_damage(target, power.x, power.y)
	
	elif _target.team != caster.team:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				if target == _target:
					_deal_damage(target, power.x, power.y)
				else:
					_heal(target, power.x, power.y)
	return
