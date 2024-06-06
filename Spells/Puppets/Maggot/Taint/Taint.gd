extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var lifesteal = 0.5 if not crit else 1.0
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_lifesteal(target, min_power, max_power, lifesteal)
