extends Item

export var bonus_range : int = 1
export var bonus_healing : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.range_modif += bonus_range
	actor.healing_output_flat_modif += bonus_healing
	
