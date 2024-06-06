extends Spell

var max_health_bonus : int = 4

export var base_health_bonus : int = 4
export var crit_health_bonus : int = 5

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	max_health_bonus = base_health_bonus if not crit else crit_health_bonus
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
#			if target == caster:
#				continue
			if not crit:
				target.max_health_points += max_health_bonus
			elif crit:
				if target.team == caster.team:
					target.max_health_points += max_health_bonus
