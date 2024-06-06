extends Spell


func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	request_jump(target_dict["origin"])
	if crit:
		caster.current_energy += 1
