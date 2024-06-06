extends Item

export var bonus_health : int = 6
export var bonus_damage : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.bonus_health_points += bonus_health
	actor.damage_output_flat_modif += bonus_damage
	
