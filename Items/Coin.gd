extends Item

export var turn : int = 3
export var bonus_energy : int = 3

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	if opt_array[0] is int and opt_array[0] > turn:
		return
	
	actor.current_energy += bonus_energy
		
	

func _get_custom_apply() -> String:
	return "turn_passed"
