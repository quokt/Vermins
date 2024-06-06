extends Spell

enum MODE {FAMISHED, ENGORGED}
var current_mode = MODE.FAMISHED

export var base_health_percentage_bonus : int = 15
export var crit_health_precentage_bonus : int = 25

var health_percentage_bonus

func _process(_delta) ->void:
	
	if caster == null or not is_instance_valid(caster):
		return

	match caster.current_mode:
		MODE.ENGORGED:
			ai_targets = TARGETS.ALL
		MODE.FAMISHED:
			ai_targets = TARGETS.ENEMIES



func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	health_percentage_bonus = base_health_percentage_bonus if not crit else crit_health_precentage_bonus
	
	current_mode = caster.current_mode
	match current_mode:
		MODE.FAMISHED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					var bonus_damage = int(caster.current_health_points*health_percentage_bonus/100)
					_deal_damage(target, min_power+bonus_damage, max_power+bonus_damage)

			return
		
		MODE.ENGORGED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					if target.team != caster.team:
						_deal_damage(target)
					elif target.team == caster.team:
						_heal(target)

			return
					

