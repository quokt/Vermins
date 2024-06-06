extends Spell

export var base_strength : int = 1
export var crit_strength : int = 2

onready var strength : int = base_strength

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	strength = base_strength if not crit else crit_strength
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			request_push(caster.position, target, strength)
