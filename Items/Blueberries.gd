extends Item

export var crit_chance : float = 0.03


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.crit_chance_bonus += crit_chance
	
