extends Spell

var damage = Vector2(min_power, max_power)


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var bonus_damage = 1 if not crit else 2
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target)
			damage.x += bonus_damage
			damage.y += bonus_damage
