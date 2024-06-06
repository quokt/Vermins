extends Spell

enum MODE {FAMISHED, ENGORGED}
var current_mode = MODE.FAMISHED


export (int) var min_healing
export (int) var max_healing

export (float, 0.0, 2.0) var lifesteal_amount

func _process(delta):
	match current_mode:
		MODE.FAMISHED:
			ai_targets = TARGETS.ENEMIES
		MODE.ENGORGED:
			ai_targets = TARGETS.ALLIES


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	var damage := Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	current_mode = caster.current_mode
	match current_mode:
		MODE.FAMISHED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					_lifesteal(target, damage.x, damage.y, lifesteal_amount)
					if not singleplayer:
						caster.rpc("set_current_mode", MODE.ENGORGED)
					else:
						caster.set_current_mode(MODE.ENGORGED)
			return
		
		MODE.ENGORGED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					_heal(target, min_healing, max_healing)
					if not crit:
						_deal_damage(caster, int(min_healing/2), int(max_healing/2))
					if not singleplayer:
						caster.rpc("set_current_mode", MODE.FAMISHED)
					else:
						caster.set_current_mode(MODE.FAMISHED)
			return
					

