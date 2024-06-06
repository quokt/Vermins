extends Spell

#TODO: test this spell critical effect

export var delay : float = 0.8

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if crit and target.team != caster.team:
				_deal_damage(target)
			else:
				_deal_damage(target)
	
	yield(get_tree().create_timer(delay),"timeout")
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target) and not target.dead:
			if crit and target.team == caster.team:
				_heal(target)
			else:
				_heal(target)
