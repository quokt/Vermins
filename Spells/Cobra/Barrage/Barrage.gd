extends Spell

export var base_max_health_bonus : int = 1
export var crit_max_health_bonus : int = 2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var max_health_bonus
	max_health_bonus = base_max_health_bonus if not crit else crit_max_health_bonus
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target == caster:
				continue
			_deal_damage(target)
			caster.max_health_points += max_health_bonus
			caster.current_health_points += max_health_bonus
