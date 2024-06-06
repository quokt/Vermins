extends Spell

export var min_healing : int = 6
export var max_healing : int = 12

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if not crit:
				_deal_damage(target)
			elif target.team != caster.team:
				_deal_damage(target)
					
			if target.team == caster.team:
				_heal(target, min_healing, max_healing)
