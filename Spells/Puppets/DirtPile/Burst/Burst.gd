extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target != caster:
				_deal_damage(target)
