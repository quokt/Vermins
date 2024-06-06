extends Spell

export (int) var pull_strength

func _cast_spell(_target_dict : Dictionary, crit : bool = false) -> void:
	autocast(_target_dict)
#	for target in _target_dict.values():
#		if target is Actor and is_instance_valid(target):
#			request_slide(caster.position, target, pull_strength)
