extends Spell

export var base_strength : int = 3
export var crit_strength : int = 4

var strength : int

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	strength = base_strength if not crit else crit_strength
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			request_push(caster.position, target, strength)
