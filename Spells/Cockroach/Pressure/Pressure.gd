extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var power = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			var _damage = _deal_damage(target, power.x, power.y)
			if target.team != caster.team:
				target.max_health_points -= max(0, _damage)
