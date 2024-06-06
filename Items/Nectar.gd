extends Item

export var bonus_energy : int = 1
export var bonus_health : int = 6

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_energy += bonus_energy
	actor.bonus_health_points += bonus_health
	
