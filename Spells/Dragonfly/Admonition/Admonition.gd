extends Spell

export var push_strength = 1
export var crit_push = 2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	request_jump(target_dict["origin"])
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			var strength : int = push_strength
			if target == caster:
				continue
			if crit:
				strength = crit_push
			request_push(caster.position, target, strength)
