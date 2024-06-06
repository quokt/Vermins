extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if crit:
				_deal_damage(target, min_power * 2, max_power * 2)
			else:
				_deal_damage(target, min_power, max_power)
