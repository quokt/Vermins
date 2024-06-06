extends Spell
#TODO add crit effect

func _cast_spell(target_dict: Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	
	var power = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
		
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target, power.x, power.y)
