extends Spell

#TODO : test critical effects on all spells
#TODO : test this buff

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if crit:
				_deal_damage(target, crit_min_power, crit_max_power)
				if target.team != caster.team:
					_add_buff(target, buff_name, false) #this buff is always critical
			else:
				_deal_damage(target)
			
