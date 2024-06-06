extends Item

export var bonus_stamina : int = 1
export var bonus_range : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_stamina += bonus_stamina
	actor.range_modif += bonus_range
	
