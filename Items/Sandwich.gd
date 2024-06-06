extends Item

export var bonus_health : int = 14
export var range_debuff : int = 1

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points += bonus_health
	actor.range_modif -= range_debuff
	
