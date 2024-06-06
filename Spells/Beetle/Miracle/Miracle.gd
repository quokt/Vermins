extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		#TODO : test the cooldown reduction
		set_cooldown(cooldown-1)
		
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_add_buff(target)
