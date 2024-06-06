extends Spell

enum MODE {FAMISHED, ENGORGED}

export (int) var famished_bonus_damage
#TODO : add crit effect

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var damage := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			match caster.current_mode:
				caster.MODE.FAMISHED:
					_lifesteal(target, damage.x+famished_bonus_damage, damage.y + famished_bonus_damage)
					if not singleplayer:
						caster.rpc("set_current_mode", MODE.ENGORGED)
					else:
						caster.set_current_mode(MODE.ENGORGED)
					return
				caster.MODE.ENGORGED:
					_deal_damage(target)
					return
