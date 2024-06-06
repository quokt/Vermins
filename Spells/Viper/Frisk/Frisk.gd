extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	if crit:
		caster.current_energy += 1
	
	var target_pos : Vector2 = target_dict["origin"]
	var caster_pos : Vector2 = caster.position
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			request_jump(caster_pos, target)
	
	request_jump(target_pos, caster)
	
	
	
