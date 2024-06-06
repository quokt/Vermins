extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var lifesteal = 0.5 if not crit else 1.0
	var heal_target : Actor = null
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.position == target_dict["origin"]:
				heal_target = target
				break
		
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target == heal_target:
				continue
			_lifesteal(target, min_power, max_power, lifesteal, heal_target)
