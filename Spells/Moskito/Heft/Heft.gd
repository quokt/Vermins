extends Spell

export var caster_damage : int = 6

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if not crit:
				if target == caster:
					_deal_damage(caster, caster_damage, caster_damage)
				else:
					_deal_damage(target)
					
			elif target.team != caster.team:
				_deal_damage(target)
				
