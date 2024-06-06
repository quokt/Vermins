extends Spell

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	if crit:
		set_cooldown(cooldown-1)
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			var target_pos : Vector2 = target.position
			var caster_pos : Vector2 = caster.position
			request_jump(target_pos, caster)
			request_jump(caster_pos, target)
#			_deal_damage(target)
		
