extends Spell

export var push_strength = 2
export var crit_push_strength = 3

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.position == target_dict["origin"]:
				continue
			if crit:
				request_push(target_dict["origin"], target, crit_push_strength)
			else:
				request_push(target_dict["origin"], target, push_strength)

