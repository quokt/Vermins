extends Spell

export var health_bonus : int = 5
export var crit_health_bonus : int = 8

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target) and target.team == caster.team:
			if crit:
				target.max_health_points += crit_health_bonus
				target.current_health_points += crit_health_bonus
			else:
				target.max_health_points += health_bonus
				target.current_health_points += health_bonus
				
			_deal_damage(caster)
	
