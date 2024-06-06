extends Spell

export var slide_strength : int = 4
export var push_strength : int = 4

func _cast_spell(target_dict : Dictionary, crit : bool = false) -> void:
	
	var actors_healed := []
	var buffer := []
	
	for target in target_dict.values():
		if target is Actor and is_instance_valid(target):
			if target.team == caster.team:
				request_slide(target.position, caster, slide_strength)
			elif target.team != caster.team:
				request_push(caster.position, target, push_strength)
				
	
