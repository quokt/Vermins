extends Spell


export var push_strength = 1

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var damage := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)

	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				_deal_damage(target, damage.x, damage.y)
				request_push(caster.position, target, push_strength)
			elif target.team == caster.team:
				_add_buff(target, buff_name, crit)
