extends Spell

#TODO : add crit effect


func _cast_spell(target_dict: Dictionary, crit : bool = false) -> void:
	if crit:
		caster.current_energy += 2
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				_add_buff(target, buff_name)
