extends Item

export var bonus_health : int = 6
export var bonus_stamina : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points += bonus_health
	actor.bonus_stamina += bonus_stamina
	
