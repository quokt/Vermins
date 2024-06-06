extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		crit_autocast(target_dict)
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				_add_buff(target, buff_name, crit)
	else:
		autocast(target_dict)
