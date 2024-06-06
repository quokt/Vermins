extends Spell

export var push_strength : int = 5
export var pull_strength : int = 5

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	if crit:
		caster.current_energy += 1 
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				request_slide(caster.position, target, pull_strength)
			elif target.team == caster.team:
				request_push(caster.position, target, push_strength)
