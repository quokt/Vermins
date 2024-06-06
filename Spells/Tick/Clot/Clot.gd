extends Spell

enum MODE {FAMISHED, ENGORGED}
var current_mode = MODE.FAMISHED

export (int) var base_min_range
export (int) var base_max_range

var power : Vector2


func _process(_delta) ->void:
	
	if caster == null or not is_instance_valid(caster):
		return
	current_mode = caster.current_mode
	match current_mode:
		MODE.ENGORGED:
			min_range = base_min_range
			max_range = base_max_range
			ai_targets = TARGETS.ENEMIES
			range_modif = true
		MODE.FAMISHED:
			min_range = 0
			max_range = 0
			ai_targets = TARGETS.CASTER
			range_modif = false


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	power = Vector2(min_power, max_power) if not crit else Vector2(crit_min_power, crit_max_power)
	
	current_mode = caster.current_mode
	match current_mode:
		MODE.FAMISHED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					_add_buff(caster)
					
					if not singleplayer:
						caster.rpc("set_current_mode", MODE.ENGORGED)
					else:
						caster.set_current_mode(MODE.ENGORGED)
					set_cooldown(cooldown-1)
			return
		
		MODE.ENGORGED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					_deal_damage(target, power.x, power.y)
					if not singleplayer:
						caster.rpc("set_current_mode", MODE.FAMISHED)
					else:
						caster.set_current_mode(MODE.FAMISHED)
			return
					

