extends Item

export var bonus_initiative : int = 4
export var bonus_crit_chance : float = 0.05

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.initiative += bonus_initiative
	actor.crit_chance_bonus += bonus_crit_chance
	
