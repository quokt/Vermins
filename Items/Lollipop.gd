extends Item

export var crit_chance : float = 0.10
export var health_debuff : int = 10


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.max_health_points -= health_debuff
	actor.crit_chance_bonus += crit_chance
	
