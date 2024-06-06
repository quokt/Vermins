extends Spell
#TODO : refresh this spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var no_energy_left : bool = caster.current_energy <= 0
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target)
			if no_energy_left:
				_add_buff(target, buff_name)

