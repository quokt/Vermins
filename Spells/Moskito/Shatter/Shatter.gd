extends Spell
#TODO add crit effect
var damage_multiplier : float
var bonus_treshold : Dictionary = {
	1.0 : 3.0,
	0.75 : 2.5,
	0.5 : 2.0,
	0.20 : 1.5,
	0.0 : 1.0
}

func _cast_spell(target_dict: Dictionary, crit : bool = false) -> void:
	var power := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	
	var health_ratio : float = float(caster.current_health_points) / float(caster.max_health_points)
	for treshold in bonus_treshold.keys():
		if health_ratio >= treshold:
			damage_multiplier = bonus_treshold[treshold]
			break
			
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target, power.x*damage_multiplier, power.y*damage_multiplier)
