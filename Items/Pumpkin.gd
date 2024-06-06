extends Item

export var crit_chance : float = 0.06


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.crit_chance_bonus += crit_chance
	
