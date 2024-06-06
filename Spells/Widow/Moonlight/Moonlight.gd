extends Spell

#TODO : add crit effect


func _cast_spell(target_dict: Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown -1)
	
	var enemy_count : int = 0
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team != caster.team:
				enemy_count += 1
				_add_buff(target, buff_name)
	
	for enemy in enemy_count:
		_add_buff(caster, buff_name)
