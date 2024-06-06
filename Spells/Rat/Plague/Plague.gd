extends Spell

var push_strength : int = 4


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			request_push(caster.position, target, push_strength)
