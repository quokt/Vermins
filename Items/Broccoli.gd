extends Item

export (int) var bonus_health = 12


func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points += bonus_health
