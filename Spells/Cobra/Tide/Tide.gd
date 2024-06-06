extends Spell

export var pull_strength = 2

var damage : Vector2

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	damage = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	request_jump(target_dict["origin"])
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target == caster:
				continue
			request_slide(caster.position, target, pull_strength)
			if target.team != caster.team:
				_deal_damage(target, damage.x, damage.y)
