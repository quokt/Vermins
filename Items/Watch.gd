extends Item

export var turn : int = 15
export var bonus_damage : int = 6

export (String, MULTILINE) var description_activated

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	if opt_array[0] is int and opt_array[0] == turn:
		actor.damage_output_flat_modif += bonus_damage
		description = description_activated
		

func _get_custom_apply() -> String:
	return "turn_passed"
