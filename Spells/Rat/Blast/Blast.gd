extends Spell

var base_push_strength : int = 4
var crit_push_strength : int = 5

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var push_strength = base_push_strength if not crit else crit_push_strength
	
	for target in target_dict.values():
		if target is Actor:
			request_push(caster.position, target, push_strength)
