extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown -1)
	
	for target in target_dict.values():
		if target is Actor:
			_add_buff(target, buff_name)
