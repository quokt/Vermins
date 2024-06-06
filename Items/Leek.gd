extends Item

export (int) var damage_bonus = 2



func _apply_item(actor : Actor = target, opt_array : Array = []) -> void:
	actor.damage_type_modif["Physic"]["Flat"] += damage_bonus
