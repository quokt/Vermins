extends Spell

export var push_strength := 1
export var crit_push := 2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var heal := Vector2(min_power, max_power)
	var strength := push_strength
	if crit:
		heal = Vector2(crit_min_power, crit_max_power)
		strength = crit_push
		
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				request_push(caster.position, target, strength)
			elif target.team == caster.team:
				_heal(target, heal.x, heal.y)
