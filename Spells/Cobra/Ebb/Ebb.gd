extends Spell

export var push_strength = 3

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target == caster:
				continue
			request_push(caster.position, target, push_strength)
			if target.team != caster.team:
				_deal_damage(target)
				_add_buff(target, buff_name, crit)
