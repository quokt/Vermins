extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
		crit_autocast(target_dict)
	else:
		autocast(target_dict)
