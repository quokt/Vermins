extends Spell

export var amount : int = 4
export var delay = 0.6

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var power = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	
	for i in amount:
		for target in target_dict.values():
			if target is Actor and is_instance_valid(target):
				if target == caster:
					continue
				_deal_damage(target, power.x, power.y)
		
		yield(get_tree().create_timer(delay), "timeout")
