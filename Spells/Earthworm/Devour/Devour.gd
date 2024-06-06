extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var power := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	
	var lifesteal_coef := 0.5 if not crit else 1.0
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_lifesteal(target, power.x, power.y, lifesteal_coef)
