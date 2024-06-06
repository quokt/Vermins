extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	if crit:
		caster.max_health_points += 4
		caster.current_health_points += 4
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_lifesteal(target, min_power, max_power)
	

