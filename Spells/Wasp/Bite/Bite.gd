extends Spell

#TODO : this spell is not working

#export var double_damage_chance : float = 0.2
#export var crit_damage_bonus : int = 4

var power : Vector2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
#	power = Vector2(min_power, max_power) if not crit else Vector2(min_power*2, max_power*2)
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
#			if randf() <= double_damage_chance:
#				_deal_damage(target, power.x * 2, power.y * 2)
#			else:
			_deal_damage(target)
			if target.current_health_points <= 0:
				return
			if crit:
				yield(get_tree().create_timer(0.7),"timeout")
				cast_spell(target_dict["origin"], false, true)
