extends Item

export var physic_dr : int = 2
export var bonus_damage_output_flat : int = 2

func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.resistances["Physic"]["Flat"] += physic_dr
	actor.damage_type_modif["Physic"]["Flat"] += bonus_damage_output_flat
	
