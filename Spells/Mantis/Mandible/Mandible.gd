extends Spell

export var bonus_damage = 4
export var crit_bonus_damage = 8

onready var min_damage = min_power
onready var max_damage = max_power

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			_deal_damage(target, min_damage, max_damage)
			if crit:
				min_damage += crit_bonus_damage
				max_damage += crit_bonus_damage
			else:
				min_damage += bonus_damage
				max_damage += bonus_damage
