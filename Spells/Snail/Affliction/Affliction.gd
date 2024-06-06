extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var power := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power) 
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				_deal_damage(target, power.x, power.y)
			elif target.team == caster.team:
				_heal(target, power.x, power.y)
