extends Spell

enum MODE {FAMISHED, ENGORGED}

export (int) var engorged_bonus_damage

export var crit_min_damage : int
export var crit_max_damage : int

export var base_min_healing : int
export var base_max_healing : int

export var crit_min_healing : int
export var crit_max_healing : int

var damage : Vector2
var healing : Vector2

func _process(_delta) ->void:
	
	if caster == null or not is_instance_valid(caster):
		return
	match caster.current_mode:
		MODE.ENGORGED:
			ai_targets = TARGETS.ALL
		MODE.FAMISHED:
			ai_targets = TARGETS.ENEMIES


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	damage = Vector2(min_power, max_power) if not crit else Vector2(crit_min_damage, crit_max_damage)
	healing = Vector2(base_min_healing, base_max_healing) if not crit else Vector2(crit_min_healing, crit_max_healing)
	
	match caster.current_mode:
		caster.MODE.FAMISHED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					if target.team != caster.team:
						_deal_damage(target)
			
			return
		caster.MODE.ENGORGED:
			for target in target_dict.values():
				if target is Actor and is_instance_valid(target):
					if target.team != caster.team:
						_deal_damage(target, damage.x+engorged_bonus_damage, damage.y+engorged_bonus_damage)
					elif target.team == caster.team:
						_heal(target, healing.x, healing.y)
			if not singleplayer:
				caster.rpc("set_current_mode", MODE.FAMISHED)
			else:
				caster.set_current_mode(MODE.FAMISHED)
			return
